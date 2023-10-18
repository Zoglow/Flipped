//
//  ContentView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
//    @ObservedResults(Frame.self) var frames
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedResults(Animation.self) var animations
    
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                editModeIsOn.toggle()
                            }
                        }, label: {
                            Text(editModeIsOn ? "Done" : "Edit")
                        })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addItem) {
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
        let newAnimation = Animation()
        $animations.append(newAnimation)
        
        try? realm.write {
            newAnimation.selectedFrame = Frame()
            newAnimation.frames.append(newAnimation.selectedFrame!)
        }
            
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

