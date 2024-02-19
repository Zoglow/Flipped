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
    
    @State var isMiddleFrame: Bool = false
    
    @Binding var canvas: PKCanvasView
    
    var body: some View {
        
        HStack {
            
            if (thisFrame == animation.selectedFrame) { addFrameButton(isToLeft: true, frame: thisFrame).zIndex(1) }
    
            frameView()
                .zIndex(2)
                
            if (thisFrame == animation.selectedFrame) { addFrameButton(isToLeft: false, frame: thisFrame).zIndex(1) }
        }
        .zIndex(thisFrame == animation.selectedFrame ? 3 : 0)
        .padding(.horizontal, thisFrame == animation.selectedFrame ? -32 : 1)
        .contextMenu {
            if (thisFrame == animation.selectedFrame) { 
                deleteButton()
                duplicateButton()
            }
        }
        
    }
    
    private func checkLocation(geo: GeometryProxy) -> Bool {
        let screenWidth = UIScreen.main.bounds.width
        let middleOfScreen = screenWidth / 2.0
        let loc = geo.frame(in: .global).midX
        
        // Define a range around the middleOfScreen
        let range: ClosedRange<CGFloat> = (middleOfScreen - 50.5)...(middleOfScreen + 50.5)
        
        if (range.contains(loc)) {
            return true
//            if (animation.selectedFrame != thisFrame) {
//
////                animation.loadDrawing(canvas: canvas, frame: thisFrame)
//            }
        }

        return false
    }
    
    func frameView() -> some View {
        return AnyView (
            Button {
                animation.saveDrawing(canvas: canvas, frame: thisFrame)
            } label: {
                ZStack {
                    
                    GeometryReader { geo in
                        
                        Rectangle()
                            .foregroundColor(.white)
                        Image(uiImage: try! PKDrawing(data: thisFrame.frameData).generateThumbnail(scale: 1)) // Use the generated thumbnail
                            .resizable()
                            .aspectRatio(contentMode: .fit)
//                        if (checkLocation(geo: geo)) {
//                            Text("is middle")
//                        }
                            
                    }
                    
                        
                }
                .frame(width: 125, height: 100)
                .shadow(radius: 5)
                .scaleEffect(thisFrame == animation.selectedFrame ? 1.3 : 1)
                .padding(.horizontal, thisFrame == animation.selectedFrame ? 7 : 0)
            }
        )
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

struct TimelineFrame_Previews: PreviewProvider {
    static var previews: some View {
        // Set up the Realm configuration for preview
        let config = Realm.Configuration(inMemoryIdentifier: "preview")
        let realm = try! Realm(configuration: config)
        
        // Set up a sample animation for preview
        let previewAnimation = Animation.previewAnimation(in: realm)
        
        return AnimationView(animation: previewAnimation)
            .environment(\.realm, realm)
            .environment(\.realmConfiguration, config)
    }
}
