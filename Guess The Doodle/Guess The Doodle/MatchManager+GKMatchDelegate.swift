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
        
        if content.starts(with: "strData:") {
            let message = content.replacing("strData:", with: "")
            recevedString(message)
        } else {
            do {
                lastRecivedDrawing = try PKDrawing(data: data)
            } catch {
                errorLog(error)
            }
        }
    }
    
    func sendString(_ message: String) {
        guard let encoded = "strData:\(message)".data(using: .utf8) else { return }
        sendData(encoded, mode: .reliable)
    }
    
    func sendData(_ data: Data, mode: GKMatch.SendDataMode) {
        do {
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            errorLog(error)
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
    }
}
