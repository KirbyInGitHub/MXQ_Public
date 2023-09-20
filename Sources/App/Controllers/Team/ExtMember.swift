//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/24.
//

import Vapor
import Fluent

extension FieldKey {
    static var wxID: FieldKey { return "wx_id" }
}

public final class ExtMember: Model {
    
    public static let schema = "ext_member"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: .wxID)
    public var wxID: String
    
    @Enum(key: "member_level")
    public var level: Level

    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    public var updatedAt: Date?
    
    @Timestamp(key: "ends_at", on: .none, format: .iso8601)
    public var endsAt: Date?
    
    required public init() { }
    
    public init(id: UUID? = nil, name: String, wxID: String, level: Level, endsAt: Date? = nil) {
        self.id = id
        self.name = name
        self.wxID = wxID
        self.level = level
        self.endsAt = endsAt
    }
}

extension ExtMember {
    
    public enum Level: String, Codable {
        case block
        case trial
        case vip
        case vvvip
    }
}

extension ExtMember.Level {
    
    var period: Int {
        switch self {
        case .block: return 0
        case .trial: return 3
        case .vip: return 30
        case .vvvip: return 365
        }
    }
}

extension ExtMember {
    
    public static var create: AsyncMigration {
        Create()
    }
    
    struct Create: AsyncMigration {
        
        func revert(on database: FluentKit.Database) async throws {
            
        }
        
        func prepare(on database: FluentKit.Database) async throws {
            let level = try await database.enum("member_level")
                .case("block")
                .case("trial")
                .case("vip")
                .create()

            try await database.schema(ExtMember.schema)
                .id()
                .field("name", .string, .required)
                .field(.wxID, .string, .required)
                .field("member_level", level, .required)
                .field("created_at", .string, .required)
                .field("updated_at", .string, .required)
                .unique(on: "wx_id")
                .create()
        }
    }
    
    struct UpdateV1: AsyncMigration {
        
        func revert(on database: FluentKit.Database) async throws {
            
        }
        
        func prepare(on database: FluentKit.Database) async throws {
            let level = try await database.enum("member_level").read()
            
            try await database.schema(ExtMember.schema)
                .updateField("member_level", level)
                .field("ends_at", .string)
                .update()
        }
    }
}
