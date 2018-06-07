//
//  CollectionTestObjectMock.swift
//  CollectionTestTests
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 transcriptics. All rights reserved.
//

import Foundation

enum ObjectStatus {
    case new
    case old
    case hot
    case cold
    case other
}

struct CollectionTestObjectMock: Hashable, Equatable {
    var value : String
    var status: ObjectStatus
    
    var hashValue : Int {
        return value.hashValue
    }
    
    static func == (lhs: CollectionTestObjectMock, rhs: CollectionTestObjectMock) -> Bool {
        return  lhs.hashValue == rhs.hashValue &&
                lhs.status    == rhs.status
    }
    
    init(value:String) {
        self.value = value
        self.status = .new
    }
}
