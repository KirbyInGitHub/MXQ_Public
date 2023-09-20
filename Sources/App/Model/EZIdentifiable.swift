//
//  EZIdentifiable.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Foundation

public protocol EZIdentifiable: Equatable {
    
    associatedtype Identifier: Equatable
    
    var identifier: Identifier { get }
}

public func ==<I: EZIdentifiable>(lhs: I, rhs: I) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension Sequence where Iterator.Element: EZIdentifiable, Iterator.Element.Identifier: Hashable {
    
    public var idMapping: [Iterator.Element.Identifier: Iterator.Element] {
        
        var mapping: [Iterator.Element.Identifier: Iterator.Element] = [:]
        for element in self {
            mapping[element.identifier] = element
        }
        return mapping
    }
    
    public var idGrouping: [Iterator.Element.Identifier: [Iterator.Element]] {
        
        var grouping: [Iterator.Element.Identifier: [Iterator.Element]]  = [:]
        for element in self {
            let identifier = element.identifier
            var group: [Iterator.Element] = grouping[identifier] ?? []
            group.append(element)
            grouping[identifier] = group
        }
        return grouping
    }
}
