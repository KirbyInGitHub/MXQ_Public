//
//  Database.swift
//  
//
//  Created by 张鹏 on 2021/3/15.
//

import Vapor
import Fluent
import FluentMySQLDriver

func database(_ app: Application) throws {

    app.databases.use(.mysql(
        hostname: "localhost",
        port: 3306,
        username: "zp",
        password: "Zp19880220.",
        database: "shinchan",
        tlsConfiguration: nil
    ), as: .mysql)
    
    app.migrations.add(ExtMember.create)
    app.migrations.add(ExtMember.UpdateV1())
    app.migrations.add(VipCard.Create())
    app.migrations.add(VipCard.Update())
    try app.autoMigrate().wait()
}
