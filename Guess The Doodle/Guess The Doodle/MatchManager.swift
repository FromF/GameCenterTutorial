//
//  MatchManager.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import Foundation

class MatchManager: ObservableObject {
    @Published var inGame: Bool = false
    @Published var isGameOver: Bool = false
    @Published var authenicationState: PlayerAuthState = .authenticating
    
    @Published var currentlyDrawing: Bool = false
    @Published var drawPrompt = ""
    @Published var PassGuesses: [PastGuess] = []
    
    @Published var score = 0
    @Published var remainingTime = maxTimeRemaining
    
}
