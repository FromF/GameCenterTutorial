//
//  MatchManager+GKLocalPlayerListener.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/25.
//

import Foundation
import GameKit

extension MatchManager: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        if let viewController = GKMatchmakerViewController(invite: invite) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true)
        }
    }
}
