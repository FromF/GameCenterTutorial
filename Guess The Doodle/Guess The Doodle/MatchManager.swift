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
                sendCommand(.timer, parameter: "\(newValue)")
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
        
        sendCommand(.begin, parameter: playerUUIDKey)
    }
    func swapRole() {
        score += 1
        currentlyDrawing = !currentlyDrawing
        drawPrompt = everydayObjects.randomElement()!
    }
    
    func gameOver() {
        isGameOver = true
        sendCommand(.gameOver, parameter: "")
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
    
    func recevedString(_ signature: CommunicationSignature, parameter: String) {
        switch signature {
        case .begin:
            if playerUUIDKey == parameter {
                playerUUIDKey = UUID().uuidString
                sendCommand(.begin, parameter: playerUUIDKey)
                break
            }
            
            currentlyDrawing = playerUUIDKey < parameter
            inGame = true
            isTimerKeeper = currentlyDrawing
            
        case .timer:
            remainingTime = Int(parameter) ?? 0
            
        case .guess:
            var guessCorrect = false
            if parameter.lowercased() == drawPrompt {
                sendCommand(.correct, parameter: parameter)
                swapRole()
                guessCorrect = true
            } else {
                sendCommand(.incorrect, parameter: parameter)
            }
            
            appendPastGuess(guess: parameter, correct: guessCorrect)
            
        case .correct:
            swapRole()
            appendPastGuess(guess: parameter, correct: true)
            
        case .incorrect:
            appendPastGuess(guess: parameter, correct: false)
            
        case .gameOver:
            isGameOver = true
        }
    }
    
    func appendPastGuess(guess: String, correct: Bool) {
        passGuesses.append(PastGuess(message: "\(guess)\(correct ? " was correct!" : "")", correct: correct))
    }
}
