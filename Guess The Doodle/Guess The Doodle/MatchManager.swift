//
//  MatchManager.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import Foundation
import GameKit
import PencilKit
import Combine

class MatchManager: NSObject, ObservableObject {
    @Published var inGame: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isTimerKeeper: Bool = false
    @Published var authenicationState: PlayerAuthState = .authenticating
    
    @Published var currentlyDrawing: Bool = false
    @Published var drawPrompt = ""
    @Published var passGuesses: [PastGuess] = []
    
    @Published var score = 0
    @Published var remainingTime = maxTimeRemaining {
        willSet {
            if isTimerKeeper {
                let structureValue = CommunicationStructure(
                    signaature: .timer,
                    UUIDKey: nil, time: newValue, guess: nil, drawing: nil
                )
                send(structureValue)
                if newValue < 0 {
                    gameOver()
                }
            }
        }
    }
    
    @Published var lastRecivedDrawing: PKDrawing = PKDrawing()
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer = GKLocalPlayer.local
    
    var playerUUIDKey = UUID().uuidString
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    private var cancellable: AnyCancellable?

    override init() {
        super.init()
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                guard self.isTimerKeeper else { return }
                self.remainingTime -= 1
            }
        
        // 参加依頼を受付できるようにする
        GKLocalPlayer.local.register(self)
    }
    
    func authenticationUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] viewController, error in
            if let viewController = viewController {
                rootViewController?.present(viewController, animated: true)
                
                return
            }
            if let error = error {
                authenicationState = .error
                errorLog(error.localizedDescription)
                
                return
            }
            
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenicationState = .restricted
                } else {
                    authenicationState = .authenticated
                }
            } else {
                authenicationState = .unauthenticated
            }
        }
    }
    
    func startMatchMaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        
        rootViewController?.present(matchmakerViewController!, animated: true)
    }
    
    func startMatch(match: GKMatch) {
        self.match = match
        self.match?.delegate = self
        otherPlayer = self.match?.players.first
        drawPrompt = everydayObjects.randomElement()!
        
        let structureValue = CommunicationStructure(
            signaature: .begin,
            UUIDKey: playerUUIDKey, time: nil, guess: nil, drawing: nil
        )
        send(structureValue)
    }
    func swapRole() {
        score += 1
        currentlyDrawing = !currentlyDrawing
        drawPrompt = everydayObjects.randomElement()!
    }
    
    func gameOver() {
        isGameOver = true
        let structureValue = CommunicationStructure(
            signaature: .gameOver,
            UUIDKey: nil, time: nil, guess: nil, drawing: nil
        )
        send(structureValue)
        match?.disconnect()
    }
    
    func resetGame() {
        Task { @MainActor [self] in
            isGameOver = false
            inGame  = false
            drawPrompt = ""
            score = 0
            remainingTime = maxTimeRemaining
            lastRecivedDrawing = PKDrawing()
        }
        
        isTimerKeeper = false
        match?.delegate = nil
        match = nil
        otherPlayer = nil
        passGuesses.removeAll()
        playerUUIDKey = UUID().uuidString
    }
    
    func receviedStructure(_ structure: CommunicationStructure) {
        switch structure.signaature {
        case .begin:
            guard let UUIDKey = structure.UUIDKey else {
                return
            }
            
            if playerUUIDKey == UUIDKey {
                playerUUIDKey = UUID().uuidString
                
                let structureValue = CommunicationStructure(
                    signaature: .begin,
                    UUIDKey: playerUUIDKey, time: nil, guess: nil, drawing: nil
                )
                send(structureValue)
                break
            }
            
            currentlyDrawing = playerUUIDKey < UUIDKey
            inGame = true
            isTimerKeeper = currentlyDrawing
            
        case .timer:
            remainingTime = structure.time ?? 0
            
        case .guess:
            guard let guess = structure.guess else {
                return
            }
            var guessCorrect = false
            if guess.lowercased() == drawPrompt {
                let structureValue = CommunicationStructure(
                    signaature: .correct,
                    UUIDKey: nil, time: nil, guess: guess, drawing: nil
                )
                send(structureValue)
                swapRole()
                guessCorrect = true
            } else {
                let structureValue = CommunicationStructure(
                    signaature: .incorrect,
                    UUIDKey: nil, time: nil, guess: guess, drawing: nil
                )
                send(structureValue)
            }
            
            appendPastGuess(guess: guess, correct: guessCorrect)
            
        case .correct:
            guard let guess = structure.guess else {
                return
            }
            swapRole()
            appendPastGuess(guess: guess, correct: true)
            
        case .incorrect:
            guard let guess = structure.guess else {
                return
            }
            appendPastGuess(guess: guess, correct: false)
            
        case .gameOver:
            isGameOver = true
            
        case .drawing:
            guard let drawing = structure.drawing else {
                return
            }
            do {
                lastRecivedDrawing = try PKDrawing(data: drawing)
            } catch {
                errorLog(error)
            }
        }
    }
    
    func appendPastGuess(guess: String, correct: Bool) {
        passGuesses.append(PastGuess(message: "\(guess)\(correct ? " was correct!" : "")", correct: correct))
    }
}
