//
//  Task.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor

extension TAPD {
    
    var task: Task {
        return .init(app: app)
    }
    
    struct Task {

        let app: Application
        
        func modify(manDay: Double, for task: TAPDTask.Info, and member: TeamMember) async throws -> ClientResponse {
            
            guard let taskid = task.id else {
                throw Abort(.internalServerError, reason: "TAPD task id iEmpty!!!")
            }
            
            let api = URI(string: "https://api.tapd.cn/timesheets")
            
            let content = TAPDTask.Modify(id: taskid,
                                  timespent: String(format: "%.1f", manDay),
                                  workspace: task.workspace_id,
                                  spentdate: Date().string,
                                  type: "task",
                                  owner: member.tapdID)

            let resp = try await app.client.post(api) { req in
                req.headers.basicAuthorization = app.tapd.auth
                try req.content.encode(content, as: .json)
            }
            
            return resp

        }
    }
}

extension TAPD.Task {
    
    func list(storyid: String = "", member: TeamMember = .👽, name: String = "") async throws -> [TAPDTask.Info] {
        var api = URI(string: "https://api.tapd.cn/tasks")
        
        let queries = {
            if let id = Int(name) {
                return TAPDTask.Info(id: String(id),
                                     name: "",
                                     status: "open%7Cprogressing",
                                     effort: nil,
                                     workspace_id: TAPDProject.id(from: member),
                                     due: nil,
                                     owner: member.tapdID,
                                     story_id: storyid,
                                     creator: nil)
            } else {
                let e = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return TAPDTask.Info(id: "",
                                     name: e,
                                     status: "open%7Cprogressing",
                                     effort: nil,
                                     workspace_id: TAPDProject.id(from: member),
                                     due: nil,
                                     owner: member.tapdID,
                                     story_id: storyid,
                                     creator: nil)
            }
        }()
        
        
        
        api.query = try URLEncodedFormEncoder().encode(queries)

        let resp = try await app.client.get(api) { req in
            req.headers.basicAuthorization = app.tapd.auth
        }
        
        let list: [[String: TAPDTask.Info]] = try resp.content.get(at: ["data"])
        let tasks = list.flatMap { $0.values }.map { $0 }
        
        return tasks
    }
}

extension TAPD.Task {
    
    func create(for event: TAPD.WebhookStoryEvent) async throws -> [(TeamMember, String)] {
        
        guard let members = event.owner?.map({ TeamMember(identifiable: $0) }) else {
            throw Abort(.internalServerError, reason: "TAPD task owners iEmpty!!!")
        }
        
        let tasks = try await self.list(storyid: event.story)
        
        let aMembers = Set(tasks.map { $0.owner?.components(separatedBy: ";").map { TeamMember(identifiable: $0) } }.compactMap { $0 }.flatMap { $0 })
        
        var resps = [(TeamMember, String)]()
        
        for m in members where !aMembers.contains(m) && m != .👽 {
            let api = URI(string: "https://api.tapd.cn/tasks")
            
            let content = TAPDTask.Create(workspace: String(event.workspace),
                                          name: event.name,
                                          creator: m.tapdID,
                                          owner: m.tapdID,
                                          story: event.story)

            let resp = try await app.client.post(api) { req in
                req.headers.basicAuthorization = app.tapd.auth
                try req.content.encode(content, as: .json)
            }
            
            let status: Int = try resp.content.get(at: "status")
            let taskid: String = (try? resp.content.get(at: ["data", 0, "Task", "id"])) ?? ""
            
            if status == 1 {
                resps.append((m, taskid))
            }
        }
        return resps
    }
}

extension TAPD.Task {
    
    @discardableResult
    func update(for event: TAPD.WebhookStoryEvent) async throws -> [(TeamMember, String)] {
        //create new
        return try await self.create(for: event)
    }
}

extension TAPDProject {
    
    static func id(from member: TeamMember) -> String {
        return member.isAPPMember ? app.id : fe.id
    }
}


