//
//  TAPDProject.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor

enum TAPDProject: String, Content {
    
    case app
    case fe
    case qa
    case product
    case backend
    case 🌀
    
    var name: String {
        switch self {
        case .app: return "APP"
        case .fe: return "FE"
        case .qa: return "QA"
        case .product: return "Product"
        case .backend: return "Backend"
        case .🌀: return "🌀"
        }
    }
    
    var id: String {
        switch self {
        case .app: return ""
        case .fe: return ""
        case .qa: return ""
        case .product: return ""
        case .backend: return ""
        case .🌀: return ""
        }
    }
    
    init(id: String?) {
        guard let id = id else { self = .🌀; return }

        switch CaseInsensitiveString(id) {
        case TAPDProject.app.id:
            self = .app
        case TAPDProject.fe.id:
            self = .fe
        case TAPDProject.qa.id:
            self = .qa
        case TAPDProject.product.id:
            self = .product
        case TAPDProject.backend.id:
            self = .backend
        default:
            self = .🌀
        }
    }
}
