//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/24.
//

import Vapor

struct WXVerifyMessage: Content {
    
    let signature: String
    let timestamp: String
    let nonce: String
    let echostr: String?
    
    enum CodingKeys: String, CodingKey {
        case signature = "msg_signature"
        case timestamp
        case nonce
        case echostr
    }
}

struct WXEncryptMessage: Content {
    
    let toUserName: String
    let agentID: String
    let encrypt: String
    
    enum CodingKeys: String, CodingKey {
        case toUserName = "ToUserName"
        case agentID = "AgentID"
        case encrypt = "Encrypt"
    }
}

struct WXMessage: Content {
    
    enum MsgType: String, Content {
        case text
        case event
        case image
        case voice
        case video
        case location
    }
    
    let msgType: MsgType
    let fromUserName: String
    
    enum CodingKeys: String, CodingKey {
        case msgType = "MsgType"
        case fromUserName = "FromUserName"
    }
}

struct WXTextMessage: Content {
    let toUserName: String
    let fromUserName: String
    let createTime: Int
    let content: String
    let msgID: Int
    let agentID: Int
    
    enum CodingKeys: String, CodingKey {
        case toUserName = "ToUserName"
        case fromUserName = "FromUserName"
        case createTime = "CreateTime"
        case content = "Content"
        case msgID = "MsgId"
        case agentID = "AgentID"
    }
}

struct WXEventMessage: Content {
    let toUserName: String
    let fromUserName: String
    let createTime: Int
    let msgType: String
    let event: String
    let agentID: String
    
    enum CodingKeys: String, CodingKey {
        case toUserName = "ToUserName"
        case fromUserName = "FromUserName"
        case createTime = "CreateTime"
        case msgType = "MsgType"
        case event = "Event"
        case agentID = "AgentID"
    }
}

/*
 {
    "touser" : "UserID1|UserID2|UserID3",
    "toparty" : "PartyID1|PartyID2",
    "totag" : "TagID1 | TagID2",
    "msgtype": "markdown",
    "agentid" : 1,
    "markdown": {
         "content": "您的会议室已经预定，稍后会同步到`邮箱`
                                 >**事项详情**
                                 >事　项：<font color=\"info\">开会</font>
                                 >组织者：@miglioguan
                                 >参与者：@miglioguan、@kunliu、@jamdeezhou、@kanexiong、@kisonwang
                                 >
                                 >会议室：<font color=\"info\">广州TIT 1楼 301</font>
                                 >日　期：<font color=\"warning\">2018年5月18日</font>
                                 >时　间：<font color=\"comment\">上午9:00-11:00</font>
                                 >
                                 >请准时参加会议。
                                 >
                                 >如需修改会议信息，请点击：[修改会议信息](https://work.weixin.qq.com)"
    },
    "enable_duplicate_check": 0,
    "duplicate_check_interval": 1800
 }
 */

/*
 <xml>
    <ToUserName><![CDATA[toUser]]></ToUserName>
    <AgentID><![CDATA[toAgentID]]></AgentID>
    <Encrypt><![CDATA[msg_encrypt]]></Encrypt>
 </xml>
 
 
 <ToUserName><![CDATA[toUser]]></ToUserName>
 <FromUserName><![CDATA[fromUser]]></FromUserName>
 <CreateTime>1348831860</CreateTime>
 <MsgType><![CDATA[text]]></MsgType>
 <Content><![CDATA[this is a test]]></Content>
 <MsgId>1234567890123456</MsgId>
 <AgentID>1</AgentID>
</xml>
 */
