//
//  TimelineFrame.swift
//  Flipped
//
//  Created by Zoe Olson on 9/26/23.
//

import SwiftUI
import RealmSwift

struct TimelineFrame: View {
    
    @Environment(\.realm) var realm
    @Environment(\.realmConfiguration) var conf
    
    @ObservedRealmObject var thisFrame: Frame
    @ObservedRealmObject var animation: Animation
    
    var body: some View {
        Button {
            try? realm.write {
                let thisAnimation = animation.thaw()
                let thisFrame = thisFrame.thaw()
                thisAnimation?.selectedFrame = thisFrame
            }
        } label: {
            Rectangle()
                .frame(width: 125, height: 100)
                .foregroundColor(.white)
                .shadow(radius: 5)
                .scaleEffect(thisFrame == animation.selectedFrame ? 1.3 : 1)
                .padding(thisFrame == animation.selectedFrame ? 20 : 0)
        }

        
    }
}

struct TimelineFrame_Previews: PreviewProvider {
    static var previews: some View {
        TimelineFrame(thisFrame: Frame(), animation: Animation())
    }
}
