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
        let canvasView = canvas
        
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        
        return canvasView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(canvasView: self, animation: self.animation, selectedFrame: self.selectedFrame)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var canvasView: CanvasView
        var animation: Animation
        var selectedFrame: Frame
        
        init(canvasView: CanvasView, animation: Animation, selectedFrame: Frame) {
            self.canvasView = canvasView
            self.animation = animation
            self.selectedFrame = selectedFrame
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Handle drawing changes here
//            animation.saveDrawing(canvas: canvasView, frame: selectedFrame)
            
        }
    }
    
//    func makeUIView(context: Context) -> PKCanvasView {
//
//        canvas.drawingPolicy = .anyInput
//        canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
//        canvas.isOpaque = false
//        canvas.drawing = drawing
//        
////        canvas.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
////        canvas.minimumZoomScale = 0.2
////        canvas.maximumZoomScale = 4.0
//        
////        canvas.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
////        canvas.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
////        canvas.becomeFirstResponder()
//                
//        return canvas
//        
//    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
//        animation.saveDrawing(canvas: canvas, frame: selectedFrame)
    }
    
    
}


/*
 
 // Never gets called
 func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
     
     print("Canvas view drawing changed")
     // Ensure there's a selected frame
     guard let selectedFrame = selectedFrame.thaw() else {
         print("No selected frame")
         return
     }
     
     try? realm.write { selectedFrame.frameData = canvas.drawing.dataRepresentation() }
     print("Success saving frame data")
 }
 
 
 */
