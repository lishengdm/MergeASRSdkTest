//
//  CalculateWordAccuracyOperation.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/12.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

protocol VTResponseDelegate {
    func onResponseGotten(response: AnyObject)
    func onResponseError(errorType: VTResponseError)
}

enum VTResponseError {
    case VTResponseNetworkError
    case VTResponseResolutionError
}

let RESPONSE_ACCURACY_UNDEFINED: String = "-1"
let RESPONSE_8K_ACCURACY_KEY: String = "8k_accuracy"
let RESPONSE_16K_ACCURACY_KEY: String = "16k_accuracy"

class CalculateWordAccuracyOperation {

    let remoteURL: String = "http://cp01-sys-razzjunheng-jxaibq423.cp01.baidu.com:8081/handle_sdk_result/handle_input_result.php"
    var queue: NSOperationQueue
    var sendContent: String
    var responseDelegate: VTResponseDelegate
    
    init(inQueue queue: NSOperationQueue, withContent: String, delegate: VTResponseDelegate) {
        self.queue = queue
        self.sendContent = withContent
        self.responseDelegate = delegate
    }
    
    func send() {
        let requestContent: String = String(format: "recognition_result=%@", sendContent)
        let requestData: NSData = requestContent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        var requestEntity: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: remoteURL)!)
        requestEntity.HTTPMethod = "POST"
        requestEntity.HTTPBody = requestData
        
        // using trailing closure, cool, huh?
        NSURLConnection.sendAsynchronousRequest(requestEntity, queue: queue) {
            response, returnData, connectionError in
            if connectionError == nil {
                // send success
                println("send request success")
                var jsonError: NSError?
                let responseDic: [String: String]? = NSJSONSerialization.JSONObjectWithData(returnData, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError) as? [String: String]
                if let dic = responseDic {
                    println("get dic success")
                    for (key, value) in dic {
                        println("\(key) && \(value)")
                    }
                    self.responseDelegate.onResponseGotten(dic)
                } else {
                    self.responseDelegate.onResponseError(VTResponseError.VTResponseResolutionError)
                }
            } else {
                // send fail
                println("send fail")
                self.responseDelegate.onResponseError(VTResponseError.VTResponseNetworkError)
            }
        // closure end
        }
    // send function end
    }
}
            