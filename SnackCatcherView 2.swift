//
//  SnackCatcherView.swift
//  Foggy Mirror
//
//  Face tracking game: catch falling snacks with your mouth!
//

import SwiftUI
import ARKit

// MARK: - Game State
enum GameState {
    case ready
    case playing
    case gameOver
}

// MARK: - Falling Emoji Model
struct FallingEmoji: Identifiable {
    let id = UUID()
    let emoji: String
    var x: CGFloat
    var y: CGFloat
}

// MARK: - Face Tracking Manager
class FaceTrackingManager: NSObject, ObservableObject, ARSCNViewDelegate {
    @Published var isMouthOpen = false
    let arView = ARSCNView()
    private let threshold: Float = 0.6
    
    override init() {
        super.init()
        arView.delegate = self
        arView.isHidden = true // We only need face data, not visual
    }
    
    func startTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("❌ Face tracking not supported on this device")
            return
        }
        
        print("✅ Starting face tracking...")
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopTracking() {
        arView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let jawOpen = faceAnchor.blendShapes[.jawOpen]?.floatValue ?? 0
        
        DispatchQueue.main.async {
            self.isMouthOpen = jawOpen > self.threshold
            // Debug: Print jaw open values (remove this later)
            if jawOpen > 0.1 {
                print("Jaw open value: \(jawOpen) | Mouth detected as: \(self.isMouthOpen ? "OPEN" : "closed")")
            }
        }
    }
}

// MARK: - Main Game View
struct SnackCatcherView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var faceTracker = FaceTrackingManager()
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var fallingEmojis: [FallingEmoji] = []
    @State private var spawnTimer: Timer?
    @State private var fallTimer: Timer?
    @State private var gameTimer: Timer?
    
    let emojiOptions = ["🍕", "🍩", "🍪", "🍔", "🌮", "🍰"]
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.95, green: 0.95, blue: 0.85)
                .ignoresSafeArea()
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🍕 Snack Catcher 🍰")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                    
                    VStack(spacing: 15) {
                        Text("Open your mouth to catch falling snacks!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        Text("30 seconds • 1 point per catch")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: startGame) {
                        Text("Tap to Start")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.3, green: 0.7, blue: 0.5), Color(red: 0.2, green: 0.5, blue: 0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                    }
                }
                
            } else if gameState == .playing {
                // Game Screen
                VStack {
                    // Top Bar
                    HStack {
                        // Score
                        Text("Score: \(score)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                        
                        Spacer()
                        
                        // Timer
                        Text("⏱️ \(timeRemaining)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining <= 5 ? .red : Color(red: 0.3, green: 0.5, blue: 0.7))
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    
                    Spacer()
                    
                    // Mouth Open Indicator
                    VStack(spacing: 10) {
                        Circle()
                            .fill(faceTracker.isMouthOpen ? Color.green : Color.gray)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(faceTracker.isMouthOpen ? "😮" : "😊")
                                    .font(.system(size: 40))
                            )
                            .shadow(color: faceTracker.isMouthOpen ? Color.green : Color.clear, radius: 20)
                        
                        Text(faceTracker.isMouthOpen ? "MOUTH OPEN!" : "Open your mouth")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(faceTracker.isMouthOpen ? .green : .gray)
                    }
                    .padding(.bottom, 40)
                }
                
                // Falling Emojis
                ForEach(fallingEmojis) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 60))
                        .position(x: emoji.x, y: emoji.y)
                }
                
            } else if gameState == .gameOver {
                // Game Over Screen
                VStack(spacing: 30) {
                    Text("Game Over!")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: startGame) {
                            Text("Play Again")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.3, green: 0.7, blue: 0.5), Color(red: 0.2, green: 0.5, blue: 0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(radius: 10)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Back")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.3, green: 0.5, blue: 0.7), lineWidth: 2)
                                )
                        }
                    }
                }
            }
            
            // Back button (always visible except on game over)
            if gameState != .gameOver {
                VStack {
                    HStack {
                        Button(action: {
                            stopGame()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            faceTracker.startTracking()
        }
        .onDisappear {
            stopGame()
            faceTracker.stopTracking()
        }
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        // Reset
        score = 0
        timeRemaining = 30
        fallingEmojis = []
        gameState = .playing
        
        // Start spawn timer
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            spawnEmoji()
        }
        
        // Start fall timer (update positions)
        fallTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateEmojis()
        }
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    private func stopGame() {
        spawnTimer?.invalidate()
        fallTimer?.invalidate()
        gameTimer?.invalidate()
        spawnTimer = nil
        fallTimer = nil
        gameTimer = nil
    }
    
    private func endGame() {
        stopGame()
        gameState = .gameOver
    }
    
    private func spawnEmoji() {
        guard fallingEmojis.count < 10 else { return } // Limit active emojis
        
        let randomEmoji = emojiOptions.randomElement() ?? "🍕"
        let randomX = CGFloat.random(in: 60...(screenWidth - 60))
        
        let newEmoji = FallingEmoji(emoji: randomEmoji, x: randomX, y: -50)
        fallingEmojis.append(newEmoji)
    }
    
    private func updateEmojis() {
        let fallSpeed: CGFloat = 3.0
        let catchZoneY = screenHeight * 0.75 // Bottom 1/4
        let catchZoneCenterX = screenWidth / 2
        let catchZoneWidth = screenWidth / 3
        
        var indicesToRemove: [UUID] = []
        
        for (index, emoji) in fallingEmojis.enumerated() {
            // Update position
            fallingEmojis[index].y += fallSpeed
            
            // Check if caught
            if faceTracker.isMouthOpen &&
               emoji.y >= catchZoneY &&
               emoji.y <= screenHeight &&
               abs(emoji.x - catchZoneCenterX) <= catchZoneWidth / 2 {
                score += 1
                indicesToRemove.append(emoji.id)
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            // Remove if off screen
            if emoji.y > screenHeight + 50 {
                indicesToRemove.append(emoji.id)
            }
        }
        
        // Remove caught/missed emojis
        fallingEmojis.removeAll { indicesToRemove.contains($0.id) }
    }
}

#Preview {
    SnackCatcherView()
}

