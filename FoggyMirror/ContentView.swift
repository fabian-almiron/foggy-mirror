import SwiftUI

enum FrameColor: String, CaseIterable {
    case gold = "Gold"
    case copper = "Copper"
    case rainbow = "Rainbow"
    case silver = "Silver"
    case emerald = "Emerald"
    
    var gradient: [Color] {
        switch self {
        case .gold:
            return [
                Color(red: 0.85, green: 0.65, blue: 0.13),
                Color(red: 1.0, green: 0.84, blue: 0.0),
                Color(red: 0.85, green: 0.65, blue: 0.13),
                Color(red: 1.0, green: 0.84, blue: 0.0),
                Color(red: 0.85, green: 0.65, blue: 0.13)
            ]
        case .silver:
            return [
                Color(red: 0.7, green: 0.7, blue: 0.7),
                Color(red: 0.95, green: 0.95, blue: 0.95),
                Color(red: 0.7, green: 0.7, blue: 0.7),
                Color(red: 0.95, green: 0.95, blue: 0.95),
                Color(red: 0.7, green: 0.7, blue: 0.7)
            ]
        case .emerald:
            return [
                Color(red: 0.2, green: 0.6, blue: 0.4),
                Color(red: 0.3, green: 0.9, blue: 0.6),
                Color(red: 0.2, green: 0.6, blue: 0.4),
                Color(red: 0.3, green: 0.9, blue: 0.6),
                Color(red: 0.2, green: 0.6, blue: 0.4)
            ]
        case .copper:
            return [
                Color(red: 0.72, green: 0.45, blue: 0.20),
                Color(red: 0.95, green: 0.64, blue: 0.38),
                Color(red: 0.72, green: 0.45, blue: 0.20),
                Color(red: 0.95, green: 0.64, blue: 0.38),
                Color(red: 0.72, green: 0.45, blue: 0.20)
            ]
        case .rainbow:
            return [
                Color.red,
                Color.orange,
                Color.yellow,
                Color.green,
                Color.blue,
                Color.purple
            ]
        }
    }
    
    var shadowColor: Color {
        gradient[1].opacity(0.3)
    }
}

struct ContentView: View {
    @State private var showMirror = false
    @State private var showZenGarden = false
    @State private var showEightBall = false
    @State private var showMazeBall = false
    @State private var showCircleTap = false
    
    var body: some View {
        ZStack {
            // Cute gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.85, blue: 1.0),
                    Color(red: 0.85, green: 0.95, blue: 1.0),
                    Color(red: 0.95, green: 0.90, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                // Title
                Text("r u bored?")
                    .font(.custom("Chalkboard SE", size: 48))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.8),
                                Color(red: 0.4, green: 0.6, blue: 0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                .padding(.top, 40)
                
                // Experience cards - 3 in a row
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        // Foggy Mirror Card
                        VStack(spacing: 12) {
                            Text("🪞")
                                .font(.system(size: 45))
                            
                            Text("Foggy Mirror")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            
                            Button(action: {
                                showMirror = true
                            }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                                Color(red: 0.4, green: 0.6, blue: 0.95)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .shadow(color: Color.purple.opacity(0.2), radius: 8)
                        
                        // Zen Garden Card
                        VStack(spacing: 12) {
                            Text("🪨")
                                .font(.system(size: 45))
                            
                            Text("Zen Garden")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            
                            Button(action: {
                                showZenGarden = true
                            }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.7, green: 0.6, blue: 0.5),
                                                Color(red: 0.6, green: 0.5, blue: 0.4)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .shadow(color: Color.brown.opacity(0.2), radius: 8)
                        
                        // Magic Eight Ball Card
                        VStack(spacing: 12) {
                            Text("🎱")
                                .font(.system(size: 45))
                            
                            Text("Eight Ball")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            
                            Button(action: {
                                showEightBall = true
                            }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color.black,
                                                Color(white: 0.2)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 8)
                    }
                    
                    // Add Maze Ball below
                    HStack {
                        Spacer()
                        
                        // Maze Ball Card
                        VStack(spacing: 12) {
                            Text("🎯")
                                .font(.system(size: 45))
                            
                            Text("Maze Ball")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            
                            Button(action: {
                                showMazeBall = true
                            }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.7, blue: 0.5),
                                                Color(red: 0.2, green: 0.5, blue: 0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                        }
                        .frame(width: 105)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .shadow(color: Color.blue.opacity(0.2), radius: 8)
                        
                        // Balloon Pop Card
                        VStack(spacing: 12) {
                            Text("🎈")
                                .font(.system(size: 45))
                            
                            Text("Balloon Pop")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.7))
                            
                            Button(action: {
                                showCircleTap = true
                            }) {
                                Text("Start")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.8, green: 0.3, blue: 0.5),
                                                Color(red: 0.6, green: 0.4, blue: 0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                            }
                        }
                        .frame(width: 105)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .shadow(color: Color.pink.opacity(0.2), radius: 8)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showMirror) {
            MirrorView()
        }
        .fullScreenCover(isPresented: $showZenGarden) {
            ZenGardenView()
        }
        .fullScreenCover(isPresented: $showEightBall) {
            MagicEightBallView()
        }
        .fullScreenCover(isPresented: $showMazeBall) {
            MazeBallView()
        }
        .fullScreenCover(isPresented: $showCircleTap) {
            CircleTapView()
        }
    }
}

#Preview {
    ContentView()
}
