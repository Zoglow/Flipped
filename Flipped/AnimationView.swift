//
//  AnimationView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import PencilKit
import RealmSwift

struct AnimationView: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedRealmObject var animation: Animation
    
    @State var canvas = PKCanvasView()
    @State var drawing = PKDrawing()
    @State var frameImage = Image(systemName: "gear")
    @State var scaleEffect = 0.75
    @State public var onionSkinModeIsOn = true
    
    @State private var isPlaying = false
    @State private var isFocused = false
    @State private var isEditingTitle = false
    @State private var editableTitle = ""

    
    var body: some View {
        

        ZStack(alignment: .center) {
            Color.white
                .ignoresSafeArea()
            
            if (onionSkinModeIsOn) {
                
                OnionSkinView(animation: animation, selectedFrame: animation.selectedFrame!, indexModifier: -2)
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                OnionSkinView(animation: animation, selectedFrame: animation.selectedFrame!, indexModifier: -1)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                Rectangle()
                    .foregroundColor(.blue)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                
                OnionSkinView(animation: animation, selectedFrame: animation.selectedFrame!, indexModifier: 2)
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                OnionSkinView(animation: animation, selectedFrame: animation.selectedFrame!, indexModifier: 1)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                Rectangle()
                    .foregroundColor(.green)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                
            }
            
            if (isPlaying) {
                frameImage
                    .resizable()
                    .ignoresSafeArea()
            } else {
                CanvasView(canvas: $canvas, drawing: $drawing, animation: animation, selectedFrame: animation.selectedFrame!)
                    .onAppear(perform: { animation.loadDrawing(canvas: canvas, frame: animation.selectedFrame!) })
                    .onDisappear(perform: { animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!) })
                    .ignoresSafeArea()
            }
            
            if (!isFocused) {
                VStack {
                    Spacer()
                    TimelineView(canvas: $canvas, isPlaying: $isPlaying, frameImage: $frameImage, onionSkinModeIsOn: $onionSkinModeIsOn, animation: animation).scaleEffect(scaleEffect)
                }
                HStack {
                    ToolbarView(canvas: $canvas).scaleEffect(scaleEffect)
                        .offset(x:-95)
                    Spacer()
                }
                .ignoresSafeArea()
            }
            
        }
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                
                if (isEditingTitle) {
                    HStack {
                        TextField(animation.title, text: $editableTitle).textFieldStyle(.roundedBorder)
                        Button {
                            if (!editableTitle.isEmpty) {
                                
                                try? realm.write {
                                    let thisAnimation = animation.thaw()
                                    thisAnimation?.title = editableTitle
                                }
                                
                            }
                            isEditingTitle.toggle()
                            print(isEditingTitle)
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                } else {
                    Button {
                        isEditingTitle.toggle()
                        print(isEditingTitle)
                    } label: {
                        Text(animation.title)
                            .font(.title3)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }

                }
            }
//            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFocused.toggle()
                } label: {
                    Image(systemName: "rectangle.expand.vertical")
                }
            }
            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame)
//                } label: {
//                    Image(systemName: "square.and.arrow.down")
//                }
//            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onionSkinModeIsOn.toggle()
                } label: {
                    Image(systemName: "square.3.stack.3d.middle.fill")
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onEnded({ fingerDistance in
                    isFocused = (fingerDistance > 1 ? true : false)
                })
        )
        
    } // End of View
    
}

extension PKDrawing {
    
    func generateThumbnail(scale: CGFloat) -> UIImage {
        
        let screen = UIScreen.main.bounds
        let traitCollection = UITraitCollection(userInterfaceStyle: .light)
        
        var thumbnail = UIImage()
        
        traitCollection.performAsCurrent {
            thumbnail = self.image(from: CGRect(origin: .zero, size: CGSize(width: screen.width, height: screen.height)), scale: scale)
        }
        
        return thumbnail
        
    }
}

//let darkImage = thumbnail(drawing: drawing, thumbnailRect: frameForImage, traitCollection: UITraitCollection(userInterfaceStyle: .dark))

//func thumbnail(drawing: PKDrawing, thumbnailRect: CGRect, traitCollection: UITraitCollection) -> UIImage {
//
//    var image = UIImage()
//    traitCollection.performAsCurrent {
//        image = drawing.image(from: thumbnailRect, scale: 2.0)
//    }
//    return image
//}


//struct AnimationView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        return AnimationView(animation: Animation(), canvas: PKCanvasView())
//    }
//}

