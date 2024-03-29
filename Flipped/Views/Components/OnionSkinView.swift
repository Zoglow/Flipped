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
    
    @State var indexModifier: Int
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvas.isOpaque = false
        
        let selectedFrameIndex = animation.frames.firstIndex(of: animation.selectedFrame!)
        let onionSkinIndex = selectedFrameIndex! + indexModifier
        
        if (onionSkinIndex >= 0 && onionSkinIndex < animation.frames.count) {
            canvas.drawing = try! PKDrawing(data: animation.frames[onionSkinIndex].frameData)
        } else {
            canvas.drawing = PKDrawing()
        }
        
        return canvas
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        let selectedFrameIndex = animation.frames.firstIndex(of: animation.selectedFrame!)
        let onionSkinIndex = selectedFrameIndex! + indexModifier
        
        if (onionSkinIndex >= 0 && onionSkinIndex < animation.frames.count) {
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
