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
        do {
            let decoder = JSONDecoder()
            let receviedStructureValue = try decoder.decode(CommunicationStructure.self, from: data)
            receviedStructure(receviedStructureValue)
        } catch {
            errorLog(error)
        }
    }
    
    func sendDrawing(_ drawing: PKDrawing) {
        let structureValue = CommunicationStructure(
            signaature: .drawing,
            UUIDKey: nil, time: nil, guess: nil,
            drawing: drawing.dataRepresentation()
        )
        send(structureValue)
    }
    
    func send(_ structureValue: CommunicationStructure) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(structureValue)
            sendData(encoded, mode: .reliable)
        } catch {
            errorLog(error)
        }
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
