//
//  Utility.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/8.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation

class Utility {

    class func getDocDir() -> String {
        let dirs: [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as! [String]
        let documentDir = dirs[0]
        return documentDir
    }
}
