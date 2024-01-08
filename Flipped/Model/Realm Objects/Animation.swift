//
//  Animation.swift
//  Flipped
//
//  Created by Zoe Olson on 9/25/23.
//

import Foundation
import RealmSwift
import PencilKit

final class Animation: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var createdDate = Date()
    @Persisted var title = "Untitled animation"
    
    @Persisted var frames = RealmSwift.List<Frame>()
    @Persisted var selectedFrame: Frame?
    
    func saveDrawing(canvas: PKCanvasView, frame: Frame) {
        
        // You can access the Realm instance using `self.realm`
        let animation = self.thaw()
        let realm = animation?.realm
        
        try? realm?.write {
            animation!.selectedFrame?.frameData = canvas.drawing.dataRepresentation()
            print("Frame data saved: " + (animation!.selectedFrame?.frameData.debugDescription ?? "No data found"))
        }
        
        self.loadDrawing(canvas: canvas, frame: frame)
    }
    
    func loadDrawing(canvas: PKCanvasView, frame: Frame) {
            
        let thisFrame = frame.thaw()
        let animation = self.thaw()
        let realm = animation?.realm
            
        try? realm?.write {
            if let loadedDrawing = try? PKDrawing(data: thisFrame!.frameData) {
                animation!.selectedFrame = thisFrame
                canvas.drawing = PKDrawing()
                canvas.drawing = loadedDrawing
            }
        }
        
    }
    
    func addFrame(isToLeft: Bool, canvas: PKCanvasView, frame: Frame) {
        
        let animation = self.thaw()
        let realm = animation?.realm
        let newFrame = Frame()
        
        saveDrawing(canvas: canvas, frame: frame)
        
        try? realm?.write {
            
            let index = animation!.frames.firstIndex(of: (animation!.selectedFrame)!)
            animation!.selectedFrame = newFrame
            animation!.frames.insert(newFrame, at: isToLeft ? index! : index! + 1)
        }
        
        loadDrawing(canvas: canvas, frame: newFrame)
        
    }

}


