//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor
import Queues

struct TAPDTasksJob: AsyncJob {
    
    typealias Payload = WXTextMessage
    
    func dequeue(_ context: Queues.QueueContext, _ payload: WXTextMessage) async throws {

        let member = TeamMember(identifiable: payload.fromUserName)
        
        guard member != .👽 else {
            throw Abort(.internalServerError, reason: "TAPDTasksJob member iEmpty!!!")
        }

        let action = try MXQAction(m: payload.content)
        
        switch action {
        case .task(let a):
            switch a {
            case .list:
                try await list(context, member: member)
            case .new: break
            case .add:
                try await modify(context, member: member, content: payload.content)
            case .delete: break
            }
        default:
            throw Abort(.internalServerError, reason: "TAPDTasksJob action dont match!!!")
        }
    }
}

extension TAPDTasksJob {
    
    func list(_ context: Queues.QueueContext, member: TeamMember) async throws {
        
        let list = try await context.application.tapd.task.list(member: member)
        
        let gg = list.map { l -> String in
            return "> **\(l.name ?? ""):** <font color=\"info\">\(l.status)</font> [查看](https://www.tapd.cn/\(l.workspace_id)/prong/tasks/view/\(l.id ?? "")) <font color=\"comment\">\(l.id ?? "")</font> "
        }

        let m = """
        📝 **当前任务列表：**
        \(gg.joined(separator: "\n"))
        """
        
        let message = try AppMessage<Markdown>.build(toUser: member, content: m)
        
        try await context.application.mxq.send(message: message)
    }
}

extension TAPDTasksJob {
    
    func modify(_ context: Queues.QueueContext, member: TeamMember, content: String) async throws {
        
        guard let addIndex = content.lastIndex(of: "+"), let manDay = Double(content[addIndex..<content.endIndex]) else {
            let message = try AppMessage<Markdown>.build(toUser: member, content: "请输入正确的命令：/填工时 任务名称(关键字、ID）+N")
            try await context.application.mxq.send(message: message)
            return
        }
        
        let c = content.replacingOccurrences(of: "/填工时", with: "").replacingOccurrences(of: " ", with: "")

        let query = String(c[c.startIndex..<(c.lastIndex(of: "+") ?? c.endIndex)])
        
        let list = try await context.application.tapd.task.list(member: member, name: query)
        
        guard let task = list.first, list.count == 1 else {
            let message = try AppMessage<Markdown>.build(toUser: member, content: "任务查询失败，请输入更加准确的关键词！")
            try await context.application.mxq.send(message: message)
            return
        }
        
        let resp = try await context.application.tapd.task.modify(manDay: manDay, for: task, and: member)
        
        let status: Int = try resp.content.get(at: "status")
        let info: String = try resp.content.get(at: "info")
        
        let success = """
        任务：\(task.name ?? "") 工时**<font color="info">\(String(format: "%.1f", manDay))</font>** 更新成功！[查看](https://www.tapd.cn/\(task.workspace_id)/prong/tasks/view/\(task.id ?? ""))
        """
        
        let fail = """
        任务：\(task.name ?? "") 工时**<font color="info">\(String(format: "%.1f", manDay))</font>** 更新失败
        >原因：\(info)
        """
        
        let m = status == 1 ? success : fail
        let message = try AppMessage<Markdown>.build(toUser: member, content: m)
        try await context.application.mxq.send(message: message)
    }
}
