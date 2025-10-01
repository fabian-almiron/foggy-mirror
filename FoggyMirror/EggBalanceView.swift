//
//  EggBalanceView.swift
//  Foggy Mirror
//
//  Balance an egg by keeping your phone still
//

import SwiftUI
import CoreMotion

// MARK: - Motion Manager
class StillnessDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var tiltX: Double = 0
    @Published var tiltY: Double = 0
    @Published var movementIntensity: Double = 0
    
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.02
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            
            // Get rotation rate (how fast the device is moving)
            let rotationX = abs(motion.rotationRate.x)
            let rotationY = abs(motion.rotationRate.y)
            let rotationZ = abs(motion.rotationRate.z)
            
            // Calculate overall movement intensity
            let intensity = (rotationX + rotationY + rotationZ) / 3.0
            
            self?.movementIntensity = intensity
            self?.tiltX = motion.gravity.x
            self?.tiltY = motion.gravity.y
        }
    }
    
    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Egg Balance Game View
struct EggBalanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var stillnessDetector = StillnessDetector()
    @State private var gameState: GameState = .ready
    @State private var timeBalanced: Double = 0
    @State private var gameTimer: Timer?
    @State private var eggTiltX: CGFloat = 0
    @State private var eggTiltY: CGFloat = 0
    @State private var wobbleAmount: CGFloat = 0
    @State private var isBroken = false
    @State private var bestTime: Double? = nil
    @State private var sensitivity: Double = 1.0
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let maxTiltBeforeBreak: Double = 0.15
    
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
                    Color(red: 0.95, green: 0.9, blue: 0.85),
                    Color(red: 0.9, green: 0.95, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🥚 Egg Balance 🥚")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                    
                    VStack(spacing: 15) {
                        Text("Keep your phone still to balance the egg!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        Text("Move = wobble • Too much movement = crack!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if let best = bestTime {
                            Text("Best Time: \(String(format: "%.1f", best))s")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
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
                                    colors: [Color(red: 0.8, green: 0.6, blue: 0.3), Color(red: 0.9, green: 0.7, blue: 0.4)],
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
                    // Timer at top
                    VStack(spacing: 5) {
                        Text("⏱️ \(String(format: "%.1f", timeBalanced))s")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                        
                        // Sensitivity indicator
                        Text("Sensitivity: \(String(format: "%.0f", sensitivity * 100))%")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Egg in center
                    ZStack {
                        if !isBroken {
                            // Intact egg
                            Text("🥚")
                                .font(.system(size: 120))
                                .rotationEffect(.degrees(Double(eggTiltX) * 30))
                                .offset(x: eggTiltX * 20, y: eggTiltY * 20)
                                .scaleEffect(1.0 + wobbleAmount * 0.2)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                                .animation(.spring(response: 0.3, dampingFraction: 0.3), value: wobbleAmount)
                        } else {
                            // Broken egg
                            VStack(spacing: -20) {
                                Text("🍳")
                                    .font(.system(size: 80))
                                Text("💔")
                                    .font(.system(size: 40))
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Spacer()
                    
                    // Movement indicator
                    VStack(spacing: 10) {
                        Text("Stability")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                
                                // Danger zone (red)
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.3), Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * min(CGFloat(stillnessDetector.movementIntensity * sensitivity), 1.0))
                            }
                        }
                        .frame(height: 30)
                        
                        Text(wobbleAmount > 0.7 ? "⚠️ Too much movement!" : "Keep still...")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(wobbleAmount > 0.7 ? .red : .secondary)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                
            } else if gameState == .gameOver {
                // Game Over Screen
                VStack(spacing: 30) {
                    Text("Egg Cracked!")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                    
                    Text("🍳")
                        .font(.system(size: 100))
                    
                    VStack(spacing: 10) {
                        Text("Balanced For")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.1f", timeBalanced))s")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                        
                        if let best = bestTime, timeBalanced >= best {
                            Text("🏆 New Best Time!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
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
                                        colors: [Color(red: 0.8, green: 0.6, blue: 0.3), Color(red: 0.9, green: 0.7, blue: 0.4)],
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
                                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.8, green: 0.6, blue: 0.3), lineWidth: 2)
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
            stillnessDetector.startTracking()
        }
        .onDisappear {
            stopGame()
            stillnessDetector.stopTracking()
        }
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        timeBalanced = 0
        sensitivity = 1.0
        eggTiltX = 0
        eggTiltY = 0
        wobbleAmount = 0
        isBroken = false
        gameState = .playing
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateGame()
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateGame() {
        // Increase time
        timeBalanced += 0.1
        
        // Gradually increase sensitivity (gets harder over time)
        sensitivity = 1.0 + (timeBalanced / 10.0) // +10% every second
        
        // Calculate wobble based on movement intensity and sensitivity
        let adjustedMovement = stillnessDetector.movementIntensity * sensitivity
        wobbleAmount = CGFloat(min(adjustedMovement, 1.5))
        
        // Update egg position based on device tilt
        eggTiltX = CGFloat(stillnessDetector.tiltX) * CGFloat(sensitivity) * 2
        eggTiltY = CGFloat(stillnessDetector.tiltY) * CGFloat(sensitivity) * 2
        
        // Check if egg should break
        if adjustedMovement > maxTiltBeforeBreak {
            breakEgg()
        }
    }
    
    private func breakEgg() {
        withAnimation {
            isBroken = true
        }
        
        stopGame()
        
        // Update best time
        if bestTime == nil || timeBalanced > bestTime! {
            bestTime = timeBalanced
        }
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
        
        // Wait a moment before showing game over
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gameState = .gameOver
        }
    }
}

#Preview {
    EggBalanceView()
}

