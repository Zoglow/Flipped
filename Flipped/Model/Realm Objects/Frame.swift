//
//  Frame.swift
//  Flipped
//
//  Created by Zoe Sosa on 9/25/23.
//

import Foundation
import RealmSwift
import PencilKit

final class Frame: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var frameData = PKDrawing().dataRepresentation()
//    @Persisted var isSelected = true
    
    @Persisted(originProperty: "frames") var animation: LinkingObjects<Animation>
    
}
