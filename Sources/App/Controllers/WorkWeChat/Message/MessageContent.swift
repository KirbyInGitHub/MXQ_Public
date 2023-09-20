//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/7.
//

import Vapor

public protocol MessageContent: Content {
    static var attKey: String { get }
}

public struct Text: MessageContent {
    
    public static var attKey: String { return MsgType.text.rawValue }
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case content
    }
}

public struct Markdown: MessageContent {
    
    public static var attKey: String { return MsgType.markdown.rawValue }
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case content
    }
    
    public init(content: String) {
        self.content = content
    }
}

public struct News: MessageContent {
    
    public static var attKey: String { return MsgType.news.rawValue }
    public var content: [Item] = []
    
    enum CodingKeys: String, CodingKey {
        case content = "articles"
    }
    
    public struct Item: Content {
        let title: String
        let description: String
        let url: String
        let picurl: String
    }
}

public struct TextCard: MessageContent {
    
    public static var attKey: String { return MsgType.textcard.rawValue }
    let title: String
    let description: String
    let url: String
    let btntxt: String
}

public struct TemplateCard: MessageContent {
    
    public static var attKey: String { return MsgType.template_card.rawValue }
    
    let type: String
    let source: Source
    let title: Main
    let jumps: [JumpList]
    let action: Action
    let quote: Quote
    
    enum CodingKeys: String, CodingKey {
        case type = "card_type"
        case source
        case title = "main_title"
        case jumps = "jump_list"
        case action = "card_action"
        case quote = "quote_area"
    }
    
    struct Input: Content {
        let icon: String
        let source: String
        let title: String
        let text: String
        let url: String
    }
    
    struct Source: Content {
        let icon: String
        let desc: String
        let color: Int
        
        enum CodingKeys: String, CodingKey {
            case icon = "icon_url"
            case desc
            case color = "desc_color"
        }
    }
    
    struct Main: Content {
        let title: String
        let desc: String
    }
    
    struct JumpList: Content {
        var type: Int = 1
        let title: String
        let url: String
    }
    
    struct Action: Content {
        var type: Int = 1
        let url: String
    }
    
    struct Quote: Content{
        let type: Int = 0
        let title: String
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case type
            case title
            case text = "quote_text"
        }
    }
}


extension BotMessage where C == Text {
    
    static func build(content: String) throws -> BotMessage<Text> {
        return BotMessage<Text>(content: Text(content: content))
    }
}

extension BotMessage where C == Markdown {
    
    static func build(content: String) throws -> BotMessage<Markdown> {
        return BotMessage<Markdown>(content: Markdown(content: content))
    }
}

extension BotMessage where C == News {
    
    static func build(content: [News.Item]) throws -> BotMessage<News> {
        return BotMessage<News>(content: News(content: content))
    }
}

extension ChatMessage where C == Text {
    
    static func build(chatid: String = ChatID, content: String) throws -> ChatMessage<Text> {
        return ChatMessage<Text>(chatid: chatid, content: Text(content: content))
    }
}

extension ChatMessage where C == Markdown {
    
    static func build(chatid: String = ChatID, content: String) throws -> ChatMessage<Markdown> {
        return ChatMessage<Markdown>(chatid: chatid, content: Markdown(content: content))
    }
}

extension ChatMessage where C == News {
    
    static func build(chatid: String = ChatID, content: [News.Item]) throws -> ChatMessage<News> {
        return ChatMessage<News>(chatid: chatid, content: News(content: content))
    }
}

extension AppMessage where C == Markdown {
    
    static func build(toUser: String, content: String) throws -> AppMessage<Markdown> {
        return AppMessage<Markdown>(toUser: toUser, content: Markdown(content: content))
    }
    
    static func build(toUser: TeamMember, content: String) throws -> AppMessage<Markdown> {
        guard toUser != .👽 else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        return try self.build(toUser: toUser.wxID, content: content)
    }
}

extension AppMessage where C == Text {
    
    static func build(toUser: String, content: String) throws -> AppMessage<Text> {
        return AppMessage<Text>(toUser: toUser, content: Text(content: content))
    }
    
    static func build(toUser: TeamMember, content: String) throws -> AppMessage<Text> {
        guard toUser != .👽 else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        return try self.build(toUser: toUser.wxID, content: content)
    }
}

extension AppMessage where C == TextCard {
    
    static func build(toUser: TeamMember, content: TextCard) throws -> AppMessage<TextCard> {
        guard toUser != .👽 else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        return AppMessage<TextCard>(toUser: toUser.wxID, content: content)
    }
}


extension AppMessage where C == TemplateCard {
    
    static func build(toUser: TeamMember, content: TemplateCard.Input) throws -> AppMessage<TemplateCard> {
        guard toUser != .👽 else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        let t = TemplateCard(type: "text_notice",
                             source: .init(icon: content.icon, desc: content.source, color: 3),
                             title: .init(title: content.title, desc: ""),
                             jumps: [.init(title: "查看", url: content.url)],
                             action: .init(url: content.url),
                             quote: .init(title: "", text: content.text))
        return AppMessage<TemplateCard>.init(toUser: toUser.wxID, content: t)
    }
}
