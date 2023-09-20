//
//  GitlabModel.swift
//  
//
//  Created by 张鹏 on 2022/4/25.
//

import Foundation
import Vapor

struct ContributionEvents: Content {
    
    let id: Int
    let project_id: Int
    let action_name: String
    let created_at: String
    let author_username: String
}

extension ContributionEvents: EZIdentifiable {
    
    var identifier: TeamMember {
        return TeamMember(identifiable: author_username)
    }
    
    var event_created_at: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let date = formatter.date(from: created_at)
        return date ?? Date()
    }
    
    var event_created_at_ft: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        return formatter.string(from: event_created_at)
//        return event_created_at.formatted(date: .omitted, time: .shortened) //构建报错
    }
    
    var event_created_at_Date_ft: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        return formatter.string(from: event_created_at)
//        return event_created_at.formatted(date: .omitted, time: .shortened) //构建报错
    }
    
    static var afterOfDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else {
            return ""
        }
        return formatter.string(from: date)
    }
    
    static var beforeOfDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    static var last7days:(begin:String, end:String) {
        var begin: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = Calendar.current.date(byAdding: .day, value: -6, to: Date()) else {
                return ""
            }
            return formatter.string(from: date)
        }
        
        var end: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
                return ""
            }
            return formatter.string(from: date)
        }
        return (begin, end)
    }
}
