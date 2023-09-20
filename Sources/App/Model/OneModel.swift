//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor

struct OneModel: Content {
    let word: String
    let wordfrom: String
    let imgurl: String
    let imgauthor: String
    let date: String
}


/*
 {
       "oneid": 3035,
       "word": "我始终相信，上帝造人，必定给予每个人属于自己的独特礼物，你必须去发掘它，并勇往直前将之发扬光大，那么成功必定不会离你太远。",
       "wordfrom": "",
       "imgurl": "http://image.wufazhuce.com/FnMRKu69SdvdpXccB2xJWVE6TtUU",
       "imgauthor": "",
       "date": "2020-12-16"
     }
 */
