//
//  MatchManager+GKMatchDelegate.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import Foundation
import GameKit
import PencilKit

extension MatchManager: GKMatchDelegate {    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let content = String(decoding: data, as: UTF8.self)
        
        if content.starts(with: "\(communicationStringPrefix):") {
            let message = content.replacing("\(communicationStringPrefix):", with: "")
            let messageSplit = message.split(separator: ":")
            let messagePrefix = String(messageSplit.first ?? "") 
            guard let signature = CommunicationSignature(rawValue: messagePrefix) else { return }
            let parameter = String(messageSplit.last ?? "")
            
            recevedString(signature, parameter: parameter)
        } else {
            do {
                lastRecivedDrawing = try PKDrawing(data: data)
            } catch {
                errorLog(error)
            }
        }
    }
    
    func sendCommand(_ signature: CommunicationSignature, parameter: String) {
        sendString("\(signature.rawValue):\(parameter)")
    }
    
    func sendDrawing(_ drawing: PKDrawing) {
        sendData(drawing.dataRepresentation(), mode: .reliable)
    }
    
    private func sendString(_ message: String) {
        guard let encoded = "\(communicationStringPrefix):\(message)".data(using: .utf8) else { return }
        sendData(encoded, mode: .reliable)
    }
    
    private func sendData(_ data: Data, mode: GKMatch.SendDataMode) {
        do {
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            errorLog(error)
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        guard state == .disconnected && !isGameOver else { return }
        let alert = UIAlertController(title: "プレイヤーの中断", message: "プレーヤーがゲームを中断しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.match?.disconnect()
        })
        Task { @MainActor in
            self.resetGame()
            self.rootViewController?.present(alert, animated: true)
        }
    }
}
