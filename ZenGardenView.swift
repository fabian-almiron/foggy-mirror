//
//  ZenGardenView.swift
//  Foggy Mirror
//
//  Zen garden raking experience
//

import SwiftUI

struct Rock: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var emoji: String
}

struct SandGrain: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let isLight: Bool
}

struct ZenGardenView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var rakePaths: [Path] = []
    @State private var currentPath = Path()
    @State private var rocks: [Rock] = []
    @State private var sandGrains: [SandGrain] = []
    @State private var rakeSize: Double = 10.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sand background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.93, green: 0.87, blue: 0.73),
                        Color(red: 0.90, green: 0.84, blue: 0.70),
                        Color(red: 0.88, green: 0.82, blue: 0.68)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Dense visible sand texture
                Canvas { context, size in
                    // Create a dense grid of visible texture dots
                    let spacing: CGFloat = 3
                    let cols = Int(size.width / spacing)
                    let rows = Int(size.height / spacing)
                    
                    for row in 0..<rows {
                        for col in 0..<cols {
                            // Add random variation to position
                            let x = CGFloat(col) * spacing + CGFloat.random(in: -1...1)
                            let y = CGFloat(row) * spacing + CGFloat.random(in: -1...1)
                            
                            // Random dot size and brightness
                            let dotSize = CGFloat.random(in: 0.5...2.5)
                            let brightness = Double.random(in: 0...1)
                            
                            let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                            
                            // Mix of lighter and darker grains
                            let color: Color
                            if brightness > 0.5 {
                                color = Color.white.opacity(Double.random(in: 0.2...0.5))
                            } else {
                                color = Color(red: 0.6, green: 0.5, blue: 0.4).opacity(Double.random(in: 0.2...0.4))
                            }
                            
                            context.fill(Path(ellipseIn: rect), with: .color(color))
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Depth overlay
                Rectangle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.black.opacity(0.12)
                            ]),
                            center: .center,
                            startRadius: 100,
                            endRadius: 500
                        )
                    )
                    .ignoresSafeArea()
                
                // Rake patterns in sand
                Canvas { context, size in
                    for path in rakePaths {
                        // Draw rake lines (3 parallel lines for rake tines)
                        let spacing = rakeSize / 2
                        for offset in [-spacing, 0.0, spacing] {
                            var offsetPath = path
                            offsetPath = offsetPath.offsetBy(dx: offset, dy: offset)
                            
                            context.stroke(
                                offsetPath,
                                with: .color(Color(red: 0.75, green: 0.68, blue: 0.55).opacity(0.6)),
                                style: StrokeStyle(lineWidth: rakeSize / 5, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                    
                    // Current path being drawn
                    if !currentPath.isEmpty {
                        let spacing = rakeSize / 2
                        for offset in [-spacing, 0.0, spacing] {
                            var offsetPath = currentPath
                            offsetPath = offsetPath.offsetBy(dx: offset, dy: offset)
                            
                            context.stroke(
                                offsetPath,
                                with: .color(Color(red: 0.75, green: 0.68, blue: 0.55).opacity(0.6)),
                                style: StrokeStyle(lineWidth: rakeSize / 5, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                }
                
                // Rocks and gnome
                ForEach(rocks) { rock in
                    Text(rock.emoji)
                        .font(.system(size: rock.size))
                        .position(rock.position)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2)
                }
                
                // Drawing gesture layer
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let point = value.location
                                if currentPath.isEmpty {
                                    currentPath.move(to: point)
                                } else {
                                    currentPath.addLine(to: point)
                                }
                            }
                            .onEnded { _ in
                                if !currentPath.isEmpty {
                                    rakePaths.append(currentPath)
                                    currentPath = Path()
                                }
                            }
                    )
                
                // UI Overlay
                VStack {
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
                            .background(Color.brown.opacity(0.6))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        // Clear button
                        Button(action: {
                            withAnimation {
                                rakePaths.removeAll()
                                currentPath = Path()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Clear")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.brown.opacity(0.6))
                            .clipShape(Capsule())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Rake size slider - no text
                    HStack(spacing: 15) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(Color.brown.opacity(0.6))
                        
                        Slider(value: $rakeSize, in: 5...30)
                            .accentColor(Color(red: 0.7, green: 0.6, blue: 0.5))
                            .frame(width: 200)
                        
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(Color.brown.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: Color.brown.opacity(0.2), radius: 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            setupGarden()
            generateSandTexture()
        }
    }
    
    private func setupGarden() {
        // Add a rake laying in the sand
        rocks = [
            Rock(position: CGPoint(x: 200, y: 300), size: 80, emoji: "🪺")
        ]
    }
    
    private func generateSandTexture() {
        // Generate persistent sand grain texture
        var grains: [SandGrain] = []
        
        // Create dense sand grains across a normalized space
        for _ in 0..<5000 {
            let grain = SandGrain(
                position: CGPoint(
                    x: CGFloat.random(in: 0...400),
                    y: CGFloat.random(in: 0...900)
                ),
                size: CGFloat.random(in: 1.0...3.0),
                opacity: Double.random(in: 0.1...0.35),
                isLight: Bool.random()
            )
            grains.append(grain)
        }
        
        sandGrains = grains
    }
}

#Preview {
    ZenGardenView()
}

