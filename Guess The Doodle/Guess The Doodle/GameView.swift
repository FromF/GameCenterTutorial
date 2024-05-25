//
//  GameView.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var matchManager: MatchManager
    @State var drawingGuess = ""
    @State var eraserEnabed: Bool = false
    
    func makeGuess() {
        guard drawingGuess != "" else {
            return
        }
        
        let structureValue = CommunicationStructure(
            signaature: .guess,
            UUIDKey: nil, time: nil, guess: drawingGuess, drawing: nil
        )
        matchManager.send(structureValue)

        drawingGuess = ""
    }

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image(matchManager.currentlyDrawing ? .drawerBg : .guesserBg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .scaleEffect(1.1)
                
                VStack {
                    topBar
                    
                    ZStack {
                        DrawingView(matchManager: matchManager, eraserEnabled: $eraserEnabed)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black, lineWidth: 10)
                            }
                        
                        VStack {
                            HStack {
                                Spacer()
                                
                                if matchManager.currentlyDrawing {
                                    Button {
                                        eraserEnabed.toggle()
                                    } label: {
                                        Image(systemName: eraserEnabed ? "eraser.fill" : "eraser")
                                            .font(.title)
                                            .foregroundStyle(.primaryPurple)
                                            .padding(.top, 10)
                                    }
                                }
                            } // HStack
                            
                            Spacer()
                        } // VStack
                        .padding()
                    } // ZStack
                    
                    pastGuesses
                } // VStack
                .padding(.horizontal, 30)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
            VStack {
                Spacer()
                
                promptGroup
            } // VStack
            .ignoresSafeArea()
        } // ZStack
    }
    
    var topBar: some View {
        ZStack {
            HStack {
                Button {
                    matchManager.match?.disconnect()
                    matchManager.resetGame()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                        .font(.largeTitle)
                        .tint(matchManager.currentlyDrawing ? .primaryYellow : .primaryPurple)
                }
                
                Spacer()
                
                Label("\(matchManager.remainingTime)", systemImage: "clock.fill")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(matchManager.currentlyDrawing ? .primaryYellow : .primaryPurple)
            } // HStack
            
            Text("Score:\(matchManager.score)")
                .bold()
                .font(.title)
                .foregroundStyle(matchManager.currentlyDrawing ? .primaryYellow : .primaryPurple)
        } // ZStack
        .padding(.vertical, 15)
    }
    
    var pastGuesses: some View {
        ScrollView {
            ForEach(matchManager.passGuesses) { guess in
                HStack {
                    Text(guess.message)
                        .font(.title2)
                        .bold(guess.correct)
                    
                    if guess.correct {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundStyle(
                                matchManager.currentlyDrawing ?
                                Color(red: 0.808, green: 0.345, blue: 0.776) : Color(red: 0.243, green: 0.773, blue: 0.745)
                            )
                    }
                } // HStack
                .frame(maxWidth: .infinity)
                .padding(.bottom, 1)
            } // ForEach
        } // ScrollView
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            (matchManager.currentlyDrawing ?
            Color(red: 0.243, green: 0.773, blue: 0.745) : .primaryYellow)
                .brightness(-0.2)
                .opacity(0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.vertical)
        .padding(.bottom, 130)
    }
    
    var promptGroup: some View {
        VStack {
            if matchManager.currentlyDrawing {
                Label("DRAW:", systemImage: "exclamationmark.bubble.fill")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(matchManager.drawPrompt.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundStyle(.primaryYellow)
            } else {
                HStack {
                    Label("GUESS THE DRAWING!:", systemImage: "exclamationmark.bubble.fill")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primaryPurple)
                    
                    Spacer()
                } // HStack
                
                HStack {
                    TextField("Type your guess", text: $drawingGuess)
                        .padding()
                        .background(
                            Capsule(style: .circular)
                                .fill(.white)
                        )
                        .onSubmit {
                            makeGuess()
                        }
                    
                    Button {
                        makeGuess()
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .renderingMode(.original)
                            .foregroundStyle(.primaryPurple)
                            .font(.system(size: 50))
                    }
                } //HStack
            }
        } // VStack
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .bottom], 30)
        .padding(.vertical)
        .background(
            (matchManager.currentlyDrawing ?
             Color(red: 0.243, green: 0.773, blue: 0.745) : .primaryYellow)
            .opacity(0.5)
            .brightness(-0.2)
        )
    }
}

#Preview {
    GameView(matchManager: MatchManager())
}
