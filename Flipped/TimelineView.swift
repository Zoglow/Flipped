//
//  TimelineView.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import SwiftUI
import RealmSwift

struct TimelineView: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf

    @State private var isPlaying = false;
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
                                Button {
                                    try? realm.write {
                                        let thisAnimation = animation.thaw()
                                        let newFrame = Frame()
                                        let index = thisAnimation?.frames.firstIndex(of: (thisAnimation?.selectedFrame)!)
                                        
                                        
                                        thisAnimation?.selectedFrame = newFrame
                                        thisAnimation?.frames.insert(newFrame, at: index!)

                                    }
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

                                TimelineFrame(thisFrame: frame, animation: animation)
                                    .zIndex(3)
                                
                                Button {
                                    try? realm.write {
                                        let thisAnimation = animation.thaw()
                                        let newFrame = Frame()
                                        let index = thisAnimation?.frames.firstIndex(of: (thisAnimation?.selectedFrame)!)
                                        
                                        
                                        thisAnimation?.selectedFrame = newFrame
                                        thisAnimation?.frames.insert(newFrame, at: index! + 1)

                                    }
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
                            }
                            .padding(.horizontal, -33)
                            .zIndex(3)
                            
                        } else {
                            TimelineFrame(thisFrame: frame, animation: animation)
                        }
                        
                        
                    }
                    
                }
                .padding(10)
                .padding(.horizontal, 40)
                
            }
            .frame(width: 550)
            
            
            HStack(alignment: .center) { //timeline controls
                Button {
                    isPlaying.toggle()
                    
                    // Play/pause animation:
                    
                } label: {
                    if (isPlaying) {
                        Image(systemName: "pause.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
            
                Spacer()
                Image(systemName: "gear")
            }
            .font(.title)
            .foregroundColor(.black)
            .padding([.leading,.trailing], 20)
               
            
        }.frame(width:700)
        
    }
}

//struct TimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        var conf = Realm.Configuration.defaultConfiguration
//        conf.inMemoryIdentifier = "preview"
//        let realm = try! Realm(configuration: conf)
//
//
//        return TimelineView(animation: Animation())
//            .environment(\.realm, realm)
//    }
//}
