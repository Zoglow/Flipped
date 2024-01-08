//
//  CanvasView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import PencilKit
import RealmSwift

struct CanvasView: UIViewRepresentable {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @Binding var canvas: PKCanvasView
    @Binding var drawing: PKDrawing
    
    @ObservedRealmObject var animation: Animation
    @ObservedRealmObject var selectedFrame: Frame
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvas.isOpaque = false
        
        canvas.drawing = drawing
        
        return canvas
        
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
    
//        if let loadedDrawing = try? PKDrawing(data: selectedFrame.frameData) {
//            drawing = loadedDrawing
//        }
        
    }
    
    // Never gets called
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Ensure there's a selected frame
        guard let selectedFrame = selectedFrame.thaw() else {
            print("No selected frame")
            return
        }
        
        try? realm.write { selectedFrame.frameData = canvas.drawing.dataRepresentation() }
        print("Success saving frame data")
    }
}
