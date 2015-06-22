//
//  LastVersionData.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/15.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

let KEY_8K_DATA = "8k"
let KEY_16K_DATA = "16k"

enum StatKey: String {
    case UA = "ua"
    case TEST_TIME = "test_time"
    case SDK_VERSION = "sdk_version"
    case PLATFORM = "platform"
    case ACCURACY_RATE = "accuracy_rate"
    case CPU = "cpu"
    case MEM = "mem"
    case INIT_TIME = "init_time"
    case RECALL_ORDER = "recall_order"
    case RESPONSE_TIME = "response_time"
    case SUCCESSRATE_RATE = "success_rate"
    case DOMAIN_CORRECT_RATE = "domain_correct_rate"
    case SAMPLE_RATE = "sample_rate"
}

class LastVersionData {

    private var lastVersionDatas: [String: [String: String]]
    private lazy var data8k = [String: String] ()
    private lazy var data16k = [String: String] ()
    
    init() {
        lastVersionDatas = [String: [String: String]] ()
    }
    
    func inflateData(sampleRate: String, lastVersionData: [String: String]) {
        switch sampleRate {
        case KEY_8K_DATA:
            lastVersionDatas[KEY_8K_DATA] = lastVersionData
        case KEY_16K_DATA:
            lastVersionDatas[KEY_16K_DATA] = lastVersionData
        default:
            return;
        }
    }
    
    func getLastVersionData(sampleRate: String) -> [String: String]? {
        switch sampleRate {
        case KEY_8K_DATA:
            return lastVersionDatas[KEY_8K_DATA]
        case KEY_16K_DATA:
            return lastVersionDatas[KEY_16K_DATA]
        default:
            return nil
        }
    }
    
}