//
//  TestSummarize.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/12.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

class TestSummarize {
    
    var fileName: String = String()
    var round: String = String()
    var sampleRate: String = String()
    
    var displayedFileName: String {
        get {
            return "文件名: " + fileName
        }
    }
    
    var displayedSampleRate: String {
        get {
            return "采样率: " + sampleRate + "K"
        }
    }
    
    var displayedRound: String {
        get {
            return "第" + round + "个文件"
        }
    }
    
    
    init() {
    
    }
    
    func toString() -> String {
        return displayedRound + "\n" + displayedFileName + "\n" + displayedSampleRate
    }

}