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
        
        Button {
            try? realm.write {
                let thisAnimation = animation.thaw()
                let thisFrame = thisFrame.thaw()
                
                thisAnimation?.selectedFrame?.frameData = canvas.drawing.dataRepresentation()
                thisAnimation?.selectedFrame = thisFrame
                
                canvas.drawing = try PKDrawing(data: thisAnimation?.selectedFrame?.frameData ?? Data())
            }
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

        
    }
}

//struct TimelineFrame_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineFrame(thisFrame: Frame(), animation: Animation())
//    }
//}
