//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/20.
//

import Vapor

extension TAPD {
    
    var story: Story {
        return .init(app: app)
    }
    
    struct Story {

        let app: Application


    }
}
