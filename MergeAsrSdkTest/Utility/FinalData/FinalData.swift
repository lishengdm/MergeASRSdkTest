//
//  FinalData.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

let KEY_TEST_CONFIG = "config"
let KEY_TEST_RESULT = "test_result"
let KEY_UA = "ua"
let KEY_SDK_VERSION = "sdk_version"
let KEY_TIME = "test_time"
let KEY_PLATFORM = "platform"

let PLATFORM_IOS = "ios"

class FinalData {
    
    internal var rootJson: [String: AnyObject]
    internal var testConfigJson: [String: String]
    internal var testResultJson: [String: AnyObject]
    
    init() {
        rootJson = [String: AnyObject]()
        testConfigJson = [String: String]()
        testResultJson = [String: AnyObject]()
    }
    
    func putUA(ua: String) {
        testConfigJson[KEY_UA] = ua
    }
    
    func putSdkVersion(version: String) {
        testConfigJson[KEY_SDK_VERSION] = version
    }
    
    func putTime(time: String) {
        testConfigJson[KEY_TIME] = time
    }
    
    func putPlatform(platform: String) {
        testConfigJson[KEY_UA] = platform
    }
    
    func toString() -> String {
        rootJson[KEY_TEST_CONFIG] = self.testConfigJson
        rootJson[KEY_TEST_RESULT] = self.testResultJson
        
        return NSString(data: NSJSONSerialization.dataWithJSONObject(rootJson, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!, encoding: NSUTF8StringEncoding)! as String
    }

}
