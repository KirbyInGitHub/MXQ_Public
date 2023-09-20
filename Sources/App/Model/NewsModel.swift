//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor

struct NewsModel: Content {
    let ctime: String
    let title: String
    let description: String
    let picUrl: String
    let url: String
}


/*
 {
       "ctime": "2020-11-20 10:49",
       "title": "iOS14精准广告需授权功能推迟发布，苹果这样",
       "description": "网易互联网",
       "picUrl": "http://cms-bucket.ws.126.net/2020/1120/bc0a865cp00qk2qio003ec0009c0070c.png?imageView&thumbnail=200y140",
       "url": "https://tech.163.com/20/1120/10/FRSD9PRE00097U7R.html"
     }
 */
