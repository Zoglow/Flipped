//
//  Animation.swift
//  Flipped
//
//  Created by Zoe Olson on 9/25/23.
//

import Foundation
import RealmSwift
import PencilKit

final class Animation: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var createdDate = Date()
    @Persisted var title = "Untitled animation"
    
    @Persisted var frames = RealmSwift.List<Frame>()
    @Persisted var selectedFrame: Frame?

}


