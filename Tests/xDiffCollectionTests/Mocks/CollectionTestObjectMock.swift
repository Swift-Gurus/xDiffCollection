//
//  CollectionTestObjectMock.swift
//  CollectionTestTests
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
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
    var value: String
    var status: ObjectStatus
    var rank: Int

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(rank)
    }
    
    static func == (lhs: CollectionTestObjectMock, rhs: CollectionTestObjectMock) -> Bool {
        lhs.status  == rhs.status
    }

    init(value: String,
         status: ObjectStatus = .new,
         rank: Int = 0) {
        
        self.value = value
        self.status = status
        self.rank = rank
    }
}
