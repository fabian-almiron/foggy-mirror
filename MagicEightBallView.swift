//
//  MagicEightBallView.swift
//  Foggy Mirror
//
//  Magic Eight Ball shake experience
//

import SwiftUI
import CoreMotion

struct MagicEightBallView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var motionManager = ShakeDetector()
    @State private var currentAnswer = ""
    @State private var showAnswer = false
    @State private var isShaking = false
    
    let answers = [
        "It is certain",
        "Without a doubt",
        "Yes definitely",
        "You may rely on it",
        "As I see it, yes",
        "Most likely",
        "Outlook good",
        "Yes",
        "Signs point to yes",
        "Reply hazy, try again",
        "Ask again later",
        "Better not tell you now",
        "Cannot predict now",
        "Concentrate and ask again",
        "Don't count on it",
        "My reply is no",
        "My sources say no",
        "Outlook not so good",
        "Very doubtful"
    ]
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Magic Eight Ball
                ZStack {
                    // Outer black ball with shine
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.black,
                                    Color(white: 0.1),
                                    Color.black
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                        )
                        .shadow(color: Color.white.opacity(0.2), radius: 20, x: -30, y: -30)
                        .shadow(color: Color.black.opacity(0.8), radius: 30, x: 20, y: 20)
                        .rotation3DEffect(
                            .degrees(isShaking ? 5 : 0),
                            axis: (x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1), z: 0)
                        )
                    
                    // Number 8
                    if !showAnswer {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.1, green: 0.1, blue: 0.3),
                                            Color(red: 0.05, green: 0.05, blue: 0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text("8")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Answer window
                    if showAnswer {
                        ZStack {
                            // Triangle window background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.1, green: 0.1, blue: 0.3),
                                            Color(red: 0.05, green: 0.05, blue: 0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 150, height: 150)
                            
                            // Answer text
                            Text(currentAnswer)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(20)
                                .frame(width: 130)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showAnswer)
                .animation(.easeInOut(duration: 0.1), value: isShaking)
                
                Spacer()
                
                // Instructions
                if !showAnswer {
                    Text("Shake to reveal your answer")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            motionManager.onShake = {
                handleShake()
            }
            motionManager.startDetecting()
        }
        .onDisappear {
            motionManager.stopDetecting()
        }
    }
    
    private func handleShake() {
        // Trigger shake animation
        isShaking = true
        
        // Hide answer immediately
        showAnswer = false
        
        // Short delay for shake effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isShaking = false
        }
        
        // Show new answer after shake
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentAnswer = answers.randomElement() ?? "Ask again"
            withAnimation {
                showAnswer = true
            }
        }
        
        // Auto hide after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation {
                showAnswer = false
            }
        }
    }
}

// Shake detector using CoreMotion
class ShakeDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private let threshold: Double = 2.5
    var onShake: (() -> Void)?
    
    func startDetecting() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            let acceleration = data.acceleration
            let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
            
            if magnitude > self.threshold {
                self.onShake?()
            }
        }
    }
    
    func stopDetecting() {
        motionManager.stopAccelerometerUpdates()
    }
}

#Preview {
    MagicEightBallView()
}

