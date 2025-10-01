//
//  MazeBallView.swift
//  Foggy Mirror
//
//  Tilt-controlled maze ball game
//

import SwiftUI
import CoreMotion

// MARK: - Wall Model
struct Wall: Identifiable {
    let id = UUID()
    let rect: CGRect
}

// MARK: - Motion Manager
class TiltManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var tiltX: Double = 0
    @Published var tiltY: Double = 0
    
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.02
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            
            // Get gravity (device orientation)
            self?.tiltX = motion.gravity.x
            self?.tiltY = motion.gravity.y
        }
    }
    
    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Maze Ball Game View
struct MazeBallView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var tiltManager = TiltManager()
    @State private var ballPosition = CGPoint(x: 50, y: 100)
    @State private var velocity = CGPoint.zero
    @State private var gameState: GameState = .ready
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    @State private var hasWon = false
    @State private var bestTime: Double? = nil
    @State private var mazeWalls: [Wall] = []
    
    let ballSize: CGFloat = 30
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    enum GameState {
        case ready
        case playing
        case won
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.95, green: 0.9, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🎯 Maze Ball 🎯")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                    
                    VStack(spacing: 15) {
                        Text("Tilt your phone to roll the ball through the maze!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        if let best = bestTime {
                            Text("Best Time: \(String(format: "%.1f", best))s")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
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
                    // Timer at top
                    Text("⏱️ \(String(format: "%.1f", elapsedTime))s")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.top, 60)
                    
                    Spacer()
                }
                
                // Maze walls
                ForEach(mazeWalls) { wall in
                    Rectangle()
                        .fill(Color(red: 0.3, green: 0.4, blue: 0.6))
                        .frame(width: wall.rect.width, height: wall.rect.height)
                        .position(x: wall.rect.midX, y: wall.rect.midY)
                        .shadow(radius: 3)
                }
                
                // Start zone (green)
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .position(x: 50, y: 100)
                    .overlay(
                        Text("START")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                            .position(x: 50, y: 100)
                    )
                
                // End zone (goal - red)
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .position(x: screenWidth - 50, y: screenHeight - 150)
                    .overlay(
                        Text("GOAL")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                            .position(x: screenWidth - 50, y: screenHeight - 150)
                    )
                
                // Ball
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange, Color.red],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                
            } else if gameState == .won {
                // Win Screen
                VStack(spacing: 30) {
                    Text("🎉 You Win! 🎉")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
                    
                    VStack(spacing: 10) {
                        Text("Time")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.1f", elapsedTime))s")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                        
                        if let best = bestTime, elapsedTime < best {
                            Text("🏆 New Best Time!")
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
            
            // Back button (always visible except on win screen)
            if gameState != .won {
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
            tiltManager.startTracking()
            generateNewMaze()
        }
        .onDisappear {
            stopGame()
            tiltManager.stopTracking()
        }
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        generateNewMaze() // Generate new maze each time
        ballPosition = CGPoint(x: 50, y: 100)
        velocity = .zero
        elapsedTime = 0
        hasWon = false
        gameState = .playing
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
        }
        
        // Start physics update loop
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateBallPosition()
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        updateTimer?.invalidate()
        timer = nil
        updateTimer = nil
    }
    
    private func updateBallPosition() {
        // Apply gravity/tilt force
        let force = CGPoint(
            x: tiltManager.tiltX * 0.8,
            y: -tiltManager.tiltY * 0.8
        )
        
        // Update velocity with friction
        velocity.x += force.x
        velocity.y += force.y
        velocity.x *= 0.98
        velocity.y *= 0.98
        
        // Update position
        var newPosition = CGPoint(
            x: ballPosition.x + velocity.x,
            y: ballPosition.y + velocity.y
        )
        
        // Keep ball on screen
        let halfBall = ballSize / 2
        newPosition.x = max(halfBall, min(screenWidth - halfBall, newPosition.x))
        newPosition.y = max(halfBall, min(screenHeight - halfBall, newPosition.y))
        
        // Check wall collisions
        let ballRect = CGRect(x: newPosition.x - halfBall, y: newPosition.y - halfBall, width: ballSize, height: ballSize)
        
        for wall in mazeWalls {
            if ballRect.intersects(wall.rect) {
                // Simple collision response - stop movement
                velocity.x *= -0.3
                velocity.y *= -0.3
                return
            }
        }
        
        ballPosition = newPosition
        
        // Check if reached goal
        let goalRect = CGRect(x: screenWidth - 90, y: screenHeight - 190, width: 80, height: 80)
        if ballRect.intersects(goalRect) && !hasWon {
            hasWon = true
            winGame()
        }
    }
    
    private func winGame() {
        stopGame()
        
        // Update best time
        if bestTime == nil || elapsedTime < bestTime! {
            bestTime = elapsedTime
        }
        
        gameState = .won
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func generateNewMaze() {
        let w = screenWidth
        let h = screenHeight
        let wallThickness: CGFloat = 15
        
        var walls: [Wall] = []
        
        // Border walls (always present)
        walls.append(Wall(rect: CGRect(x: 0, y: 0, width: w, height: wallThickness))) // Top
        walls.append(Wall(rect: CGRect(x: 0, y: h - wallThickness, width: w, height: wallThickness))) // Bottom
        walls.append(Wall(rect: CGRect(x: 0, y: 0, width: wallThickness, height: h))) // Left
        walls.append(Wall(rect: CGRect(x: w - wallThickness, y: 0, width: wallThickness, height: h))) // Right
        
        // Maze interior walls (simple zigzag pattern) - same every time
        walls.append(Wall(rect: CGRect(x: w * 0.3, y: 150, width: wallThickness, height: 200)))
        walls.append(Wall(rect: CGRect(x: w * 0.3, y: 150, width: w * 0.4, height: wallThickness)))
        
        walls.append(Wall(rect: CGRect(x: w * 0.6, y: 250, width: wallThickness, height: 200)))
        walls.append(Wall(rect: CGRect(x: w * 0.2, y: 450, width: w * 0.4, height: wallThickness)))
        
        walls.append(Wall(rect: CGRect(x: w * 0.2, y: 450, width: wallThickness, height: 200)))
        walls.append(Wall(rect: CGRect(x: w * 0.2, y: 650, width: w * 0.5, height: wallThickness)))
        
        walls.append(Wall(rect: CGRect(x: w * 0.65, y: 550, width: wallThickness, height: 150)))
        
        mazeWalls = walls
    }
}

#Preview {
    MazeBallView()
}

