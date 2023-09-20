//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/26.
//

import Vapor

enum TeamMember: Content {
    
    case czz
    
    case 👽

    init(identifiable: String?) {
        guard let identifiable = identifiable else { self = .👽; return }

        switch CaseInsensitiveString(identifiable) {
        case TeamMember.czz.gitID,
            TeamMember.czz.tapdID,
            TeamMember.czz.wxID,
            TeamMember.czz.name:
            self = .czz

        default:
            self = .👽
        }
    }
}

extension TeamMember {
    
    static var all: [TeamMember] {
        return APP.all + FE.all
    }
    
    struct APP {
        static var all: [TeamMember] {
            return [.czz
            ]
        }
        
        static var project: TAPDProject = .app
    }
    
    struct FE {
        static var all: [TeamMember] {
            return []
        }
        
        static var project: TAPDProject = .fe
    }

}

extension TeamMember {
    
    var name: String {
        switch self {
        case .czz: return "菜zz"

        case .👽: return "👽"
        
            
        }
    }
}

extension TeamMember {
    
    var tapdID: String {
        switch self {
        case .czz: return "zhangpeng"
            
        case .👽: return "👽"
        }
    }
}

extension TeamMember {
    
    var gitID: String {
        switch self {
        case .czz: return "zhangpeng"

        case .👽: return "👽"
        }
    }
}

extension TeamMember {
    
    var wxID: String {
        switch self {
        case .czz: return "E0736"

        case .👽: return "👽"
        }
    }
}

extension TeamMember {
    
    var isAPPMember: Bool {
        return Set(TeamMember.APP.all).contains(self)
    }

    var isFEMember: Bool {
        return Set(TeamMember.FE.all).contains(self)
    }
}
