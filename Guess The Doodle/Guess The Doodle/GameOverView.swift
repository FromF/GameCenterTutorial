//
//  GameOverView.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var matchManager: MatchManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(.gameOver)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 70)
                .padding(.vertical)
            
            Text("Score \(matchManager.score)")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.primaryYellow)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("MENU")
                    .foregroundStyle(.menuBtn)
                    .brightness(-0.4)
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
            .padding(.horizontal, 50)
            .background(
                Capsule(style: .circular)
                    .fill(.menuBtn)
            )
            
            Spacer()
        }
        .background(
            Image(.gameOverBg)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.1)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GameOverView(matchManager: MatchManager())
}
