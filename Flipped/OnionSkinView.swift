//
//  OnionSkinView.swift
//  Flipped
//
//  Created by Zoe Sosa on 10/9/23.
//

import SwiftUI
import PencilKit
import RealmSwift

struct OnionSkinView: UIViewRepresentable {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @State var canvas: PKCanvasView = PKCanvasView()
    
    @ObservedRealmObject var animation: Animation
    @ObservedRealmObject var selectedFrame: Frame
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvas.isOpaque = false
        
        
        let selectedFrameIndex = animation.frames.firstIndex(of: animation.selectedFrame!)
        print("Selected frame index: " + selectedFrameIndex!.description)
        
        if (selectedFrameIndex! > 0) {
            let onionSkinIndex = selectedFrameIndex! - 1
            canvas.drawing = try! PKDrawing(data: animation.frames[onionSkinIndex].frameData)
        } else {
            canvas.drawing = PKDrawing()
            
        }
        return canvas
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        let selectedFrameIndex = animation.frames.firstIndex(of: animation.selectedFrame!)
        print("Selected frame index: " + selectedFrameIndex!.description)
        
        if (selectedFrameIndex! > 0) {
            let onionSkinIndex = selectedFrameIndex! - 1
            canvas.drawing = try! PKDrawing(data: animation.frames[onionSkinIndex].frameData)
        } else {
            canvas.drawing = PKDrawing()
        }
    }
    

}

//struct OnionSkinView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnionSkinView()
//    }
//}
