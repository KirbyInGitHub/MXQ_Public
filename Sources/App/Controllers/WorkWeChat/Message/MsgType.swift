//
//  BotMessageType.swift
//  
//
//  Created by 张鹏 on 2023/3/7.
//

import Vapor

public enum MsgType: String, Content {
    case text
    case markdown
    case image
    case file
    case news
    case textcard
    case template_card
}
