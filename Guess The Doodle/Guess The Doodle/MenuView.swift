//
//  MenuView.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var matchManager: MatchManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(.logo)
                .resizable()
                .scaledToFit()
                .padding(30)
            
            Spacer()
            
            Button {
                matchManager.startMatchMaking()
            } label: {
                Text("PLAY")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .bold()
            }
            .disabled(matchManager.authenicationState != .authenticated || matchManager.inGame)
            .padding(.vertical, 20)
            .padding(.horizontal, 100)
            .background(
                Capsule(style: .circular)
                    .fill(matchManager.authenicationState != .authenticated || matchManager.inGame ? .gray : .menuBtn)
            )
            
            Text(matchManager.authenicationState.rawValue)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.primaryYellow)
                .padding()
            
            Spacer()
        }
        .background(
            Image(.menuBg)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.1)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
