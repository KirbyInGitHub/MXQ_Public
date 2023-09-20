//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor
import Queues
import Redis

func queues(_ app: Application) throws {
    
    try app.queues.register(HolidayJobLegacy.self)
    try app.queues.register(OneJobLegacy.self)
    try app.queues.register(EatJob.self)
    try app.queues.register(WeatherJob.self)
    try app.queues.register(WorkJob.self)
    try app.queues.register(StoryJob.self)
    try app.queues.register(DragonWorkJob.self)
    try app.queues.register(DragonEatJob.self)
    
    try app.queues.register(TAPDTaskAlertJob.self)
    
    app.queues.add(ReplayMessageJob())
    app.queues.add(TAPDTasksJob())
    
    try app.queues.startInProcessJobs(on: .mxq)
    try app.queues.startInProcessJobs()
    try app.queues.startScheduledJobs()
}

let days: [ScheduleBuilder.Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]

extension Calendar {
    
    static let local: Calendar  = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return calendar
    }()
}

public protocol JobCollection {
    static func boot(app: Application) throws
}

extension Application.Queues {
    
    public func register<J>(_ job: J.Type) throws where J: JobCollection  {
        try job.boot(app: self.application)
    }
}

extension QueueName {
    static let mxq = QueueName(string: "mxq")
}
