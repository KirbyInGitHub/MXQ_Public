//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/17.
//

import Vapor

public struct ChatMessage<C>: Content where C: MessageContent {
    
    let chatid: String
    let msgtype: MsgType
    let content: C
    
    init(chatid: String, content: C) {
        self.chatid = chatid
        self.msgtype = MsgType(rawValue: C.attKey) ?? .text
        self.content = content
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        chatid = try values.decode(String.self, forKey: .chatid)
        msgtype = try values.decode(MsgType.self, forKey: .msgtype)
        content = try values.decode(C.self, forKey: .content)
     }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chatid, forKey: .chatid)
        try container.encode(msgtype, forKey: .msgtype)
        try container.encode(content, forKey: .content)
    }
}

extension ChatMessage {
    
    struct CodingKeys: CodingKey {
        
        var stringValue: String
        var intValue: Int? = nil

        init?(intValue: Int) { return nil }

        init?(stringValue: String) {
          
            guard stringValue == C.attKey ||
            stringValue == DefaultCodingKeys.msgtype.rawValue ||
            stringValue == DefaultCodingKeys.chatid.rawValue else {
                return nil
            }
            self.stringValue = stringValue
        }

        enum DefaultCodingKeys: String, CodingKey {
            case msgtype
            case chatid
        }
        
        static var chatid: CodingKeys {
            return CodingKeys(stringValue:  DefaultCodingKeys.chatid.rawValue)!
        }
        
        static var content: CodingKeys {
            return CodingKeys(stringValue: C.attKey)!
        }

        static var msgtype: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.msgtype.rawValue)!
        }
    }
}

