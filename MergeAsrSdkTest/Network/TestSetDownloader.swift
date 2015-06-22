//
//  TestSetDownloader.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/7.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import Foundation
import Alamofire

let STATUS_DOWNLOAD_SUCCESS: Int = 0

let ERROR_NETWORK: Int = 1
let ERROR_SERVER_RETURN_BAD_RESULT: Int = 2
let ERROR_NO_NEED_TO_DOWNLOAD: Int = 3
let ERROR_UNKNOWN_ERROR: Int = 4

let REMOTE_VERSION_FILE_URL = "http://cp01-sys-razzjunheng-jxaibq423.cp01.baidu.com:8081/mobile_service_test/get_version.php"
let REMOTE_TESTSET_URL = "http://cp01-sys-razzjunheng-jxaibq423.cp01.baidu.com:8081/mobile_service_test/voicerecognition.zip"

protocol LSTestSetDownloaderDelegate {
    func onDownLoadProgress(current: Int, total: Int)
    func onDownLoadFinish(status: Int)
    func onDownLoadError(error: Int)
}

class TestSetDownloader {
    
    var delegate: LSTestSetDownloaderDelegate
    
    var currentVersion: String?
    
    init(delegate: LSTestSetDownloaderDelegate) {
        self.delegate = delegate
    }
    
    func downLoadTestSet() {
        requestNewVersionFirst()
    }
    
    private func checkIfTestSetExist() -> Bool {
        var isDir: ObjCBool = false
        let testSetPath = Utility.getDocDir().stringByAppendingPathComponent("voicerecognition")
        if NSFileManager.defaultManager().fileExistsAtPath(testSetPath, isDirectory: &isDir) {
            if isDir {
                return true
            }
        }
        return false
    }
    
    private func checkVersion(nv: String?) {
        if let version = nv {
            var versionArray = version.componentsSeparatedByString(":") as [String]
            var newVersion: String = ""
            if versionArray.count >= 2 {
                newVersion = versionArray[1]
            }
            self.currentVersion = NSUserDefaults.standardUserDefaults().valueForKey(KEY_TEST_SET_VERSION) as? String
            if let oldVersion = self.currentVersion {
                if oldVersion != newVersion {
                    self.currentVersion = newVersion
                    self.startDownLoad()
                } else {
                    if checkIfTestSetExist() {
                        self.delegate.onDownLoadError(ERROR_NO_NEED_TO_DOWNLOAD)
                    } else {
                        self.currentVersion = newVersion
                        self.startDownLoad()
                    }
                }
            } else {
                // no default, so start download
                self.currentVersion = newVersion
                self.startDownLoad()
            }
        } else {
            self.delegate.onDownLoadError(ERROR_SERVER_RETURN_BAD_RESULT)
        }
    }
    
    private func requestNewVersionFirst() {
        Alamofire.request(.GET, REMOTE_VERSION_FILE_URL)
            .responseString { (_, _, string, error) in
                if nil == error {
                    self.checkVersion(string)
                } else {
                    self.delegate.onDownLoadError(ERROR_NETWORK)
                }
            }
    }
    
    private func startDownLoad() {
        Alamofire.download(.GET, REMOTE_TESTSET_URL,
            { (temporaryURL, response) in
                if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(
                    .DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                        let pathComponent = response.suggestedFilename
                        let fileUrl = directoryURL.URLByAppendingPathComponent(pathComponent!)
                        if let fullPath = fileUrl.absoluteString {
                            if NSFileManager.defaultManager().fileExistsAtPath(fullPath) {
                                NSFileManager.defaultManager().removeItemAtPath(fullPath, error: nil)
                            }
                        }
                        return fileUrl
                }
                return temporaryURL
            }
        ).progress( closure: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                println("download set progress")
                self.delegate.onDownLoadProgress(Int(totalBytesRead), total: Int(totalBytesExpectedToRead))
        }).response { (request, response, _, error) in
            if nil == error {
                NSUserDefaults.standardUserDefaults().setValue(self.currentVersion, forKey: KEY_TEST_SET_VERSION)
                self.delegate.onDownLoadFinish(STATUS_DOWNLOAD_SUCCESS)
            } else {
                self.delegate.onDownLoadError(ERROR_UNKNOWN_ERROR)
            }
        }
    }
}