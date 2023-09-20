//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/25.
//

import Vapor
import Fluent

public final class VipCard: Model {
    
    public static let schema = "vip_card"
    
    @ID(custom: .id)
    public var id: Int?
    
    @Field(key: "number")
    public var number: String
    
    @Field(key: "used")
    public var used: Bool
    
    @Enum(key: "member_level")
    public var level: ExtMember.Level
    
    @Field(key: "used_member")
    public var member: String?
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    public var updatedAt: Date?
    
    public init() { }
    
    init(id: Int? = nil, number: String, used: Bool, level: ExtMember.Level) {
        self.id = id
        self.number = number
        self.used = used
        self.level = level
    }
}

extension VipCard {
    
    struct Create: AsyncMigration {
        
        func revert(on database: FluentKit.Database) async throws {
            
        }
        
        func prepare(on database: FluentKit.Database) async throws {
            let level = try await database.enum("member_level").read()

            try await database.schema(VipCard .schema)
                .field(.id, .int, .identifier(auto: true), .required)
                .field("number", .string, .required)
                .field("used", .bool, .required)
                .field("member_level", level, .required)
                .field("created_at", .string, .required)
                .field("updated_at", .string, .required)
                .unique(on: "number")
                .create()
        }
    }
    
    struct Update: AsyncMigration {
        
        func revert(on database: FluentKit.Database) async throws {
            
        }
        
        func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(VipCard .schema)
                .field("used_member", .string)
                .update()
        }
    }
}
