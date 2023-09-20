//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/15.
//

import Vapor

struct Bot {
    
    let app: Application
    
    init(req: Request) {
        self.init(app: req.application)
    }
    
    init(app: Application) {
        self.app = app
    }
}

extension Bot {
    
    enum name {
        case dog, dragon, app, firoa, xiu, nia, george, mi
        
        var webhook: URI {
            switch self {
            case .dog:
                return URI(string: "删")
            case .dragon:
                return URI(string: "删")
            case .app:
                return URI(string: "删")
            case .firoa:
                return URI(string: "删")
            case .xiu:
                return URI(string: "删")
            case .nia:
                return URI(string: "删")
            case .george:
                return URI(string: "删")
            case .mi:
                return URI(string: "删")
            }
        }
        
        var nick: String {
            switch self {
            case .dog: return ""
            case .dragon: return "斑点龙"
            case .app: return ""
            case .firoa: return ""
            case .xiu: return "一休"
            case .nia: return "Nia"
            case .george: return "乔治"
            case .mi: return "米小圈"
            }
        }
    }
}



extension Bot {

    public func send<C: MessageContent>(_ message: BotMessage<C>, to bots: [Bot.name]) async throws {
        
        for bot in bots {
            let resp = try await app.client.post(bot.webhook, content: message)
            self.app.logger.info("\(resp)")
        }
    }
    
    public func send<C: MessageContent>(_ message: BotMessage<C>, to bots: [String]) async throws {
        
        for bot in bots {
            let resp = try await app.client.post(URI(string: bot), content: message)
            self.app.logger.info("\(resp)")
        }
    }
}

extension Date {
    
    var string: String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
//        dformatter.calendar =  Calendar(identifier: Calendar.Identifier.iso8601)
        
        return dformatter.string(from: self)
    }
}

/// Subtracts two dates and returns the relative components from `lhs` to `rhs`.
/// Follows this mathematical pattern:
///     let difference = lhs - rhs
///     rhs + difference = lhs
public func - (lhs: Date, rhs: Date) -> DateComponents {
    Calendar(identifier: .gregorian).dateComponents(DateComponents.allComponentsSet, from: rhs, to: lhs)
}

public func + (lhs: Date, rhs: DateComponents) -> Date {
    rhs.from(lhs)!
}

public func + (lhs: DateComponents, rhs: Date) -> Date {
    (rhs + lhs)
}

//public func - (lhs: Date, rhs: DateComponents) -> Date {
//    (lhs + (-rhs))
//}

public func + (lhs: Date, rhs: TimeInterval) -> Date {
    lhs.addingTimeInterval(rhs)
}

public extension DateComponents {

    internal static let allComponents: [Calendar.Component] =  [.nanosecond, .second, .minute, .hour,
                                                                .day, .month, .year, .yearForWeekOfYear,
                                                                .weekOfYear, .weekday, .quarter, .weekdayOrdinal,
                                                                .weekOfMonth]
    

    static var allComponentsSet: Set<Calendar.Component> {
        return [.era, .year, .month, .day, .hour, .minute,
                .second, .weekday, .weekdayOrdinal, .quarter,
                .weekOfMonth, .weekOfYear, .yearForWeekOfYear,
                .nanosecond, .calendar, .timeZone]
    }
    
    func from(_ date: Date) -> Date? {
       return  Calendar.current.date(byAdding: self, to: date)
    }
    
}

extension Int {
    
    internal func toDateComponents(type: Calendar.Component) -> DateComponents {
        var dateComponents = DateComponents()
        DateComponents.allComponents.forEach( { dateComponents.setValue(0, for: $0 )})
        dateComponents.setValue(self, for: type)
        dateComponents.setValue(0, for: .era)
        return dateComponents
    }
    
    var days: DateComponents {
        toDateComponents(type: .day)
    }
}
