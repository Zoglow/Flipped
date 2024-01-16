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
    @State var selectedFrameIndex: Int?
    
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
                
            ScrollView(.horizontal) {
                HStack(alignment: .center) { //Frames
                
                    ForEach(animation.frames) { frame in
                        
                        if (frame == animation.selectedFrame) {
                            HStack {
                                if (!isPlaying) { addFrameButton(isToLeft: true, frame: frame) }

                                TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
                                    .zIndex(3)
                                
                                if (!isPlaying) { addFrameButton(isToLeft: false, frame: frame) }
                                
                            }
                            .id(frame.id)
                            .padding(.horizontal, -33)
                            .zIndex(3)
                            .contextMenu {
                                
                                //Delete frame
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
                                    
                                } label: { Text("Delete") }
                                Button {
                                    
                                    
                                } label: { Text("Delete") }
                                
                            }
                            
                        } else {
                            TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
//                              
                                .scrollTransition(axis: .horizontal) {
                                    content, phase in
                                    content.opacity(phase.isIdentity ? 1 : 0)
                                }
                            
                        }
                    }
                    
                }
//                .frame(width: 600, alignment: .center)
                .scrollTargetLayout()
                .padding(10)
                .padding(.horizontal, 40)
                
            }
            .frame(width: 550, alignment: .center)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        
            
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
        
//        try! realm.write {
//            animation.selectedFrame = animation.frames[index]
//        }
        
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
}

