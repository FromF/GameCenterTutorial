//
//  DrawingView.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @ObservedObject var matchManager: MatchManager
    @Binding var eraserEnabled: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(matchManager: matchManager)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.delegate = context.coordinator
        canvasView.isUserInteractionEnabled = matchManager.currentlyDrawing
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        let wasDrawing = uiView.isUserInteractionEnabled
        uiView.isUserInteractionEnabled = matchManager.currentlyDrawing
        
        if !wasDrawing && matchManager.currentlyDrawing {
            uiView.drawing = PKDrawing()
        }
        
        if !uiView.isUserInteractionEnabled || !matchManager.inGame {
            uiView.drawing = matchManager.lastRecivedDrawing
        }
        
        uiView.tool = eraserEnabled ? PKEraserTool(.vector) : PKInkingTool(.pen, color: .black, width: 5)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var matchManager: MatchManager
        
        init(matchManager: MatchManager) {
            self.matchManager = matchManager
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard canvasView.isUserInteractionEnabled else { return }
            matchManager.sendData(canvasView.drawing.dataRepresentation(), mode: .reliable)
        }
    }
}

#Preview {
    DrawingView(matchManager: MatchManager(), eraserEnabled: .constant(false))
}
