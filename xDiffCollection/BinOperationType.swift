//
//  BinOperationType.swift
//  xDiffCollection
//
//  Created by Esteban Garro on 2018-06-11.
//  Copyright © 2018 transcriptics. All rights reserved.
//

internal enum BinOperationType {
    case updated
    case added
    case deleted
    case none
}

internal struct BinResult {
    var type: BinOperationType
    var idx : Int
}
