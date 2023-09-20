//
//  HolidayModel.swift
//  
//
//  Created by 张鹏 on 2022/9/30.
//

import Vapor
import Fluent

//extension FieldKey {
//    static var content: FieldKey { return "content" }
//}

struct HolidayModel: Content {

    static let tips = [
        "趁年轻，去远行。",
        "最好的时光在路上 , 所有快乐不用假装。",
        "你只管出发，其他的交给天意。",
        "时光会走远，影像会长存。",
        "有趣的人生，一半是山川湖海，一半是你。",
        "生活不是为了赶路，而是为了感受路。",
        "一个人的旅行，在路上遇见最真实的自己。",
        "最好的时光在路上，所有快乐不用假装。",
        "找不到答案的时候，就去看一看这个世界。",
        "总有远方可以奔赴，总有好事能水到渠成。",
        "用脚步去丈量世界，用眼睛去记录风景。",
        "星空迷上了山野，有雾有灯也有归人。",
        "一座城市的味道，尽在时光里。",
        "最好的时光在路上，一路向阳。",
        "想要未知的疯狂，想要声色的张扬，想要在最好的时光在最美地方。",
        "一辈子是场修行，短的是旅行，长的是人生。",
        "来世间一趟，一定要努力看看更多的风景。",
        "说走就走，是人生最华美的奢侈，也是最灿烂的自由。",
        "以为是乏味的城市 却遇见彩色的梦和许多美好。",
        "你在朋友圈旅游，我在峡谷里练兵。",
        "又过节了，没什么送大家的，一会儿我打个游戏，给大家送点人头。",
        "抱着一颗消遣的心，走了一段修行的路。",
        "你所不知道的远方，都是值得一去的天堂。",
        "把眼睛留给风光、把体重留给美食。",
        "去拥抱陌生 去期待惊喜 所有的不期而遇都在路上。",
        "一个人在旅行时，才听得到自己的声音，他会告诉你，这个世界比想象中的宽阔。",
        "出发永远是最有意义的事情，去做就对了。"
    ]

    let date: String
    let daycode: Int
    let cnweekday: String
    let holiday: String
    let name: String
    let enname: String
    let isnotwork: Int
    let tip: String
    let rest: String
    let now: Int
    let weekday: Int
}

/*
 {
   "code": 200,
   "msg": "success",
   "newslist": [
     {
       "date": "2021-01-01",
       "daycode": 1,
       "weekday": 5,
       "cnweekday": "星期五",
       "lunaryear": "庚子",
       "lunarmonth": "冬月",
       "lunarday": "十八",
       "info": "节假日",
       "start": 0,
       "now": 0,
       "end": 2,
       "holiday": "1月1号",
       "name": "元旦节",
       "enname": "New Year's Day",
       "isnotwork": 1,
       "vacation": [
         "2021-01-01",
         "2021-01-02",
         "2021-01-03"
       ],
       "remark": "",
       "wage": 3,
       "tip": "1月1日放假，共3天。",
       "rest": "2020年12月28日至2020年12月31日请假四天，与周末连休可拼七天长假。"
     }
   ]
 }
 */
