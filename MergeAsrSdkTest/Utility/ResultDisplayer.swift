//
//  ResultDisplayer.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/12.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

class ResultDisplayer {

    var accuracyRate: String
    var successRate: String
    var trafficUsage: String
    var responseTime: String
    var recognitionTime: String
    var memoryUsage: String
    var cpuUsage: String
    
    init() {
        accuracyRate = String()
        successRate = String()
        trafficUsage = String()
        responseTime = String()
        recognitionTime = String()
        memoryUsage = String()
        cpuUsage = String()
    }
    
    func toString() -> String {
        return "准确率:" + accuracyRate + "\n"
            + "识别率:" + successRate + "\n"
            + "识别时间:" + recognitionTime + "\n"
            + "响应时间:" + responseTime + "\n"
            + "内存usage:" + memoryUsage + "\n"
            + "cpu usage:" + cpuUsage + "\n"
    }
}
