//
//  File.swift
//  File
//
//  Created by 张鹏 on 2021/7/20.
//
import Fluent
import Vapor

//struct SentryController: RouteCollection {
//    
//    func boot(routes: RoutesBuilder) throws {
//        let reserve = routes.grouped("sentry")
//        reserve.post("metric_alert", use: metric_alert)
//    }
//
//    func metric_alert(req: Request) async throws -> HTTPStatus {
//        req.logger.info("SentryController.metric_alert.request:\(req)")
//        
//        let data = try req.content.decode(MetricAlertModel.self)
//        req.logger.info("SentryController.metric_alert.request.data:\(data)")
//        
//        guard data.action != .resolved else {
//            return HTTPStatus.ok
//        }
//        
//        try await req.application.bot.send(data.makeMessage(), to: [.george])
//        return HTTPStatus.ok
//    }
//}
//
//extension MetricAlertModel {
//    
//    func makeMessage() throws -> BotMessage<Markdown> {
//        
//        let title = data.title.split(separator: ":").dropFirst().joined(separator: ":")
//        let desc = data.desc.split(separator: " ")
//        
//        var d = "\(desc.first ?? "")"
//        
//        if let fisrt = desc.first, let value = Double(fisrt) {
//            d = value <= 1 ? String(format: "%.2f", value * 100.0) + "%" : String(format: "%.2f", value)
//        }
//        
//        let md = """
//        \(action.emoji) <font color="\(action.color)">\(title)</font>
//
//        >当前值：\(d)
//        >[Sentry](\(data.url))
//        """
//
//        return try BotMessage<Markdown>.build(content: md)
//    }
//}
//
//
