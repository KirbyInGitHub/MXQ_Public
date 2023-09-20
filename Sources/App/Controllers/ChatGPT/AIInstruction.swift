//
//  AIInstruction.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

struct AIInstruction: Content {
    let instruction: String
    let model: String
    let input: String
}
