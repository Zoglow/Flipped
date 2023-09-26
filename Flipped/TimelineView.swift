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
                        TimelineFrame(thisFrame: frame, animation: animation)
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
                
                Button { //this button
                    try? realm.write {
                        let thisAnimation = animation.thaw()
                        thisAnimation?.selectedFrame = Frame()
                        thisAnimation?.frames.append(thisAnimation!.selectedFrame!)
                    }
                } label: {
                    Image(systemName: "plus")
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
//        TimelineView(animation: Animation())
//    }
//}
