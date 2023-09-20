//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/23.
//

import Vapor

extension MXQController {
    
    func receivedTAPDWebhook(req: Request) async throws -> ClientResponse {
        
        let event: TAPD.WebhookType = try req.content.get(at: ["event", "event_key"])
        req.logger.info("MXQ received tapd webhook: \(event)")
        
        switch event {
        case .create:
            let event: TAPD.WebhookStoryEvent = try req.content.get(at: "event")
            try await create(req: req, for: event)
            
        case .update:
            let event: TAPD.WebhookStoryEvent = try req.content.get(at: "event")
            try await req.application.tapd.task.update(for: event)
        case .bug:
            let event: TAPD.WebhookBugEvent = try req.content.get(at: "event")
            try await req.application.tapd.bug.alert(for: event)
        }
        
        return .init()
    }
    
    private func create(req: Request, for event: TAPD.WebhookStoryEvent) async throws {
        
        let resps = try await req.application.tapd.task.create(for: event)
        
        for resp in resps {
            
            let member = resp.0
            let taskid = resp.1
            
            let input = TemplateCard.Input(icon:"https://t.rightinthebox.com/tights/litb/1uy4x6evagps0_tapd_ixintu.com.png",
                                           source: "TAPD",
                                           title: "你收到一个新任务！",
                                           text: event.name,
                                           url: "https://www.tapd.cn/\(event.workspace)/prong/tasks/view/\(taskid)")

            let message = try AppMessage<TemplateCard>.build(toUser: member, content: input)
            try await req.application.mxq.send(message: message)
        }
    }
}
