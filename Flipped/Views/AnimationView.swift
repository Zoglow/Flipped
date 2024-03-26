//
//  AnimationView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import PencilKit
import RealmSwift
import Foundation

import UIKit
import GIFFromImages
import Photos

//import UIKit
//import ImageIO
//import MobileCoreServices
//import UniformTypeIdentifiers

struct AnimationView: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedRealmObject var animation: Animation
    
    @State var canvas = PKCanvasView()
    @State var drawing = PKDrawing()
    @State var frameImage = Image(systemName: "gear")
    @State var currFrame: Frame
    
    @State var scaleEffect = 0.75
    
    @State public var onionSkinModeIsOn = true
    @State private var isPlaying = false
    @State private var isFocused = false
    @State private var isEditingTitle = false
    @State private var editableTitle = ""
//    @State var gif: CFString
    @State var showSavePopup = false
    
    var body: some View {

        ZStack(alignment: .center) {
            Color.white
                .ignoresSafeArea()
            
            if (onionSkinModeIsOn) {
                
                OnionSkinView(animation: animation, selectedFrame: currFrame, indexModifier: -2)
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                OnionSkinView(animation: animation, selectedFrame: currFrame, indexModifier: -1)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                Rectangle()
                    .foregroundColor(.blue)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                
                OnionSkinView(animation: animation, selectedFrame: currFrame, indexModifier: 2)
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .blendMode(.hardLight)
                
                OnionSkinView(animation: animation, selectedFrame: currFrame, indexModifier: 1)
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
            
            CanvasView(canvas: $canvas, drawing: $drawing, animation: animation, currFrame: currFrame)
//                .aspectRatio(1.0, contentMode: .fit)
                .opacity(isPlaying ? 0 : 1)
                .onAppear {
                    animation.loadDrawing(canvas: canvas, frame: currFrame)
                }
                .onDisappear(perform: { animation.saveDrawing(canvas: canvas, frame: currFrame) })
                .ignoresSafeArea()

            
            if !isFocused {
                VStack {
                    Spacer()
                    TimelineView(framesPerSecond: animation.framesPerSecond, canvas: $canvas, isPlaying: $isPlaying, currFrame: $currFrame, frameImage: $frameImage, onionSkinModeIsOn: $onionSkinModeIsOn, animation: animation).scaleEffect(scaleEffect)
                }
                HStack {
                    ToolbarView(canvas: $canvas).scaleEffect(scaleEffect)
                        .offset(x:-95)
                    Spacer()
                }
                .ignoresSafeArea()
            }
            
            if showSavePopup {
                SaveAnimationPopup(animation: animation, showSavePopup: $showSavePopup)
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
                
                
                Button {
                    withAnimation(.easeInOut) {
                        showSavePopup = true
                    }
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                    
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

//struct AnimationView_Previews: PreviewProvider {
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

