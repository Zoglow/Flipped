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
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                    ForEach(animations) { animation in
                        NavigationLink(destination: AnimationView(animation: animation)) {
                            VStack {
                                Rectangle()
                                    .frame(width: 170, height: 150)
                                    .foregroundColor(.white)
                                    .cornerRadius(3)
                                    .shadow(radius: 5)
                                Text(animation.title).foregroundColor(.black)
                            }.padding(5)
                        }
                    }
                    
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
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
