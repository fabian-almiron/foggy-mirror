//
//  CircleTapView.swift
//  Foggy Mirror
//
//  Pop balloons before they disappear!
//

import SwiftUI

// MARK: - Balloon Model
struct TappableBalloon: Identifiable {
    let id = UUID()
    let position: CGPoint
    let spawnTime: Date
    let lifespan: Double = 2.0
    let emoji: String
}

// MARK: - Balloon Pop Game View
struct CircleTapView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var balloons: [TappableBalloon] = []
    @State private var poppingBalloons: [UUID: Bool] = [:]
    @State private var timeRemaining = 30
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var updateTimer: Timer?
    @State private var bestScore: Int? = nil
    @State private var spawnInterval: Double = 0.5
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let balloonSize: CGFloat = 60
    let balloonEmojis = ["🎈", "🎈", "🎈", "🎈", "🎈"] // Mostly red, can add variety
    
    enum GameState {
        case ready
        case playing
        case gameOver
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.95),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🎈 Balloon Pop 🎈")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
                    
                    VStack(spacing: 15) {
                        Text("Pop balloons before they disappear!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        Text("30 seconds • Gets faster as you go!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if let best = bestScore {
                            Text("Best Score: \(best)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
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
                                    colors: [Color(red: 0.8, green: 0.3, blue: 0.5), Color(red: 0.6, green: 0.4, blue: 0.8)],
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
                    // Top bar with score and timer
                    HStack {
                        Text("Score: \(score)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
                        
                        Spacer()
                        
                        Text("⏱️ \(timeRemaining)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining <= 5 ? .red : Color(red: 0.8, green: 0.3, blue: 0.5))
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding()
                    
                    Spacer()
                }
                
                // Balloons
                ForEach(balloons) { balloon in
                    let age = Date().timeIntervalSince(balloon.spawnTime)
                    let progress = age / balloon.lifespan
                    let isPopping = poppingBalloons[balloon.id] ?? false
                    
                    if progress < 1.0 && !isPopping {
                        let scale = 1.0 - (progress * 0.3) // Shrink to 70%
                        let opacity = 1.0 - progress // Fade out
                        
                        Text(balloon.emoji)
                            .font(.system(size: balloonSize))
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .position(balloon.position)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                            .onTapGesture {
                                popBalloon(balloon)
                            }
                    } else if isPopping {
                        // Pop animation - burst effect
                        Text("💥")
                            .font(.system(size: balloonSize * 1.5))
                            .position(balloon.position)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
            } else if gameState == .gameOver {
                // Game Over Screen
                VStack(spacing: 30) {
                    Text("Time's Up!")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
                        
                        if let best = bestScore, score >= best {
                            Text("🏆 New Best Score!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
                        }
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
                                        colors: [Color(red: 0.8, green: 0.3, blue: 0.5), Color(red: 0.6, green: 0.4, blue: 0.8)],
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
                                .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.5))
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.8, green: 0.3, blue: 0.5), lineWidth: 2)
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
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        score = 0
        timeRemaining = 30
        balloons = []
        poppingBalloons = [:]
        spawnInterval = 0.5 // Starting speed
        gameState = .playing
        
        // Start game timer (countdown)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            
            // Speed up every 5 seconds
            if timeRemaining % 5 == 0 && timeRemaining > 0 {
                speedUpGame()
            }
            
            if timeRemaining <= 0 {
                endGame()
            }
        }
        
        // Start spawn timer with initial interval
        scheduleNextSpawn()
        
        // Start update timer (remove expired circles)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            removeExpiredCircles()
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        updateTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
        updateTimer = nil
    }
    
    private func endGame() {
        stopGame()
        
        // Update best score
        if bestScore == nil || score > bestScore! {
            bestScore = score
        }
        
        gameState = .gameOver
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func scheduleNextSpawn() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: false) { _ in
            self.spawnBalloon()
            self.scheduleNextSpawn() // Schedule next one
        }
    }
    
    private func speedUpGame() {
        // Decrease spawn interval (faster spawning)
        // 0.5 start -> 0.1 end = 5x faster over 30 seconds (6 speed-ups)
        spawnInterval = max(0.1, spawnInterval - 0.067) // Get faster, min 0.1 seconds
    }
    
    private func spawnBalloon() {
        let margin: CGFloat = 60
        let randomX = CGFloat.random(in: margin...(screenWidth - margin))
        let randomY = CGFloat.random(in: (150 + margin)...(screenHeight - margin))
        let randomEmoji = balloonEmojis.randomElement() ?? "🎈"
        
        let newBalloon = TappableBalloon(
            position: CGPoint(x: randomX, y: randomY),
            spawnTime: Date(),
            emoji: randomEmoji
        )
        
        balloons.append(newBalloon)
    }
    
    private func removeExpiredCircles() {
        balloons.removeAll { balloon in
            let age = Date().timeIntervalSince(balloon.spawnTime)
            let isPopping = poppingBalloons[balloon.id] ?? false
            return (age >= balloon.lifespan && !isPopping) || (isPopping && age > balloon.lifespan + 0.2)
        }
        
        // Clean up popping state for removed balloons
        poppingBalloons = poppingBalloons.filter { id, _ in
            balloons.contains { $0.id == id }
        }
    }
    
    private func popBalloon(_ balloon: TappableBalloon) {
        // Mark as popping
        withAnimation(.easeOut(duration: 0.15)) {
            poppingBalloons[balloon.id] = true
        }
        
        // Remove after pop animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            balloons.removeAll { $0.id == balloon.id }
            poppingBalloons.removeValue(forKey: balloon.id)
        }
        
        // Increase score
        score += 1
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

#Preview {
    CircleTapView()
}

