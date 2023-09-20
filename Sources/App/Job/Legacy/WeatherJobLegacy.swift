//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor
import Queues

extension WeatherJobLegacy {

    func getWeatherLegacy(for city: String, context: QueueContext) async throws -> BotMessage<Markdown> {
        
        let api = URI(string: "http://api.tianapi.com/txapi/tianqi/index?key=23640564bf27019f20151e95132c9a52&city=\(city)&type=1")
        
        let resp = try await context.application.client.get(api)
        
        let weathers = try resp.content.get(Array<WeatherModel>.self, at: ["newslist"])
        
        guard let weather = weathers.first else { throw Abort(.internalServerError) }
        
        let alarm: String = {
            guard let alarm = weather.alarmlist?.first else { return ""}
            
            let s = """
            **\(alarm.level)\(alarm.type)预警：**
            > <font color="comment">\(alarm.content)</font>
            """
            
            return s
        }()
        
        let m = """
        \(weather.icon) <font color="info">**\(weather.province) \(weather.area)**</font>
        
        ><font color="warning">今日：\(weather.weather) \(weather.lowest) - \(weather.highest)</font>
        ><font color="warning">\(weather.wind) \(weather.windsc)、降雨概率 \(weather.pop ?? "0")%、空气质量 \(weather.quality ?? "挺好的")</font>
        ><font color="warning">当前实时温度：\(weather.real)</font>

        **小贴士：**
        > <font color="comment">\(weather.tips.isEmpty ? "疫情防控不松懈，出门请佩戴口罩。" : weather.tips)</font>
        
        \(alarm)
        """
        
        return try BotMessage<Markdown>.build(content: m)
    }
}

struct WeatherJobLegacy: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let sz = try await getWeatherLegacy(for: "101280601", context: context)
        try await context.application.bot.send( sz, to: [.nia])
        
    }
}

extension WeatherJobLegacy: JobCollection {
    
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
