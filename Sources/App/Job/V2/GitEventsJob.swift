//
//  GitEventsJob.swift
//  
//
//  Created by 张鹏 on 2022/4/25.
//

import Vapor
import Queues

extension Application {
    
    func getGitEvents(for user: TeamMember, afterOfDate: String, beforeOfDate: String) async throws -> [ContributionEvents] {

        let api = URI(string:"https://git.ezbuy.me/api/v4/users/\(user.gitID)/events?after=\(afterOfDate)&&before=\(beforeOfDate)&per_page=100")
        
        let resp = try await client.get(api) { req in
            req.headers.add(name: "PRIVATE-TOKEN", value: "zWCHUVXkdmzMt_PCWoTE")
        }
        return try resp.content.decode([ContributionEvents].self)
    }
    
    func getGitEvents() async throws -> BotMessage<Markdown> {

        var resps = [ContributionEvents]()
        for m in TeamMember.all {
            let resp =  try await self.getGitEvents(for: m, afterOfDate: ContributionEvents.afterOfDate, beforeOfDate: ContributionEvents.beforeOfDate)
            resps.append(contentsOf: resp)
        }
        
        let events = resps.compactMap { $0 }.sorted { $0.created_at < $1.created_at }
         
        guard let f = events.first, let l = events.last else { throw Abort(.internalServerError) }

        let ft = f.event_created_at_ft
        let fm = f.identifier.name
        
        let lt = l.event_created_at_ft
        let lm = l.identifier.name
        
        let groups = resps.compactMap { $0 }.idGrouping
        
        let mvp = groups.sorted { $0.value.count > $1.value.count }.first
        
        
        let m = """
        🖥 **昨日Gitlab榜单**
        
        > **最早提交: **
        > <font color="warning">\(fm)</font> : <font color="warning">\(ft)</font>

        > **最晚提交: **
        > <font color="warning">\(lm)</font> : <font color="warning">\(lt)</font>
        
        > **昨日Git最多提交: **
        > <font color="info">\(mvp?.key.name ?? "🐞")</font> : <font color="info">\(mvp?.value.count ?? 0)次</font>  🎉🎉🎉
        """
        
        
        return try BotMessage<Markdown>.build(content: m)
    }
    
    func getAllGitEvents() async throws -> BotMessage<Markdown> {
        
        var resps = [ContributionEvents]()
        for m in TeamMember.all {
            let resp =  try await self.getGitEvents(for: m, afterOfDate: ContributionEvents.afterOfDate, beforeOfDate: ContributionEvents.beforeOfDate)
            resps.append(contentsOf: resp)
        }
        
        //按人分组
        let groups = resps.idGrouping
        
        let gg = groups.map { dict -> String in
            
            let ft = dict.value.last?.event_created_at_ft ?? ""
            let lt = dict.value.first?.event_created_at_ft ?? ""
        
            return "> **\(dict.key.name): ** 最早 <font color=\"warning\">\(ft)</font>, 最晚 <font color=\"warning\">\(lt)</font>, 总次数 <font color=\"info\">\(dict.value.count)</font>次"
        }

        let m = """
        🖥 **昨日Gitlab提交情况：**
        \(gg.joined(separator: "\n"))
        """
        
        return try BotMessage<Markdown>.build(content: m)
        
    }
}

extension Application {
    
    func getWeekGitEvents() async throws -> [BotMessage<Markdown>] {
        
        var resps = [ContributionEvents]()
        for m in TeamMember.all {
            let resp =  try await self.getGitEvents(for: m, afterOfDate: ContributionEvents.last7days.begin, beforeOfDate: ContributionEvents.last7days.end)
            resps.append(contentsOf: resp)
        }
        
        //按人分组
        let groups = resps.idGrouping
        
        var message: [String] = []
        
        //再按日期分组，输出结果
        for group in groups {
            let grouped = Dictionary(grouping: group.value, by: { $0.event_created_at_Date_ft })
            
            let sorted = grouped.sorted { $0.key < $1.key }
            
            var membersCommits: [String] = []
            
            for d in sorted {
                let values = d.value.sorted { $0.event_created_at < $1.event_created_at }
                let ft = values.first?.event_created_at_ft ?? ""
                let lt = values.last?.event_created_at_ft ?? ""
                
                let membersCommit = "\(d.key.featureWeekday()) 最早 <font color=\"warning\">\(ft)</font>, 最晚 <font color=\"warning\">\(lt)</font>, 总次数 <font color=\"info\">\(d.value.count)</font>次"
                
                membersCommits.append(membersCommit)
            }
            
            let commits = """
            > **\(group.key.name): **
            \(membersCommits.joined(separator: "\n"))
            """
            
            message.append(commits)
        }

        return message.map { try! BotMessage<Markdown>.build(content: $0) }
    }
}

struct GitEventsJob: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let events = try await context.application.getGitEvents()
        try await context.application.bot.send( events, to: [.mi])
    }
}

struct AllGitEventsJob: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let events = try await context.application.getAllGitEvents()
        try await context.application.bot.send( events, to: [.xiu])
    }
}

struct WeekGitEventsJob: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let events = try await context.application.getWeekGitEvents()
        
        let m = """
        🖥 **本周Gitlab提交情况：**
        """
        
        try await context.application.bot.send(BotMessage<Markdown>.build(content: m), to: [.xiu])
        
        for event in events {
            try await context.application.bot.send( event, to: [.xiu])
        }
    }
}

extension Date {
    
    var tomorrow: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: self) else {
            return ""
        }
        return formatter.string(from: date)
    }

}

extension String {
    
    func featureWeekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let formatDate = dateFormatter.date(from: self) else { return "" }
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: formatDate)
        switch weekDay {
        case 1:
            return "周日"
        case 2:
            return "周一"
        case 3:
            return "周二"
        case 4:
            return "周三"
        case 5:
            return "周四"
        case 6:
            return "周五"
        case 7:
            return "周六"
        default:
            return ""
        }
    }
}
