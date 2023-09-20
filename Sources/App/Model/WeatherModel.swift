//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor

enum WeatherType: String {
    case qing
    case yu
    case yin
    case lei
    case shachen
    case xue
    case yun
    case bingbao
    case wu
    case duoyun
    
    init(weatherimg: String?) {
        guard let w = weatherimg else { self = .yun; return }

        switch CaseInsensitiveString(w) {
        case "qing.png": self = .qing
        case "yu.png": self = .yu
        case "yin.png": self = .yin
        case "lei.png": self = .lei
        case "shachen.png": self = .shachen
        case "xue.png": self = .xue
        case "yun.png": self = .yun
        case "bingbao.png": self = .bingbao
        case "wu.png": self = .wu
        case "duoyun.png": self = .duoyun
        default:
            self = .yun
        }
    }
}

extension WeatherType {
    
    var icon: String {
        switch self {
        case .qing: return "☀️"
        case .yu: return "🌧"
        case .yin: return "☁️"
        case .lei: return "⛈"
        case .shachen: return "🌪"
        case .xue: return "❄️"
        case .yun: return "⛅️"
        case .bingbao: return "🧊"
        case .wu: return "🌁"
        case .duoyun: return "🌥"
        }
    }
}

struct WeatherModel: Content {
    
    let weather: String
    let weatherimg: String
    let lowest: String
    let highest: String
    let real: String
    let pop: String?
    let tips: String
    let wind: String
    let windsc: String
    let province: String
    let area: String
    let quality: String? //空气质量：优
    let humidity: String? //湿度
    let alarmlist: [WeatherAlarm]?
}

extension WeatherModel {
    
    var icon: String {
        return WeatherType(weatherimg: self.weatherimg).icon
    }
}

struct WeatherAlarm: Content {
    let level: String
    let type:String
    let content: String
}

/*
 {
   "code": 200,
   "msg": "success",
   "newslist": [
     {
       "date": "2022-10-24",
       "week": "星期一",
       "province": "广东",
       "area": "深圳",
       "areaid": "101280601",
       "weather": "多云",
       "weatherimg": "duoyun.png",
       "weathercode": "duoyun",
       "real": "24℃",
       "lowest": "21℃",
       "highest": "29℃",
       "wind": "东南风",
       "winddeg": "",
       "windspeed": "5",
       "windsc": "1级",
       "sunrise": "06:24",
       "sunset": "17:52",
       "moonrise": "",
       "moondown": "",
       "pcpn": "0",
       "pop": "",
       "uv_index": "0",
       "aqi": "57",
       "quality": "良",
       "vis": "30",
       "humidity": "68",
       "alarmlist": [
         {
           "province": "广东省",
           "city": "深圳市",
           "level": "红色",
           "type": "森林火险",
           "content": "【深圳市森林火险橙色预警升级为红色】深圳市森林防灭火指挥部和深圳市气象台2022年10月24日09时10分将全市陆地森林火险橙色预警升级为红色，预计我市天气将持续干燥，森林火险气象等级为五级，林内可燃物极易燃烧，森林火灾极易发生，火势蔓延速度极快，有关主管部门加大巡山护林力度，严格管制野外火源。（预警信息来源：国家预警信息发布中心）",
           "time": "2022-10-24 09:15:00"
         }
       ],
       "tips": "天气炎热，适宜着短衫、短裙、短裤、薄型T恤衫、敞领短袖棉衫等夏季服装。疫情防控不松懈，出门请佩戴口罩。"
     }
   ]
 }
 */
