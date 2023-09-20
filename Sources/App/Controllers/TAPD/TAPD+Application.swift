//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor

extension Application {
    var tapd: TAPD {
        .init(app: self)
    }
}

