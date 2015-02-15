//
//  TestInfoCounter.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/11.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

enum ONE_ROUND_RESULT: Double {
    case Success = 1
    case Fail = 0
}

class TestInfoCounter {
    
    var currentRound: Double = 0
    var totalValue: Double = 0
    var startValue: Any?
    var finishValue: Any?
    
    init() {
    }
    
    func plusOneRoundValue(oneRoundValue: Double) {
        totalValue += oneRoundValue;
        currentRound++;
    }
    
    func resetCounter() {
        currentRound = 0
        totalValue = 0
    }
    
    func getAverValue() -> Double {
        return totalValue / currentRound
    }
}