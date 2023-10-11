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
    @State var scaleEffect = 0.75
    @State var onionSkinModeIsOn = true
    
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
                    .blendMode(.hardLight)// Added, not tested yet
                
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
                    .foregroundColor(.red)
                    .blendMode(.screen)
                    .ignoresSafeArea()
                
            }
            
            CanvasView(canvas: $canvas, drawing: $drawing, animation: animation, selectedFrame: animation.selectedFrame!)
                .onAppear(perform: { loadDrawing() })
                .onDisappear(perform: { saveDrawing() })
                .ignoresSafeArea()
            
            
            if (!isFocused) {
                VStack {
                    
                    Spacer()
                    TimelineView(canvas: $canvas, animation: animation).scaleEffect(scaleEffect)
                    
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFocused.toggle()
                } label: {
                    Image(systemName: "rectangle.expand.vertical")
                }
                
                

            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    saveDrawing()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }.gesture(
            MagnificationGesture()
                .onEnded({ fingerDistance in
                    isFocused = (fingerDistance > 1 ? true : false)
                })
        )
        
    } // End of View
        
    
    func saveDrawing() {
        let thisAnimation = animation.thaw()
        try! realm.write {
            thisAnimation?.selectedFrame?.frameData = canvas.drawing.dataRepresentation()
            print("Frame data saved: " + (thisAnimation?.selectedFrame?.frameData.debugDescription ?? "No data found"))
        }
        loadDrawing()
        
    }
    
    func loadDrawing() {
        
        print("loadDrawing() called")
        
        if let savedData = animation.selectedFrame?.frameData {
            print("Frame data loaded: " + savedData.debugDescription)
            if let loadedDrawing = try? PKDrawing(data: savedData) {
                drawing = loadedDrawing
                canvas.drawing = drawing
            }
        }
    }
    
    
}

//struct AnimationView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        return AnimationView(animation: Animation(), canvas: PKCanvasView())
//    }
//}

