//
//  Course.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit

class Course: NSObject {
    // Properties
    var name: String = ""
    // From 1 to 7, Sunday is 1
    var weekday: Int = 0
    var start: Int = 0
    var end: Int = 0
    
    init(name: String = "", weekday: Int = 0, start: Int = 0, end: Int = 0) {
        self.name = name
        self.weekday = weekday
        self.start = start
        self.end = end
    }
    
    func isEmpty() -> Bool {
        return name == ""
    }
    
    func getWeekday() -> String {
        switch weekday {
        case 1: return "周一"
        case 2: return "周二"
        case 3: return "周三"
        case 4: return "周四"
        case 5: return "周五"
        default:
            return "未知"
        }
        
    }
}
