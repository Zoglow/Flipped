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
    
    @State private var isFocused = false
    @State private var isEditingTitle = false
    @State private var editableTitle = ""

    
    var body: some View {
            
        ZStack(alignment: .center) {
            Color.gray
                .ignoresSafeArea()
            
            CanvasView(canvas: $canvas, drawing: $drawing, selectedFrame: animation.selectedFrame!)
                .ignoresSafeArea()
                .shadow(radius: 5)
            
            if (!isFocused) {
                VStack {
                    
                    Spacer()
                    TimelineView(canvas: $canvas, animation: animation)
                    
                }
                HStack {
                    ToolbarView(canvas: $canvas)
                        .offset(x:-95)
                    Spacer()
                }
                .ignoresSafeArea()
            }
            
        }
        .onAppear(perform: { loadDrawing() })
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
        }
    }
    
    func saveDrawing() {
        let thisAnimation = animation.thaw()
        try! realm.write {
            thisAnimation?.selectedFrame?.frameData = canvas.drawing.dataRepresentation()
            print("Frame data saved: " + (thisAnimation?.selectedFrame?.frameData.debugDescription ?? "No data found"))
        }
        loadDrawing()
        
    }
    
    func loadDrawing() {
        if let savedData = animation.selectedFrame?.frameData {
            if let loadedDrawing = try? PKDrawing(data: savedData) {
                drawing = loadedDrawing
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

