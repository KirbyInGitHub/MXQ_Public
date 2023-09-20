@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testCreate() async throws {
        
//        let app = Application()
//        defer { app.shutdown() }
        
//        let event = TAPD.WebhookEvent(workspace: 31755764, event: .create, name: "测试企业微信需求和任务", story: "1131755764001219159", owner: ["pengchunxiao"])
//        
//        try await app.tapd.story.create(for: event)
//        
    }
    
//    func testContent() async throws {
//
//        let app = Application()
//        defer { app.shutdown() }
//
//        let list = try await app.tapd.task.list( member:  TeamMember.yaoqianying)
//
//        let tasks = list.filter { $0.begin == nil || $0.due == nil || $0.effort == nil }
//
//        let gg = tasks.map { t -> String in
//            return "> **\(t.name):** <font color=\"info\">\(t.status)</font> [查看](https://www.tapd.cn/\(t.workspace_id)/prong/tasks/view/\(t.id)) "
//        }
//
//        let m = """
//        ⚠️ **<font color=\"warning\">请及时更新以下任务排期&工时：</font>**
//        \(gg.joined(separator: "\n"))
//        """
//
//        let message = try AppMessage<Markdown>.build(toUser: TeamMember.yaoqianying, content: m)
//
//        try await app.mxq.send(message: message)
//    }
//
    

    
    func testTextCard() async throws {
        let app = Application()
        defer { app.shutdown() }
        
        let member = TeamMember.czz
        
        let input = TemplateCard.Input(icon:"https://t.rightinthebox.com/tights/litb/1uy4x6evagps0_tapd_ixintu.com.png", source: "TAPD", title: "你收到一个新任务！", text: "首页楼层类目跳转链接返回的是主站的url，前端打开是空白页", url: "https://www.tapd.cn/31755764/prong/tasks/view/\(31755764)")
        

        
        let message = try AppMessage<TemplateCard>.build(toUser: member, content: input)

        try await app.mxq.send(message: message)
    }
}
