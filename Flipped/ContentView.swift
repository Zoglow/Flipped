//
//  ContentView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import RealmSwift
import PencilKit

struct ContentView: View {
    
//    @ObservedResults(Frame.self) var frames
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedResults(Animation.self) var animations
    var newAnimation = Animation()
    
    private let adaptiveColumns = [GridItem(.adaptive(minimum: 250))]
    @State var editModeIsOn = false
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                    ForEach(animations) { animation in
                        NavigationLink(destination: AnimationView(animation: animation)) {
                            VStack {
                                ZStack {
                                    
                                    Rectangle()
                                        .foregroundColor(.white)
                                    Image(uiImage: try! PKDrawing(data: animation.selectedFrame!.frameData).generateThumbnail(scale: 1)) // Use the generated thumbnail
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    if (editModeIsOn) {
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(.black)
                                                .opacity(0.1)
                                                .onTapGesture {
                                                    $animations.remove(animation)
                                                }
                                            Image(systemName: "x.circle.fill")
                                                .foregroundColor(Color.pink)
                                                .font(.title)
                                        }.zIndex(2)
                                    }
                                    
                                } // Preview plus edit overlay
                                .frame(width: 170, height: 150)
                                .cornerRadius(3)
                                .shadow(radius: 5)
                                
                                
                                Text(animation.title).foregroundColor(.black)
                            }.padding(5)
                        }
                    }
                    
                }
                .onAppear(perform: {
                    newAnimation.selectedFrame = Frame()
                    newAnimation.frames.append(newAnimation.selectedFrame!)
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                editModeIsOn.toggle()
                            }
                        }, label: {
                            Text(editModeIsOn ? "Done" : "Edit")
                        }) // Edit button
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addItem()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }.foregroundColor(.black)
                
                    
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .padding(20)
        }.background(.white)
    }
    
    private func addItem() {
        let item = Animation()
        $animations.append(item)
        
        try? realm.write {
            item.selectedFrame = Frame()
            item.frames.append(item.selectedFrame!)
        }
        
        // Doesn't do anything >
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            AnimationView(animation: item)
//        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

