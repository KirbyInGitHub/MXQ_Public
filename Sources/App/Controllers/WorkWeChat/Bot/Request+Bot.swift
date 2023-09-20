//
//  Request+Bot.swift
//  
//
//  Created by 张鹏 on 2023/3/7.
//

import Vapor

extension Request {
    var bot: Bot {
        .init(req: self)
    }
}

