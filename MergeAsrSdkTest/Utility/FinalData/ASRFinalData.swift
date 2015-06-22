//
//  ASRFinalData.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

let KEY_RESPONSE_TIME = "response_time"
let KEY_INIT_TIME = "init_time"
let KEY_SUCCESS_RATE = "success_rate"
let KEY_MEM = "mem"
let KEY_CPU = "cpu"
let KEY_RECALL_ORDER = "recall_order"
let KEY_ACCURACY_RATE = "accuracy_rate"
let KEY_DOMAIN_CORRECT = "domain_correct_rate"
let KEY_RECO_TIME = "recognition_time"
let KEY_TRAFFIC = "traffic"
let KEY_SAMPLE_RATE = "sample_rate"
let KEY_MODE = "mode" // input, search, domain
let KEY_8K = "8k"
let KEY_16K = "16k"

let MODE_SEARCH = "search"
let MODE_INPUT = "input"
let MODE_DOMAIN = "domain"

class ASRFinalData: FinalData {

    var test8kResultJson: [String: String]
    var test16kResultJson: [String: String]
    
    override init() {
        test8kResultJson = [String: String]()
        test16kResultJson = [String: String]()
        super.init()
    }
    
    func putMode(mode: String) {
        testConfigJson[KEY_MODE] = mode
    }
    
    func put8kAccuracyRate(accuracy: String) {
        test8kResultJson[KEY_ACCURACY_RATE] = accuracy
    }
    
    func put16kAccuracyRate(accuracy: String) {
        test16kResultJson[KEY_ACCURACY_RATE] = accuracy
    }
    
    func put8kRecognitionTime(time: String) {
        test8kResultJson[KEY_RECO_TIME] = time
    }
    
    func put16kRecognitionTime(time: String) {
        test16kResultJson[KEY_RECO_TIME] = time
    }
    
    func put8kTraffic(traffic: String) {
        test8kResultJson[KEY_TRAFFIC] = traffic
    }
    
    func put16kTraffic(traffic: String) {
        test16kResultJson[KEY_TRAFFIC] = traffic
    }
    
    func put8kDomainCorrectRate(domainCorrectRate: String) {
        test8kResultJson[KEY_DOMAIN_CORRECT] = domainCorrectRate
    }
    
    func put16kDomainCorrectRate(domainCorrectRate: String) {
        test16kResultJson[KEY_DOMAIN_CORRECT] = domainCorrectRate
    }
    
    func put8kResponseTime(s: String) {
        test8kResultJson[KEY_RESPONSE_TIME] = s
    }
    
    func put16kResponseTime(s: String) {
        test16kResultJson[KEY_RESPONSE_TIME] = s
    }
    
    func put8kInitTime(s: String) {
        test8kResultJson[KEY_INIT_TIME] = s
    }
    
    func put16kInitTime(s: String) {
        test16kResultJson[KEY_INIT_TIME] = s
    }
    
    func put8kSuccessRate(s: String) {
        test8kResultJson[KEY_SUCCESS_RATE] = s
    }
    
    func put16kSuccessRate(s: String) {
        test16kResultJson[KEY_SUCCESS_RATE] = s
    }

    func put8kMemUsage(s: String) {
        test8kResultJson[KEY_MEM] = s
    }
    
    func put16kMemUsage(s: String) {
        test16kResultJson[KEY_MEM] = s
    }
    
    func put8kCpuUsage(s: String) {
        test8kResultJson[KEY_CPU] = s
    }
    
    func put16kCpuUsage(s: String) {
        test16kResultJson[KEY_CPU] = s
    }

    func put8kRecallOrderCorrectRate(s: String) {
        test8kResultJson[KEY_RECALL_ORDER] = s
    }
    
    func put16kRecallOrderCorrectRate(s: String) {
        test16kResultJson[KEY_RECALL_ORDER] = s
    }
  
    func put8kSampleRate(s: String) {
        test8kResultJson[KEY_SAMPLE_RATE] = s
    }
    
    func put16kSampleRate(s: String) {
        test16kResultJson[KEY_SAMPLE_RATE] = s
    }

    override func toString() -> String {
        testResultJson[KEY_8K] = test8kResultJson
        testResultJson[KEY_16K] = test16kResultJson
        
        return super.toString()
    }
}