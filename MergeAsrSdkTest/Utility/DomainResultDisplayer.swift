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
        return super.toString() + "\n" + nluTriggerRate + "\n" + nluAccurateRate + "\n" + nluOnlineRate
    }
}