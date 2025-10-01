import SwiftUI
import AVFoundation

struct MirrorView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var captureSession: AVCaptureSession?
    @State private var fogOpacity: Double = 0.0
    @State private var showingPermissionAlert = false
    @State private var fadeTimer: Timer?
    @State private var drawnPaths: [Path] = []
    @State private var currentPath = Path()
    @State private var selectedFrameColor: FrameColor = .gold
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - dark elegant color
                Color.black
                    .ignoresSafeArea()
                
                // Mirror with gold frame
                VStack {
                    Spacer()
                    
                    ZStack {
                        // Camera layer
                        CameraView(session: $captureSession)
                        
                        // Fog + Drawing layer
                        ZStack {
                            // Fog layer with drawing mask
                            FogEffect(opacity: $fogOpacity)
                                .mask {
                                    Canvas { context, size in
                                        // Start with full white (show fog everywhere)
                                        context.fill(
                                            Path(CGRect(origin: .zero, size: size)),
                                            with: .color(.white)
                                        )
                                        
                                        // Cut out drawn paths (hide fog where user draws)
                                        context.blendMode = .destinationOut
                                        for path in drawnPaths {
                                            context.stroke(
                                                path,
                                                with: .color(.black),
                                                style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                                            )
                                        }
                                        
                                        // Draw current path being drawn
                                        if !currentPath.isEmpty {
                                            context.stroke(
                                                currentPath,
                                                with: .color(.black),
                                                style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                                            )
                                        }
                                    }
                                }
                            
                            // Invisible gesture layer for drawing
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
                                                drawnPaths.append(currentPath)
                                                currentPath = Path()
                                            }
                                        }
                                )
                                .allowsHitTesting(fogOpacity > 0.1)
                        }
                    }
                    .frame(width: min(geometry.size.width - 40, 400),
                           height: min(geometry.size.height * 0.75, 600))
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .overlay(
                        // Main frame border with selected color
                        RoundedRectangle(cornerRadius: 35)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: selectedFrameColor.gradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 16
                            )
                    )
                    .overlay(
                        // Inner decorative border
                        RoundedRectangle(cornerRadius: 35)
                            .strokeBorder(
                                Color(red: 1.0, green: 0.9, blue: 0.4).opacity(0.6),
                                lineWidth: 2
                            )
                            .padding(6)
                    )
                    .overlay(
                        // Corner embellishments
                        ZStack {
                            // Top left
                            VStack {
                                HStack {
                                    Text("✨")
                                        .font(.system(size: 20))
                                        .offset(x: -8, y: -8)
                                    Spacer()
                                }
                                Spacer()
                            }
                            
                            // Top right
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("✨")
                                        .font(.system(size: 20))
                                        .offset(x: 8, y: -8)
                                }
                                Spacer()
                            }
                            
                            // Bottom left
                            VStack {
                                Spacer()
                                HStack {
                                    Text("✨")
                                        .font(.system(size: 20))
                                        .offset(x: -8, y: 8)
                                    Spacer()
                                }
                            }
                            
                            // Bottom right
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("✨")
                                        .font(.system(size: 20))
                                        .offset(x: 8, y: 8)
                                }
                            }
                            
                            // Top center decoration
                            VStack {
                                Text("🌟")
                                    .font(.system(size: 24))
                                    .offset(y: -12)
                                Spacer()
                            }
                            
                            // Bottom center decoration
                            VStack {
                                Spacer()
                                Text("💫")
                                    .font(.system(size: 24))
                                    .offset(y: 12)
                            }
                        }
                        .allowsHitTesting(false)
                    )
                    .shadow(color: selectedFrameColor.shadowColor, radius: 20, x: 0, y: 0)
                    
                    Spacer()
                }
                
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
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Frame color selector
                    VStack(spacing: 8) {
                        Text("Frame Color")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(FrameColor.allCases, id: \.self) { color in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: color.gradient),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedFrameColor == color ? 3 : 0)
                                    )
                                    .shadow(color: color.shadowColor, radius: 6)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedFrameColor = color
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            audioManager.startListening()
        }
        .onDisappear {
            audioManager.stopListening()
            captureSession?.stopRunning()
        }
        .onChange(of: audioManager.audioLevel) { oldValue, newValue in
            if audioManager.isBreathing {
                addFog()
            }
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings to use blow detection.")
        }
    }
    
    private func addFog() {
        // Cancel previous fade timer
        fadeTimer?.invalidate()
        
        // Add fog gradually
        withAnimation(.easeOut(duration: 0.3)) {
            fogOpacity = min(fogOpacity + 0.15, 0.95)
        }
        
        // Start fade timer after 5 seconds (longer delay before fading)
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            startFogFade()
        }
    }
    
    private func startFogFade() {
        // Much slower fade - 10 seconds duration
        withAnimation(.easeInOut(duration: 10.0)) {
            fogOpacity = max(fogOpacity - 0.3, 0.0)
        }
    }
}

#Preview {
    MirrorView()
}
