//
//  TimelineView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import PencilKit
import RealmSwift

struct TimelineView: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf

    @State private var timer: Timer?
    @State var middleFrame: Frame?
    
    @Binding var canvas: PKCanvasView
    @Binding var isPlaying: Bool
    @Binding var frameImage: Image
    @Binding var onionSkinModeIsOn: Bool
    
    @State var onionSkinModeWasOn: Bool?
    
    @ObservedRealmObject var animation: Animation
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50) //timeline bg
                .frame(width:700, height: 50)
                .foregroundColor(.black.opacity(0.25))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack() { //Frames
                        Spacer().frame(width: 200)
                        ForEach(animation.frames) { frame in
                             
                            TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas, middleFrame: $middleFrame)
                                .id(frame)
                        }
                        Spacer().frame(width: 200)
                        
                    }
                    .frame(height: 150)
                    
                }
                .frame(width: 550, height: 150)
//                .scrollTargetBehavior(.viewAligned)
//                .scrollPosition(id: $centerFrame, anchor: .center)
//                .safeAreaPadding(.horizontal, 30)
//                .scrollClipDisabled()
//                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .onChange(of: animation.selectedFrame) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        proxy.scrollTo(animation.selectedFrame, anchor: .center)
                    }
                }
                
                
            }
//            .scrollPosition(id: $centerFrame, anchor: .center)
            
            HStack(alignment: .center) { //timeline controls
                Button {
                    isPlaying.toggle()
                    isPlaying ? startPlayback() : stopPlayback()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }.onDisappear {
                    isPlaying = false
                }
            
                Spacer()
                Image(systemName: "gear")
            }
            .font(.title)
            .foregroundColor(.black)
            .padding([.leading,.trailing], 20)
               
            
        }
        .frame(width:700)
        
    }
    
    func startPlayback() {
        
        onionSkinModeWasOn = onionSkinModeIsOn
        onionSkinModeIsOn = false
        
        animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!)
        
        guard !animation.frames.isEmpty else { return }
        
        var frameImages: [Image] = []

        for frame in animation.frames {
            let frameImage = Image(uiImage: try! PKDrawing(data: frame.frameData).generateThumbnail(scale: 1))
            frameImages.append(frameImage)
        }
        
        let thisAnimation = animation.thaw()
//        canvas.drawing = PKDrawing()
        
        let index = animation.frames.firstIndex(of: animation.selectedFrame!)
        
        playFrame(index: index!, images: frameImages, animation: thisAnimation!)
    }
    
    func playFrame(index: Int, images: [Image], animation: Animation) {
        
        guard isPlaying else { return }
                
        frameImage = images[index]
        
        let nextIndex = (index + 1) % images.count
        
        // Delay between frames (adjust as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playFrame(index: nextIndex, images: images, animation: animation)
        }
    }

    func stopPlayback() {
        onionSkinModeIsOn = onionSkinModeWasOn!
        canvas.drawing = try! PKDrawing(data: animation.selectedFrame!.frameData)
        isPlaying = false
    }
    
}

//struct TimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Set up the Realm configuration for preview
//        let config = Realm.Configuration(inMemoryIdentifier: "preview")
//        let realm = try! Realm(configuration: config)
//        
//        // Set up a sample animation for preview
//        let previewAnimation = Animation.previewAnimation(in: realm)
//        
//        return AnimationView(animation: previewAnimation)
//            .environment(\.realm, realm)
//            .environment(\.realmConfiguration, config)
//    }
//}


//{ frame in
//    
//    if (frame == animation.selectedFrame) {
//        HStack {
//            if (!isPlaying) { addFrameButton(isToLeft: true, frame: frame) }
//
//            TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
//                .zIndex(3)
//            
//            if (!isPlaying) { addFrameButton(isToLeft: false, frame: frame) }
//            
//        }
//        .id(frame.id)
//        .padding(.horizontal, -33)
//        .zIndex(3)
//        .contextMenu {
//            
//            // Delete frame
//            Button {
//                let index = animation.frames.firstIndex(of: animation.selectedFrame!)
//                print("Currently selected index: " + index!.description)
//                
//                try! realm.write {
//                    let thisAnimation = animation.thaw()
//                    
//                    
//                    // This needs work
//                    if (thisAnimation?.frames.count == 1) {
//                        canvas.drawing = PKDrawing()
//                    } else if ((index! - 1) < 0) {
//                        thisAnimation?.selectedFrame = thisAnimation?.frames[index!+1]
//                        canvas.drawing = try PKDrawing(data: (thisAnimation?.selectedFrame!.frameData)!)
//
//                        thisAnimation!.frames.remove(at: index!)
//                    } else {
//                        thisAnimation?.selectedFrame = thisAnimation?.frames[index!-1]
//                        canvas.drawing = try PKDrawing(data: (thisAnimation?.selectedFrame!.frameData)!)
//                        
//                        thisAnimation!.frames.remove(at: index!)
//                    }
//                }
//                
//            } label: {
//                Text("Delete")
//                Image(systemName: "x.circle.fill")
//            }
//            // Duplicate frame
//            Button {
//                animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!)
//                animation.duplicateFrame(canvas: canvas, frame: animation.selectedFrame!)
//            } label: {
//                Text("Duplicate")
//                Image(systemName: "plus.square.fill.on.square.fill")
//            }
//            
//        }
//        
//    } else {
//        TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
////
////                                .scrollTransition(axis: .horizontal) {
////                                    content, phase in
////                                    content.opacity(phase.isIdentity ? 1 : 0)
////                                }
//        
//    }
//}

