//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/11/25.
//

import Vapor

//struct Markdown: Content {
//    let content: String
//}

extension Double {
    
    var markdown: String {
        
        let color: String = {
            switch self {
            case 0..<1: return "warning"
            case 1: return "comment"
            case 1..<100: return "info"
            default: return "comment"}
        }()
        
        return "<font color=\"\(color)\">\(self.string1)d</font>"
    }
    
    var string1: String {
        return String(format: "%.1f", self)
    }
}

extension String {

    var format: String {
        let i = 3
        if self.count < i {
            return self + Array(repeating: "    ", count: (i - self.count)).joined()
        } else {
            return self
        }
    }
}




public struct CaseInsensitiveString: ExpressibleByStringLiteral, Hashable {

    let lowercaseString: String

    public init(_ string: String) {
        self.lowercaseString = string.lowercased()
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public func hash(into haser: inout Hasher) {
        haser.combine(self.lowercaseString)
    }
}

public func == (lhs: CaseInsensitiveString, rhs: CaseInsensitiveString) -> Bool {
    return lhs.lowercaseString == rhs.lowercaseString
}

public func ~= (string: String, cis: CaseInsensitiveString) -> Bool {
    return string.lowercased() == cis.lowercaseString
}
