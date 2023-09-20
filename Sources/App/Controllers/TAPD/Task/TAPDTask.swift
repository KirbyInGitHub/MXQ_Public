//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/23.
//

import Vapor

struct TAPDTask {
    
    struct Resp: Content {
        let status: Bool
        let info: String
        let data: [[String: Info]]
    }
    
    struct Info: Content {
        let id: String?
        let name: String?
        let status: String
        let effort: String? //预估工时
        let workspace_id: String
        var begin: String?
        let due: String?
        let owner: String?
        let story_id: String?
        let creator: String?
    }

    struct Modify: Content {
        let id: String
        let timespent: String
        let workspace: String
        let spentdate: String
        let type: String
        let owner: String
        
        enum CodingKeys: String, CodingKey {
            case id = "entity_id"
            case timespent = "timespent"
            case workspace = "workspace_id"
            case spentdate = "spentdate"
            case type = "entity_type"
            case owner = "owner"
        }
    }
    
    struct Create: Content {
        let workspace: String
        let name: String
        let creator: String
        let owner: String
        let story: String
        
        enum CodingKeys: String, CodingKey {
            case workspace = "workspace_id"
            case name
            case creator
            case owner
            case story = "story_id"
        }
    }

}


/*
 {
                 "id": "1131755764001214254",
                 "name": "【Bug转需求】App下单页，购买返回rewards的文案显示为3%  实际mc设置为1%",
                 "description": "",
                 "workspace_id": "31755764",
                 "creator": "pengchunxiao",
                 "created": "2023-02-13 11:06:48",
                 "modified": "2023-02-20 15:55:23",
                 "status": "open",
                 "owner": "XuYun;",
                 "cc": "",
                 "begin": "2023-02-20",
                 "due": "2023-02-22",
                 "story_id": "1131755764001212949",
                 "iteration_id": "0",
                 "priority": "3",
                 "progress": "0",
                 "completed": null,
                 "effort_completed": "0",
                 "exceed": "0",
                 "remain": "0",
                 "effort": null,
                 "has_attachment": "0",
                 "release_id": "0",
                 "label": "",
                 "custom_field_one": "iOS开发",
             }
 */

/*
 {
             "Task": {
                 "id": "1131755764001217545",
                 "name": "【Bug转需求】【贾梦倩】三星 Galaxy S22 Ultr 安卓13版本下载app会死机-测试",
                 "description": "",
                 "workspace_id": "31755764",
                 "creator": "taohongfei",
                 "created": "2023-03-08 17:51:19",
                 "modified": "2023-03-08 17:51:19",
                 "status": "open",
                 "owner": "pengchunxiao;taohongfei;",
                 "cc": "",
                 "begin": null,
                 "due": null,
                 "story_id": "1131755764001217544",
                 "iteration_id": "0",
                 "priority": "",
                 "progress": "0",
                 "completed": null,
                 "effort_completed": "0",
                 "exceed": "0",
                 "remain": "0",
                 "effort": null,
                 "has_attachment": "0",
                 "release_id": "0",
                 "label": "",
                 "custom_field_one": "Android开发",
             }
         }
 */
