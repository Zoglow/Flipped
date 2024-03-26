//
//  TimelineFrame.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/26/23.
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
    @Binding var currFrame: Frame
    @Binding var isScrolling: Bool
    
    var body: some View {
        
        HStack {
            
            if (thisFrame == currFrame) { addFrameButton(isToLeft: true, frame: thisFrame).zIndex(2) }
    
            frameView()
                .zIndex(3)
                
            if (thisFrame == currFrame) { addFrameButton(isToLeft: false, frame: thisFrame).zIndex(2) }
        }
        .zIndex(thisFrame == currFrame ? 3 : 0)
        .padding(.horizontal, thisFrame == currFrame ? -32 : 1)
        .contextMenu {
            if (thisFrame == currFrame) {
                deleteButton()
                duplicateButton()
            }
        }
    
    }
    
    // Detects if frame is close enough to the center to be considered for selection
    private func isNearCenter(geo: GeometryProxy) -> Bool {
        let screenWidth = UIScreen.main.bounds.width
        let middleOfScreen = screenWidth / 2.0
        
        let xPos = geo.frame(in: .global).midX
        
        // Define a range around the middleOfScreen
        let range: ClosedRange<CGFloat> = (middleOfScreen - 75)...(middleOfScreen + 75)
        
        return range.contains(xPos)
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
                        
                            // Animation's selected frame changes only if there is a new frame that qualifies
                            .onChange(of: isNearCenter(geo: geo)) {
                                if (isNearCenter(geo: geo) && currFrame != thisFrame && isScrolling) {
//                                    animation.loadDrawing(canvas: canvas, frame: thisFrame)
                                    currFrame = thisFrame
                                    canvas.drawing = PKDrawing()
                                    canvas.drawing = try! PKDrawing(data: currFrame.frameData)
                                    
                                }
                            }
                            
                        Image(uiImage: try! PKDrawing(data: thisFrame.frameData).generateThumbnail(scale: 1)) // Use the generated thumbnail
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
//                        VStack {
//                            if (thisFrame == animation.selectedFrame) {
//                                Text("selected frame")
//                            }
//                            if (thisFrame == currFrame) {
//                                Text("curr frame")
//                            }
//                        }
//                        
                        
                        
                         
                    }
                        
                }
                .frame(width: 125, height: 100)
                .shadow(radius: 5)
                .scaleEffect(thisFrame == currFrame ? 1.3 : 1)
                .padding(.horizontal, thisFrame == currFrame ? 7 : 0)
                
            }
        )
    }
    
    func addFrameButton(isToLeft: Bool, frame: Frame) -> some View {
        return AnyView (
            Button {
                withAnimation() {
                    animation.addFrame(isToLeft: isToLeft, canvas: canvas, frame: frame)
                }
                
                currFrame = animation.selectedFrame!
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
                let index = animation.frames.firstIndex(of: currFrame)
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
                    
                    currFrame = (thisAnimation?.selectedFrame)!
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
                animation.saveDrawing(canvas: canvas, frame: currFrame)
                animation.duplicateFrame(canvas: canvas, frame: currFrame)
            } label: {
                Text("Duplicate")
                Image(systemName: "plus.square.fill.on.square.fill")
            }
        )
    }

}

//struct TimelineFrame_Previews: PreviewProvider {
//    static var previews: some View {
//        // Set up the Realm configuration for preview
//        let config = Realm.Configuration(inMemoryIdentifier: "preview")
//        let realm = try! Realm(configuration: config)
//        
//        // Set up a sample animation for preview
//        let previewAnimation = Animation.previewAnimation(in: realm)
//        
//        return AnimationView(animation: previewAnimation, currFrame: previewAnimation.selectedFrame!)
//            .environment(\.realm, realm)
//            .environment(\.realmConfiguration, config)
//    }
//}
