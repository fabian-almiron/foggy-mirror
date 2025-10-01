//
//  RhythmTapView.swift
//  Foggy Mirror
//
//  Piano tiles-style rhythm tap game
//

import SwiftUI
import AVFoundation

// MARK: - Tile Model
struct FallingTile: Identifiable {
    let id = UUID()
    let lane: Int
    var y: CGFloat
    let spawnTime: Date
}

// MARK: - Rhythm Tap Game View
struct RhythmTapView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var tiles: [FallingTile] = []
    @State private var tappedTiles: Set<UUID> = []
    @State private var missedTiles: Set<UUID> = []
    @State private var spawnTimer: Timer?
    @State private var updateTimer: Timer?
    @State private var bestScore: Int? = nil
    @State private var combo = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timeRemaining = 30
    @State private var gameTimer: Timer?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let numLanes = 4
    let tileHeight: CGFloat = 120
    let tapZoneHeight: CGFloat = 150
    let fallSpeed: CGFloat = 6.0
    
    enum GameState {
        case ready
        case playing
        case gameOver
    }
    
    var laneWidth: CGFloat {
        screenWidth / CGFloat(numLanes)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if gameState == .ready {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🎹 Rhythm Tap 🎹")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    
                    VStack(spacing: 15) {
                        Text("Tap tiles as they reach the bottom!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 40)
                        
                        Text("30 seconds • Don't miss or tap empty lanes!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if let best = bestScore {
                            Text("Best Score: \(best)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
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
                                    colors: [Color(red: 0.6, green: 0.4, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                    }
                }
                
            } else if gameState == .playing {
                VStack(spacing: 0) {
                    // Top bar with score, combo, and timer
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Score: \(score)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            if combo > 1 {
                                Text("Combo: \(combo)x")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                            }
                        }
                        
                        Spacer()
                        
                        Text("⏱️ \(timeRemaining)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining <= 5 ? .red : .white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    
                    Spacer()
                    
                    // Tap zone indicator at bottom
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: tapZoneHeight)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        )
                }
                
                // Lane dividers
                HStack(spacing: 0) {
                    ForEach(0..<numLanes, id: \.self) { lane in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: laneWidth)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Falling tiles
                ForEach(tiles) { tile in
                    let isTapped = tappedTiles.contains(tile.id)
                    let isMissed = missedTiles.contains(tile.id)
                    
                    if !isTapped && !isMissed {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                        Color(red: 0.4, green: 0.6, blue: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: laneWidth - 10, height: tileHeight)
                            .cornerRadius(10)
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                            .position(
                                x: (CGFloat(tile.lane) + 0.5) * laneWidth,
                                y: tile.y
                            )
                    }
                }
                
                // Tap zones for each lane
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(0..<numLanes, id: \.self) { lane in
                            Color.clear
                                .frame(width: laneWidth, height: tapZoneHeight + 100)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    tapLane(lane)
                                }
                        }
                    }
                }
                
            } else if gameState == .gameOver {
                // Game Over Screen
                VStack(spacing: 30) {
                    Text("Game Over!")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    
                    VStack(spacing: 10) {
                        Text("Final Score")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                        
                        if let best = bestScore, score >= best {
                            Text("🏆 New Best Score!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
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
                                        colors: [Color(red: 0.6, green: 0.4, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 1.0)],
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
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                .padding(.horizontal, 35)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.6, green: 0.4, blue: 0.9), lineWidth: 2)
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
        combo = 0
        timeRemaining = 30
        tiles = []
        tappedTiles = []
        missedTiles = []
        gameState = .playing
        
        // Start game timer (countdown)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
        
        // Start spawn timer (new tile every 0.6 seconds)
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            spawnTile()
        }
        
        // Start update timer (move tiles down and check for misses)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateTiles()
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
        notification.notificationOccurred(.error)
    }
    
    private func spawnTile() {
        let randomLane = Int.random(in: 0..<numLanes)
        
        let newTile = FallingTile(
            lane: randomLane,
            y: -tileHeight,
            spawnTime: Date()
        )
        
        tiles.append(newTile)
    }
    
    private func updateTiles() {
        for index in tiles.indices {
            tiles[index].y += fallSpeed
        }
        
        // Check for missed tiles (passed the tap zone)
        if timeRemaining > 0 {
            for tile in tiles {
                if !tappedTiles.contains(tile.id) && !missedTiles.contains(tile.id) {
                    if tile.y > screenHeight - tapZoneHeight + tileHeight {
                        // Missed!
                        missedTiles.insert(tile.id)
                        combo = 0
                        endGame()
                    }
                }
            }
        }
        
        // Remove tiles that are off screen
        tiles.removeAll { tile in
            tile.y > screenHeight + tileHeight
        }
    }
    
    private func tapLane(_ lane: Int) {
        // Find tiles in this lane within the tap zone
        let tapZoneTop = screenHeight - tapZoneHeight - tileHeight
        let tapZoneBottom = screenHeight - tapZoneHeight + tileHeight
        
        var tappedATile = false
        
        for tile in tiles {
            if tile.lane == lane &&
               !tappedTiles.contains(tile.id) &&
               !missedTiles.contains(tile.id) &&
               tile.y >= tapZoneTop &&
               tile.y <= tapZoneBottom {
                // Hit!
                tappedTiles.insert(tile.id)
                score += 1
                combo += 1
                tappedATile = true
                
                // Success haptic
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                break
            }
        }
        
        // If tapped empty lane (no tile), end game
        if !tappedATile {
            // Check if there's ANY tile in the lane that hasn't been tapped
            let hasUntappedTileInLane = tiles.contains { tile in
                tile.lane == lane && !tappedTiles.contains(tile.id) && !missedTiles.contains(tile.id)
            }
            
            if !hasUntappedTileInLane {
                // Tapped empty lane - game over
                combo = 0
                endGame()
            }
        }
    }
}

#Preview {
    RhythmTapView()
}

