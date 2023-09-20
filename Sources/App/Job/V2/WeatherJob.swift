//
//  WeatherJobV2.swift
//
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor
import Queues

struct WeatherJob: AsyncScheduledJob {

    func run(context: QueueContext) async throws {
        
        let sh = try await makeMessage(for: "101020600", context: context)
        try await context.application.mxq.sendChat(sh)
    }
}

extension WeatherJob {
    
    func makeMessage(for city: String, context: QueueContext) async throws -> ChatMessage<Markdown> {
        
        let api = URI(string: "http://api.tianapi.com/txapi/tianqi/index?key=23640564bf27019f20151e95132c9a52&city=\(city)&type=1")
        
        let resp = try await context.application.client.get(api)
        
        let weathers = try resp.content.get(Array<WeatherModel>.self, at: ["newslist"])
        
        guard let weather = weathers.first else { throw Abort(.internalServerError) }
        
        let w = """
        \(Date().string) \(weather.province) \(weather.area):
        
        \(weather.weather) \(weather.lowest) - \(weather.highest)
        \(weather.wind) \(weather.windsc)、空气质量 \(weather.quality ?? "挺好的")
        当前实时温度：\(weather.real)
        """
        
        let aicontext = try await context.application.ai.context(for: "mi-weather")
            .update(session: .init(role: .system, content: "接下来的对话中你将扮演一个名字叫米小圈的天气预报员，你的说话方式比较夸张。"))
            .update(session: .init(role: .user, content: w))
        
        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
        
        let md = """
        \(weather.icon) <font color="info">**\(weather.province) \(weather.area)**</font>

        >\(choice.message.content)
        """
        
        return try ChatMessage<Markdown>.build(content: md)
    }
}

extension WeatherJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(08, 30, .am)
        }
    }
}
