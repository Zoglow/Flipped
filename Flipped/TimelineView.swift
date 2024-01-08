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

    @State private var isPlaying = false;
    @State private var timer: Timer?
    
    @Binding var canvas: PKCanvasView
    
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
                                addFrameButton(isToLeft: true, frame: frame)

                                TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
                                    .zIndex(3)
                                    
                                addFrameButton(isToLeft: false, frame: frame)
                            }
                            .scrollTransition(axis: .horizontal) {
                                content, phase in
                                content.opacity(phase.isIdentity ? 1 : 0)
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
                                    
                            }
                            
                        } else {
                            TimelineFrame(thisFrame: frame, animation: animation, canvas: $canvas)
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
               
            
        }.frame(width:700)
        
    }
    
    func startPlayback() {
        animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!)
        guard !animation.frames.isEmpty else { return }
        let index = animation.frames.firstIndex(of: animation.selectedFrame!)
        playFrame(index: index!, animation: animation.thaw()!)
    }
    
    func playFrame(index: Int, animation: Animation) {
        
        guard isPlaying else { return }
        let nextIndex = (index + 1) % animation.frames.count

        withAnimation {
            try! realm.write {
                animation.selectedFrame = animation.frames[nextIndex]
                canvas.drawing = try PKDrawing(data: animation.selectedFrame!.frameData)
            }
        }

        // Delay between frames (adjust as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            playFrame(index: nextIndex, animation: animation)
        }
    }

    func stopPlayback() {
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


