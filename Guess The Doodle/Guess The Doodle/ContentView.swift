//
//  ContentView.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var matchManager = MatchManager()
    
    var body: some View {
        ZStack {
            if matchManager.isGameOver {
                GameOverView(matchManager: matchManager)
            } else if matchManager.inGame {
                GameView(matchManager: matchManager)
            } else {
                MenuView(matchManager: matchManager)
            }
        } // ZStack
        .onAppear {
            matchManager.authenticationUser()
        }
    }
}

#Preview {
    ContentView()
}
