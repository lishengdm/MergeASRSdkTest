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
    
    private var currentRound: Double = 0
    private var totalValue: Double = 0
    var startValue: Any?
    var finishValue: Any?
    private var needHistory: Bool = false
    lazy var history: [Double] = []
    
    convenience init() {
        self.init(needHistory: false)
    }
    
    init(needHistory: Bool) {
        self.needHistory = needHistory
    }
    
    func plusOneRoundValue(oneRoundValue: Double) {
        totalValue += oneRoundValue;
        currentRound++;
        if self.needHistory {
            self.history.append(oneRoundValue)
        }
    }
    
    func resetCounter() {
        currentRound = 0
        totalValue = 0
    }
    
    func getHistoryValue() -> [Double] {
        return self.history
    }
    
    func getAverValue() -> Double {
        return totalValue / currentRound
    }
}