//
//  DomainResultDisplayer.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/25.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

class DomainResultDisplayer: ResultDisplayer {
    var nluTriggerRate: String
    var nluAccurateRate: String
    var nluOnlineRate: String
    
    override init() {
        nluTriggerRate = String()
        nluAccurateRate = String()
        nluOnlineRate = String()
        super.init()
    }
    
    override func toString() -> String {
        return super.toString() + "\n"
            + "nlu触发率:" + nluTriggerRate + "\n"
            + "nlu准确率:" + nluAccurateRate + "\n"
            + "在线nlu比率:" + nluOnlineRate
    }
}