//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/3/20.
//

import Vapor

extension TAPD {
    
    enum WebhookType: String, Content {
        case create = "story::create"
        case update = "story::update"
        case bug = "bug::create"
    }
    
    struct WebhookStoryEvent: Decodable {
        let event: WebhookType
        let name: String
        let story: String
        let owner: [String]?
        let creator: [String]?
        
        private let workspaceFlex: Flex<Int, String>
        var workspace: Int { workspaceFlex.value }
        
        enum CodingKeys: String, CodingKey {
            case workspaceFlex = "workspace_id"
            case event = "event_key"
            case name
            case story = "id"
            case owner
            case creator
        }
    }
    
    struct WebhookBugEvent: Decodable {
        private let workspaceFlex: Flex<Int, String>
        var workspace: Int { workspaceFlex.value }
        
        let id: String
        let event: WebhookType
        let title: String
        let owner: [String]?
        let severity: Severity
        
        enum CodingKeys: String, CodingKey {
            case workspaceFlex = "workspace_id"
            case event = "event_key"
            case title
            case owner = "current_owner"
            case severity
            case id
        }
        
        enum Severity: String, Decodable {
            case fatal
            case serious
            case normal
            case prompt
            case advice
            
            var name: String {
                switch self {
                case .fatal: return "致命"
                case .serious: return "严重"
                case .normal: return "一般"
                case .prompt: return "提示"
                case .advice: return "建议"
                }
            }
        }
    }
}

protocol Flexible: Decodable {
    func convert<Output: Decodable>(to output: Output.Type) -> Output
}

struct Flex<Value: Decodable, AltValue: Flexible>: Decodable {

    let value: Value

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Value.self) {
            self.value = value
        } else {
            let altValue = try container.decode(AltValue.self)
            self.value = altValue.convert(to: Value.self)
        }
    }
}

extension String: Flexible {
    func convert<Output: Decodable>(to output: Output.Type) -> Output {
        switch output {
        case is Int.Type:
            return Int(self)! as! Output
        default:
            fatalError()
        }
    }
}

/*
 {
         "workspace_id": 31755764,
         "user": "zhangpeng",
         "object_type": "story",
         "id": "1131755764001219159",
         "timestamp": 1679283940,
         "timestamp_micro": 1679283940736,
         "zone": "31755764",
         "event_type": "",
         "event_key": "story::create",
         "event_identity": "story::create|1131755764001000021",
         "from": "web",
         "event_flow": null,
         "auto_task_event_times": 0,
         "auto_task_start_time": 0,
         "parent_event_id": "",
         "default_case_long_id": "",
         "case_id": 0,
         "event_id": "20ee5c68e456c9c675f4eda517ecabbf_e721c8f05554",
         "action_result": {
             "code": 0,
             "msg": "",
             "data": null
         },
         "tapd_object_id_list": null,
         "event_task_id": 0,
         "id:fromto": {
             "to": "1131755764001219159",
             "from": "1131755764001219159"
         },
         "category_id:fromto": {
             "to": "1131755764001001683",
             "from": ""
         },
         "children_id:fromto": {
             "to": "|",
             "from": ""
         },
         "confidential:fromto": {
             "to": "N",
             "from": ""
         },
         "creator:fromto": {
             "to": [
                 "zhangpeng"
             ],
             "from": ""
         },
         "description_type:fromto": {
             "to": "1",
             "from": ""
         },
         "effort:fromto": {
             "to": "5",
             "from": ""
         },
         "entity_type:fromto": {
             "to": "Story",
             "from": ""
         },
         "name:fromto": {
             "to": "测试企业微信需求和任务",
             "from": ""
         },
         "owner:fromto": {
             "to": [
                 "pengchunxiao"
             ],
             "from": ""
         },
         "path:fromto": {
             "to": "1131755764001219138",
             "from": ""
         },
         "remain:fromto": {
             "to": "5",
             "from": ""
         },
         "status:fromto": {
             "to": "planning",
             "from": ""
         },
         "templated_id:fromto": {
             "to": "1131755764001000637",
             "from": ""
         },
         "workitem_type_id:fromto": {
             "to": "1131755764001000021",
             "from": ""
         },
         "workspace_id:fromto": {
             "to": 31755764,
             "from": ""
         },
         "add_from_type:fromto": {
             "to": "create_story_from_copy",
             "from": ""
         },
         "remain_creator:fromto": {
             "to": "remain_creator",
             "from": ""
         },
         "template_id:fromto": {
             "to": "1131755764001000637",
             "from": ""
         },
         "modified:fromto": {
             "to": "",
             "from": ""
         },
         "ancestor_id": "0",
         "attachment_count": "0",
         "begin": null,
         "bug_id": null,
         "business_value": null,
         "category_id": "1131755764001001683",
         "cc": [ ],
         "children_id": "|",
         "completed": null,
         "confidential": "N",
         "created": "2023-03-20 11:45:40",
         "created_from": null,
         "creator": [
             "zhangpeng"
         ],
         "delay_count": null,
         "description_type": "1",
         "developer": [ ],
         "due": null,
         "effort": "5",
         "effort_completed": "0",
         "entity_type": "Story",
         "exceed": "0",
         "feature": "",
         "flows": null,
         "follower": "",
         "has_attachment": "0",
         "import_flag": "0",
         "is_archived": "0",
         "issue_id": null,
         "iteration_id": "0",
         "label": "",
         "level": "0",
         "modified": "2023-03-20 11:45:40",
         "modifier": "",
         "module": "",
         "name": "测试企业微信需求和任务",
         "owner": [
             "pengchunxiao"
         ],
         "parent_id": "0",
         "participator": "",
         "path": "1131755764001219138",
         "predecessor_count": "0",
         "priority": "",
         "progress": "0",
         "progress_manual": "0",
         "release_id": "0",
         "remain": "5",
         "secret_root_id": "0",
         "size": null,
         "sort": "109960000000",
         "source": "",
         "status": "planning",
         "status_append": "",
         "successor_count": "0",
         "support_forum_id": null,
         "support_id": null,
         "sync_type": "",
         "tech_risk": null,
         "templated_id": "1131755764001000637",
         "test_focus": "",
         "type": "",
         "version": "",
         "workitem_id": null,
         "workitem_type_id": "1131755764001000021",
         "add_from_type": "create_story_from_copy",
         "remain_creator": "remain_creator",
         "template_id": "1131755764001000637"
     }
 */
