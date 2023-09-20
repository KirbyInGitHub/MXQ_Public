//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/22.
//

import Vapor

public struct AppMessage<C>: Content where C: MessageContent {

    let toUser: String
    let toParty: String
    let msgtype: MsgType
    let agentID: Int
    let content: C
    let duplicateCheck: Int
    let duplicateCheckInterval: Int
    
    init(toUser: String, content: C) {
        self.toUser = toUser
        self.msgtype = MsgType(rawValue: C.attKey) ?? .text
        self.content = content
        self.toParty = ""
        self.agentID = AgentID
        self.duplicateCheck = 0
        self.duplicateCheckInterval = 1800
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        toUser = try values.decode(String.self, forKey: .toUser)
        msgtype = try values.decode(MsgType.self, forKey: .msgtype)
        content = try values.decode(C.self, forKey: .content)
        toParty = try values.decode(String.self, forKey: .toParty)
        agentID = try values.decode(Int.self, forKey: .agentID)
        duplicateCheck = try values.decode(Int.self, forKey: .duplicateCheck)
        duplicateCheckInterval = try values.decode(Int.self, forKey: .duplicateCheckInterval)
     }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toUser, forKey: .toUser)
        try container.encode(msgtype, forKey: .msgtype)
        try container.encode(toParty, forKey: .toParty)
        try container.encode(agentID, forKey: .agentID)
        try container.encode(duplicateCheck, forKey: .duplicateCheck)
        try container.encode(duplicateCheckInterval, forKey: .duplicateCheckInterval)
        try container.encode(content, forKey: .content)
    }
}

extension AppMessage {
    
    struct CodingKeys: CodingKey {
        
        var stringValue: String
        var intValue: Int? = nil

        init?(intValue: Int) { return nil }

        init?(stringValue: String) {
          
            guard stringValue == C.attKey ||
            stringValue == DefaultCodingKeys.msgtype.rawValue ||
            stringValue == DefaultCodingKeys.toUser.rawValue ||
            stringValue == DefaultCodingKeys.toParty.rawValue ||
            stringValue == DefaultCodingKeys.agentID.rawValue ||
            stringValue == DefaultCodingKeys.duplicateCheck.rawValue ||
            stringValue == DefaultCodingKeys.duplicateCheckInterval.rawValue else {
                return nil
            }
            self.stringValue = stringValue
        }

        enum DefaultCodingKeys: String, CodingKey {
            case msgtype
            case toUser = "touser"
            case toParty = "toparty"
            case agentID = "agentid"
            case duplicateCheck = "enable_duplicate_check"
            case duplicateCheckInterval = "duplicate_check_interval"
        }
        
        static var toUser: CodingKeys {
            return CodingKeys(stringValue:  DefaultCodingKeys.toUser.rawValue)!
        }
        
        static var content: CodingKeys {
            return CodingKeys(stringValue: C.attKey)!
        }

        static var msgtype: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.msgtype.rawValue)!
        }
        
        static var toParty: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.toParty.rawValue)!
        }
        
        static var agentID: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.agentID.rawValue)!
        }
        
        static var duplicateCheck: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.duplicateCheck.rawValue)!
        }
        
        static var duplicateCheckInterval: CodingKeys {
            return CodingKeys(stringValue: DefaultCodingKeys.duplicateCheckInterval.rawValue)!
        }
    }
}

