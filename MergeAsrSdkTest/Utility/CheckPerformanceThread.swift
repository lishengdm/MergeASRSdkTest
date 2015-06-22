//
//  CheckPerformanceThread.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/9.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

class CheckPerformanceThread {

    private var memCounter: TestInfoCounter?
    private var cpuCounter: TestInfoCounter?
    private var isStopped: Bool = false
    
    init(mem: TestInfoCounter, cpu: TestInfoCounter) {
        self.memCounter = mem
        self.cpuCounter = cpu
    }
    
    func start() {
        if self.memCounter == nil || self.cpuCounter == nil {
            return
        }
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, { () -> Void in
            while !self.isStopped {
                self.cpuCounter?.plusOneRoundValue(StatGetter.getCpu())
                self.memCounter?.plusOneRoundValue(StatGetter.getMem())
                NSThread.sleepForTimeInterval(5)
            }
        })
    }
    
    func stopChecking() {
        self.isStopped = true
    }
    
}