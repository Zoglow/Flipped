//
//  TimelineFrame.swift
//  Flipped
//
//  Created by Zoe Olson on 9/26/23.
//

import SwiftUI
import PencilKit
import RealmSwift

struct TimelineFrame: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedRealmObject var thisFrame: Frame
    @ObservedRealmObject var animation: Animation
    
    @Binding var canvas: PKCanvasView
    
    var body: some View {
        
        HStack {
            
            if (thisFrame == animation.selectedFrame) { addFrameButton(isToLeft: true, frame: thisFrame).zIndex(1) }
            
            frameView().zIndex(2)
                
            if (thisFrame == animation.selectedFrame) { addFrameButton(isToLeft: false, frame: thisFrame).zIndex(1) }
        }
        .zIndex(thisFrame == animation.selectedFrame ? 3 : 0)
        .padding(.horizontal, thisFrame == animation.selectedFrame ? -28 : 5)
        .contextMenu {
            if (thisFrame == animation.selectedFrame) {
                deleteButton()
            }
            
            if (thisFrame == animation.selectedFrame) {
                duplicateButton()
            }
            
        }

        
    }
    
    func addFrameButton(isToLeft: Bool, frame: Frame) -> some View {
        return AnyView (
            Button {
                animation.addFrame(isToLeft: isToLeft, canvas: canvas, frame: frame)
            } label: {
                ZStack {
                    Rectangle()
                        .frame(width: 37, height: 45)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .font(.headline)
                }
            }
        )
    }
    
    func frameView() -> some View {
        return AnyView (
            Button {
                animation.saveDrawing(canvas: canvas, frame: thisFrame)
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                    Image(uiImage: try! PKDrawing(data: thisFrame.frameData).generateThumbnail(scale: 1)) // Use the generated thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        
                }
                .frame(width: 125, height: 100)
                .shadow(radius: 5)
                .scaleEffect(thisFrame == animation.selectedFrame ? 1.3 : 1)
                .padding(.vertical, thisFrame == animation.selectedFrame ? 10 : 0)
                .padding(.horizontal, thisFrame == animation.selectedFrame ? 7 : 0)
            }
        )
    }
    
    func deleteButton() -> some View {
        return AnyView (
            Button {
                let index = animation.frames.firstIndex(of: animation.selectedFrame!)
                print("Currently selected index: " + index!.description)

                try! realm.write {
                    let thisAnimation = animation.thaw()


                    // This needs work
                    if (thisAnimation?.frames.count == 1) {
                        canvas.drawing = PKDrawing()
                    } else if ((index! - 1) < 0) {
                        thisAnimation?.selectedFrame = thisAnimation?.frames[index!+1]
                        canvas.drawing = try PKDrawing(data: (thisAnimation?.selectedFrame!.frameData)!)

                        thisAnimation!.frames.remove(at: index!)
                    } else {
                        thisAnimation?.selectedFrame = thisAnimation?.frames[index!-1]
                        canvas.drawing = try PKDrawing(data: (thisAnimation?.selectedFrame!.frameData)!)

                        thisAnimation!.frames.remove(at: index!)
                    }
                }
            } label: {
                Text("Delete")
                Image(systemName: "x.circle.fill")
            }
        )
    }
    
    func duplicateButton() -> some View {
        return AnyView (
            Button {
                animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!)
                animation.duplicateFrame(canvas: canvas, frame: animation.selectedFrame!)
            } label: {
                Text("Duplicate")
                Image(systemName: "plus.square.fill.on.square.fill")
            }
        )
    }

}

//struct TimelineFrame_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineFrame(thisFrame: Frame(), animation: Animation())
//    }
//}
