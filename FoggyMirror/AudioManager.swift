import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var audioLevelTimer: Timer?
    
    @Published var audioLevel: Float = 0.0
    @Published var isListening = false
    
    private let breathingThreshold: Float = 0.02  // Very sensitive threshold for easier detection
    
    func startListening() {
        requestMicrophonePermission { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.setupAudioEngine()
                }
            }
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap if it exists
        if let inputNode = inputNode {
            inputNode.removeTap(onBus: 0)
        }
        
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        isListening = false
        audioLevel = 0.0
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        // Use the standard AVAudioSession method - it's not deprecated in iOS 17+
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    private func setupAudioEngine() {
        do {
            // Stop engine if already running
            if audioEngine.isRunning {
                audioEngine.stop()
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            inputNode = audioEngine.inputNode
            guard let inputNode = inputNode else {
                print("Failed to get input node")
                return
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Remove existing tap if any
            inputNode.removeTap(onBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.processAudioBuffer(buffer)
            }
            
            try audioEngine.start()
            isListening = true
            
            // Start timer to update audio level
            audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                // Timer helps with UI updates
            }
            
        } catch {
            print("Failed to setup audio engine: \(error)")
            isListening = false
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0.0
        
        // Calculate RMS (Root Mean Square) for audio level
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        let level = min(max(rms, 0.0), 1.0) // Clamp between 0 and 1
        
        DispatchQueue.main.async {
            self.audioLevel = level
        }
    }
    
    var isBreathing: Bool {
        return audioLevel > breathingThreshold
    }
    
    deinit {
        stopListening()
    }
}
