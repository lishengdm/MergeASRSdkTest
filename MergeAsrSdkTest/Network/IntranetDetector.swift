//
//  IntranetDetector.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/6.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation
import Alamofire

let BAIDU_INTRA_WEBSITE = "http://family.baidu.com/"

protocol LSIntranetDetectorDelegate {
    func onCheckFinish(result: String?)
}

class IntranetDetector {

    var delegate: LSIntranetDetectorDelegate
    var manager: Manager?
    
    init(delegate: LSIntranetDetectorDelegate) {
        self.delegate = delegate;
    }
    
    func checkIfConnectIntraDector() {
        let configuration = getConfiguration()
        self.manager = Alamofire.Manager(configuration: configuration)
        
        self.manager!.request(.GET, BAIDU_INTRA_WEBSITE)
            .response { (request, response, data, error) in
                println(error)
                if nil == error {
                    self.delegate.onCheckFinish(nil)
                } else {
                    self.delegate.onCheckFinish(error!.localizedDescription)
                }
            }
    }
    
    func getConfiguration() -> NSURLSessionConfiguration {
        let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
        conf.timeoutIntervalForRequest = 1
        
        return conf
    }
    
}