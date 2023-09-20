//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/7.
//

import Vapor

extension Application {
    var bot: Bot {
        .init(app: self)
    }
}
