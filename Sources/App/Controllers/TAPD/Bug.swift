//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/20.
//

import Vapor

extension TAPD {
    
    var bug: Bug {
        return .init(app: app)
    }
    
    struct Bug {
        let app: Application
        
        func alert(for event: WebhookBugEvent) async throws {
            
            guard let members = event.owner?.map({ TeamMember(identifiable: $0) }) else {
                throw Abort(.internalServerError, reason: "TAPD Bug alert member isEmpty!!!")
            }
            
            let msg = """
            ‼️**<font color="warning">你收到一个新BUG：</font>**‼️
            >`\(event.severity.name)` \(event.title) [查看](https://www.tapd.cn/\(event.workspace)/bugtrace/bugs/view?bug_id=\(event.id))
            """
            
            for m in members where m != .👽 {
                let message = try AppMessage<Markdown>.build(toUser: m, content: msg)
                try await app.mxq.send(message: message)
            }
        }
    }
}
