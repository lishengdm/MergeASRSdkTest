//
//  TestConfig.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/6.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

enum TestType {
    case Input
    case Search
    case Domain
}

class TestConfig {

    var testType: TestType
    var testNumber: Int
    var testSampleRate: Int

    init() {
        testType = .Search
        testNumber = 1
        testSampleRate = 8000
    }
}