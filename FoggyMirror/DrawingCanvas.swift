import SwiftUI

// Drawing mask that reveals camera underneath
struct DrawingMask: View {
    @Binding var paths: [Path]
    @Binding var currentPath: Path
    
    var body: some View {
        Canvas { context, size in
            // Start with full white (show fog everywhere)
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.white)
            )
            
            // Cut out drawn paths (hide fog where user draws)
            for path in paths {
                context.blendMode = .destinationOut
                context.stroke(
                    path,
                    with: .color(.black),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
            }
            
            // Draw current path being drawn (for immediate feedback)
            if !currentPath.isEmpty {
                context.blendMode = .destinationOut
                context.stroke(
                    currentPath,
                    with: .color(.black),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

// Gesture layer for capturing drawing input
struct DrawingGestureLayer: View {
    @Binding var paths: [Path]
    @Binding var currentPath: Path
    @Binding var fogOpacity: Double
    
    var body: some View {
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
                            paths.append(currentPath)
                            currentPath = Path()
                        }
                    }
            )
            .allowsHitTesting(fogOpacity > 0.1)
    }
}


struct DrawingCanvas: View {
    @Binding var fogOpacity: Double
    @State private var currentPath = Path()
    @State private var paths: [Path] = []
    @State private var lineWidth: CGFloat = 40.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Drawing paths visualization (shows where user has drawn)
                ForEach(Array(paths.enumerated()), id: \.offset) { index, path in
                    path.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .fill(Color.clear)
                        .background(Color.black.opacity(0.01))
                }
                
                // Current path being drawn
                if !currentPath.isEmpty {
                    currentPath.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .fill(Color.clear)
                        .background(Color.black.opacity(0.01))
                }
                
                // Gesture overlay
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
                                paths.append(currentPath)
                                currentPath = Path()
                            }
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .allowsHitTesting(fogOpacity > 0.1) // Allow drawing when there's some fog
    }
    
    // Function to clear all drawings
    func clearDrawings() {
        paths.removeAll()
        currentPath = Path()
    }
}

struct FogEffect: View {
    @Binding var opacity: Double
    
    var body: some View {
        ZStack {
            // Base fog layer with moisture texture
            Rectangle()
                .fill(Color.white)
                .opacity(opacity * 0.85)
                .blur(radius: 20)
            
            // Subtle moisture texture overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.gray.opacity(0.1),
                            Color.white.opacity(0.3),
                            Color.gray.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(opacity * 0.5)
                .blur(radius: 10)
            
            // Additional soft gradient layer
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.9),
                            Color.gray.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .opacity(opacity)
                .blur(radius: 25)
        }
        .allowsHitTesting(false)
    }
}



// Simple mirror frame overlay
struct SimpleMirrorFrame: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer frame - metallic silver
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.8),
                                Color.white.opacity(0.9),
                                Color.gray.opacity(0.6),
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 12
                    )
                
                // Inner frame detail
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.gray.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .padding(8)
                
                // Corner highlights for depth
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 8, height: 8)
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 8, height: 8)
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(16)
            }
            .padding(20)
        }
        .allowsHitTesting(false)
    }
}





