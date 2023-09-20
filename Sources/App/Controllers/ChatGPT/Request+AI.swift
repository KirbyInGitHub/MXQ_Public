//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

extension Request {
    var ai: AI {
        .init(req: self)
    }
}


