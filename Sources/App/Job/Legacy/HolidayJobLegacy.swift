//
//  HolidayJob.swift
//  
//
//  Created by 张鹏 on 2022/9/30.
//

import Vapor
import Queues

extension HolidayJobLegacy {
    
    func getHolidayLegacy(context: QueueContext) async throws -> BotMessage<Markdown> {
        
        let api = URI("http://api.tianapi.com/jiejiari/index?key=23640564bf27019f20151e95132c9a52&date=\(Date().tomorrow)")
        
        let resp = try await context.application.client.get(api)
        
        let holiday = try resp.content.get(Array<HolidayModel>.self, at: ["newslist"])
        
        guard let holiday = holiday.first, holiday.isnotwork == 1 else { throw Abort(.internalServerError) }
        
        //为0表示工作日、为1节假日、为2双休日、为3调休日（上班）
        var title: String {
            switch holiday.daycode {
            case 1: return holiday.now == 0 ? "小长假来袭: \(holiday.name) \(holiday.enname)" : ""
            case 2: return holiday.weekday == 6 ? "辛苦一周了，早点下班享受周末吧。" : ""
            default: return ""
            }
        }
        
        guard !title.isEmpty else { throw Abort(.internalServerError) }
        
        let md = """
        🏖️ **<font color="warning">\(title)</font>**
        
        >\(holiday.tip.isEmpty ? HolidayModel.tips.randomElement()! : holiday.tip)
        
        \(holiday.rest.isEmpty ? "" : ">\(holiday.rest)")
        """
        
        return try BotMessage<Markdown>.build(content: md)
    }
}

struct HolidayJobLegacy: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let h = try await getHolidayLegacy(context: context)
        try await context.application.bot.send( h, to: [.dragon, .nia])
    }
}

extension HolidayJobLegacy: JobCollection {
    
    static func boot(app: Application) {
        app.queues.schedule(Self.self())
            .using(Calendar.local)
            .daily()
            .at(06, 00, .pm)
    }
}
