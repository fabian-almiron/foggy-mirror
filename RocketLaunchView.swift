//
//  RocketLaunchView.swift
//  Foggy Mirror
//
//  Sound-controlled rocket that avoids obstacles
//

import SwiftUI
import AVFoundation

// MARK: - Obstacle Model
struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

// MARK: - Sound Detector
class SoundDetector: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    @Published var soundLevel: Float = 0
    
    func startListening() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement)
        try? audioSession.setActive(true)
        
        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        try? audioRecorder = AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateSoundLevel()
        }
    }
    
    func stopListening() {
        timer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
        timer = nil
    }
    
    private func updateSoundLevel() {
        audioRecorder?.updateMeters()
        let decibels = audioRecorder?.averagePower(forChannel: 0) ?? -160
        
        // Convert decibels to 0-1 range (normalize from -50 to 0 dB)
        let normalized = (decibels + 50) / 50
        soundLevel = max(0, min(1, normalized))
    }
}

// MARK: - Rocket Launch Game View
struct RocketLaunchView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var soundDetector = SoundDetector()
    @State private var gameState: GameState = .ready
    @State private var rocketY: CGFloat = 0
    @State private var targetY: CGFloat = 0
    @State private var score = 0
    @State private var obstacles: [Obstacle] = []
    @State private var gameTimer: Timer?
    @State private var obstacleTimer: Timer?
    @State private var bestScore: Int? = nil
    @State private var hasExploded = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let rocketSize: CGFloat = 60
    let obstacleSpeed: CGFloat = 4.0
    
    enum GameState {
        case ready
        case playing
        case gameOver
    }
    
    var body: some View {
        ZStack {
            // Background - space theme
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...screenWidth),
                        y: CGFloat.random(in: 0...screenHeight)
                    )
            }
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🚀 Rocket Launch 🚀")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                    
                    VStack(spacing: 15) {
                        Text("Make sound to fly up!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 40)
                        
                        Text("Quiet = fall • Loud = rise • Avoid obstacles!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if let best = bestScore {
                            Text("Best Score: \(best)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                                .padding(.top, 5)
                        }
                    }
                    
                    Button(action: startGame) {
                        Text("Start")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.4, blue: 0.3), Color(red: 1.0, green: 0.6, blue: 0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                    }
                }
                
            } else if gameState == .playing {
                VStack {
                    // Score at top
                    HStack {
                        Text("Score: \(score)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Sound level indicator
                        VStack(spacing: 5) {
                            Text("🔊")
                                .font(.system(size: 20))
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.2))
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.yellow, Color.red],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(height: geometry.size.height * CGFloat(soundDetector.soundLevel))
                                }
                            }
                            .frame(width: 30, height: 60)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    
                    Spacer()
                }
                
                // Obstacles
                ForEach(obstacles) { obstacle in
                    Rectangle()
                        .fill(Color(red: 0.5, green: 0.2, blue: 0.3))
                        .frame(width: obstacle.width, height: obstacle.height)
                        .position(x: obstacle.x, y: obstacle.y)
                        .overlay(
                            Rectangle()
                                .stroke(Color(red: 0.8, green: 0.3, blue: 0.4), lineWidth: 2)
                                .position(x: obstacle.x, y: obstacle.y)
                        )
                }
                
                // Rocket
                if !hasExploded {
                    Text("🚀")
                        .font(.system(size: rocketSize))
                        .rotationEffect(.degrees(-90))
                        .position(x: 80, y: rocketY)
                        .shadow(color: Color.orange, radius: 10)
                } else {
                    Text("💥")
                        .font(.system(size: rocketSize * 1.5))
                        .position(x: 80, y: rocketY)
                }
                
            } else if gameState == .gameOver {
                // Game Over Screen
                VStack(spacing: 30) {
                    Text("Crashed!")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                    
                    Text("💥")
                        .font(.system(size: 100))
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(score)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                        
                        if let best = bestScore, score >= best {
                            Text("🏆 New Best Score!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: startGame) {
                            Text("Try Again")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.4, blue: 0.3), Color(red: 1.0, green: 0.6, blue: 0.2)],
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
                                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 1.0, green: 0.4, blue: 0.3), lineWidth: 2)
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
            soundDetector.startListening()
        }
        .onDisappear {
            stopGame()
            soundDetector.stopListening()
        }
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        score = 0
        rocketY = screenHeight / 2
        targetY = rocketY
        obstacles = []
        hasExploded = false
        gameState = .playing
        
        // Start game update timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateGame()
        }
        
        // Start obstacle spawner
        obstacleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            spawnObstacle()
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        obstacleTimer?.invalidate()
        gameTimer = nil
        obstacleTimer = nil
    }
    
    private func updateGame() {
        // Update rocket position based on sound
        // Loud sound = fly up, quiet = fall down
        let soundPower = CGFloat(soundDetector.soundLevel)
        
        // Calculate target Y based on sound (inverted - high sound = low Y)
        targetY -= (soundPower - 0.3) * 15 // Adjust for gravity and sound power
        targetY = max(50, min(screenHeight - 50, targetY))
        
        // Smooth movement
        rocketY += (targetY - rocketY) * 0.15
        
        // Move obstacles left
        for index in obstacles.indices {
            obstacles[index].x -= obstacleSpeed
        }
        
        // Remove off-screen obstacles and increment score
        let initialCount = obstacles.count
        obstacles.removeAll { $0.x < -100 }
        if obstacles.count < initialCount {
            score += 1
        }
        
        // Check collisions
        checkCollisions()
    }
    
    private func spawnObstacle() {
        let gapSize: CGFloat = 180
        let gapPosition = CGFloat.random(in: 150...(screenHeight - 150))
        
        // Top obstacle
        let topHeight = gapPosition - gapSize / 2
        if topHeight > 0 {
            obstacles.append(Obstacle(
                x: screenWidth + 50,
                y: topHeight / 2,
                width: 60,
                height: topHeight
            ))
        }
        
        // Bottom obstacle
        let bottomY = gapPosition + gapSize / 2
        let bottomHeight = screenHeight - bottomY
        if bottomHeight > 0 {
            obstacles.append(Obstacle(
                x: screenWidth + 50,
                y: bottomY + bottomHeight / 2,
                width: 60,
                height: bottomHeight
            ))
        }
    }
    
    private func checkCollisions() {
        let rocketRect = CGRect(
            x: 80 - rocketSize / 2,
            y: rocketY - rocketSize / 2,
            width: rocketSize,
            height: rocketSize
        )
        
        for obstacle in obstacles {
            let obstacleRect = CGRect(
                x: obstacle.x - obstacle.width / 2,
                y: obstacle.y - obstacle.height / 2,
                width: obstacle.width,
                height: obstacle.height
            )
            
            if rocketRect.intersects(obstacleRect) {
                crash()
                return
            }
        }
        
        // Check if hit top or bottom
        if rocketY < 50 || rocketY > screenHeight - 50 {
            crash()
        }
    }
    
    private func crash() {
        hasExploded = true
        stopGame()
        
        // Update best score
        if bestScore == nil || score > bestScore! {
            bestScore = score
        }
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
        
        // Show game over after explosion animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            gameState = .gameOver
        }
    }
}

#Preview {
    RocketLaunchView()
}

