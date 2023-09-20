//
//  TAPD.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor

struct TAPD {
    let app: Application
    let auth = BasicAuthorization(username: "", password: "")
}


