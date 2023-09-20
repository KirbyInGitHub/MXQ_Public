//
//  MXQ+Application.swift
//  
//
//  Created by 张鹏 on 2023/3/16.
//

import Vapor

extension Application {
    var mxq: MXQ {
        .init(app: self)
    }
}


