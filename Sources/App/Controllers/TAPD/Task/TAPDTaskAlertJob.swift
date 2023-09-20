//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/17.
//

import Vapor
import Queues

struct TAPDTaskAlertJob: AsyncScheduledJob {
    
    func run(context: Queues.QueueContext) async throws {
        
        for member in TeamMember.all {
            
            let list = try await context.application.tapd.task.list(member: member)
            
            let tasks = list.filter { $0.begin == nil || $0.due == nil || $0.effort == nil }
            
            let gg = tasks.map { t -> String in
                return "> **\(t.name ?? "未知"):** <font color=\"info\">\(t.status)</font> [查看](https://www.tapd.cn/\(t.workspace_id)/prong/tasks/view/\(t.id ?? "")) "
            }

            let m = """
            ⚠️‼️ **<font color=\"warning\">请及时更新以下任务排期&工时：</font>**
            \(gg.joined(separator: "\n"))
            """
            
            let message = try AppMessage<Markdown>.build(toUser: member, content: m)
            
            try await context.application.mxq.send(message: message)
        }
    }
}

extension TAPDTaskAlertJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(10, 30, .am)
        }
    }
}
