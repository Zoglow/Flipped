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
            }
            
            CanvasView(canvas: $canvas, drawing: $drawing, animation: animation, selectedFrame: animation.selectedFrame!)
//                .aspectRatio(1.0, contentMode: .fit)
                .opacity(isPlaying ? 0 : 1)
                .onAppear(perform: { animation.loadDrawing(canvas: canvas, frame: animation.selectedFrame!) })
                .onDisappear(perform: { animation.saveDrawing(canvas: canvas, frame: animation.selectedFrame!) })
                .ignoresSafeArea()
            
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
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onionSkinModeIsOn.toggle()
                } label: {
                    Image(systemName: "square.3.stack.3d.middle.fill")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: Image(uiImage: try! PKDrawing(data: animation.selectedFrame!.frameData).generateThumbnail(scale: 1)) , preview: SharePreview("selected frame", image: Image(uiImage: try! PKDrawing(data: animation.selectedFrame!.frameData).generateThumbnail(scale: 1))))
            }
            
        }
        .gesture(
            MagnificationGesture()
                .onEnded({ fingerDistance in
                    isFocused = (fingerDistance > 1)
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

struct AnimationView_Previews: PreviewProvider {
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

