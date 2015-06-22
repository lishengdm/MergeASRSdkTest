//
//  ManualContrastViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

let VOICE_RECOG_DIALOG_WIDTH: CGFloat = 302
let VOICE_RECOG_DIALOG_HEIGHT: CGFloat = 230

let VOLUME_UPDATE_INTERVAL = 0.1

class ManualContrastViewController: UIViewController, MVoiceRecognitionClientDelegate, BDRecognizerViewDelegate {

    @IBOutlet var mLabelRecoResult: UILabel!
    @IBOutlet var mLabelState: UILabel!
    @IBOutlet var mBaiduIndicator: UIActivityIndicatorView!
    @IBOutlet var mSliderVolume: UISlider!
    
    var baiduUIRecognizer: BDRecognizerViewController?
    var updateVolumeTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetBaiduUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpdateVolumeTimer() {
        updateVolumeTimer = NSTimer(timeInterval: VOLUME_UPDATE_INTERVAL, target: self, selector: "updateVolumeBar", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(updateVolumeTimer!, forMode: NSDefaultRunLoopMode)
    }
    
    func stopUpdateVolumeTimer() {
        if updateVolumeTimer != nil {
            updateVolumeTimer!.invalidate()
        }
    }
    
    func updateVolumeBar() {
        var volume = Float(BDVoiceRecognitionClient.sharedInstance().getCurrentDBLevelMeter()) / Float(100)
        if (volume > 1.0) {
            volume = 1.0
        }
        mSliderVolume.setValue(volume, animated: true)
    }
    
    func resetBaiduUI() {
        mBaiduIndicator.stopAnimating()
        mBaiduIndicator.hidden = true
        
        updateUI("", label: mLabelRecoResult)
        updateUI("", label: mLabelState)
    }
    
    func initBaiduUI() {
        let pos = CGPointMake((UIScreen.mainScreen().bounds.size.width - VOICE_RECOG_DIALOG_WIDTH) / 2,
            (UIScreen.mainScreen().bounds.size.height - VOICE_RECOG_DIALOG_HEIGHT) / 2);
        self.baiduUIRecognizer = BDRecognizerViewController(origin: pos, withTheme: BDTheme.defaultTheme())
        self.baiduUIRecognizer!.enableFullScreenMode = false;
        self.baiduUIRecognizer!.delegate = self;
    }
    
    func resolveBaiduResult(aResults: AnyObject) -> String {
        var tmpResult = ""
        if let nBestArray = aResults as? [String] {
            tmpResult = nBestArray[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        } else if let cnArray = aResults as? [[[String: Int]]] {
            for oneWord in cnArray {
                // get first candidate
                var firstCandidate = oneWord[0]
                var keyArray = Array(firstCandidate.keys)
                tmpResult += keyArray[0]
            }
        } else {
            tmpResult = "return format error"
        }
        
        return tmpResult
    }
    
    func generateParams() -> BDRecognizerViewParamsObject {
        let params = BDRecognizerViewParamsObject()
        
        params.apiKey = "Hfda5OQKftXEUkjyzYhTW6Wk";
        params.secretKey = "fb0a3b19be7ebdeeb592978e1c2ce172";
        params.appCode = "6164553"

//        params.licenseFilePath = NSBundle.mainBundle().pathForResource("temp_license_2015-06-17", ofType: "")
        
        // embed config
        params.datFilePath = NSBundle.mainBundle().pathForResource("s_1", ofType: "")
        params.LMDatFilePath = NSBundle.mainBundle().pathForResource("s_2_InputMethod", ofType: "")
        
        return params
    }
    
    func setBaiduApiParams() {
        BDVoiceRecognitionClient.sharedInstance().listenCurrentDBLevelMeter()
    }
    
    func setBaiduApiEmbedParams() {
        let appCode = ""
        let dataPath = NSBundle.mainBundle().pathForResource("s_1", ofType: "")
        let LMDatPath = NSBundle.mainBundle().pathForResource("s_2_InputMethod", ofType: "")
       
        let recoGramSlot = [
            "name_CORE": "张三\n李四\n",
            "$song_CORE" : "小苹果\n朋友\n",
            "$app_CORE" : "QQ\n百度\n微信\n百度地图\n",
            "$artist_CORE" : "刘德华\n周华健\n"
        ]
        
        let loadRet = BDVoiceRecognitionClient.sharedInstance().loadOfflineEngine("6164553", license: "", datFile:dataPath , LMDatFile: LMDatPath, grammSlot: recoGramSlot)
        if loadRet != 0 {
            println("load offline engine fail")
            return
        }
    }
    
    func updateUI(text: String, label: UILabel) {
        dispatch_async(dispatch_get_main_queue(), {
            label.text = text
        })
    }
    
    func baiduApiFinish(obj: AnyObject?) {
        resetBaiduUI()
        if let o: AnyObject = obj {
            var result = resolveBaiduResult(o)
            updateUI(result, label: mLabelRecoResult)
        } else {
            // error happens
        }
    }
    
    func resetBaiduApi() {
        BDVoiceRecognitionClient.sharedInstance().stopVoiceRecognition()
        stopUpdateVolumeTimer()
    }
    
    func baiduUpdateResult(obj: AnyObject?) {
        if let o: AnyObject = obj {
            var result = resolveBaiduResult(o)
            updateUI(result, label: mLabelRecoResult)
        } else {
            // no data
        }
    }
    
    // MARK: - ibaction
    
    @IBAction func startBaiduUI(sender: AnyObject) {
        if baiduUIRecognizer == nil {
            initBaiduUI()
        }
        
        let params = generateParams();
        self.baiduUIRecognizer!.startWithParams(params)
    }
    
    @IBAction func startBaiduApi(sender: AnyObject) {
        resetBaiduUI()
        resetBaiduApi()
        
        setBaiduApiParams()
        setBaiduApiEmbedParams()
        let status = BDVoiceRecognitionClient.sharedInstance().startVoiceRecognition(self)
        if status.value != EVoiceRecognitionStartWorking.value {
            return
        }
    }
    
    @IBAction func stopBaiduRec(sender: AnyObject) {
        resetBaiduApi()
        resetBaiduUI()
    }
    
    // MARK: - BDRecognizerViewDelegate
    
    func onEndWithViews(aBDRecognizerViewController: BDRecognizerViewController!, withResults aResults: [AnyObject]!) {
        var tmpResult = resolveBaiduResult(aResults)
        
        updateUI(tmpResult, label: mLabelRecoResult)
    }

    // MARK: - app delegate
    
    override func viewWillAppear(animated: Bool) {
        if baiduUIRecognizer != nil {
            baiduUIRecognizer = nil
        }
    }
    
    // MARK: - MVoiceRecognitionClientDelegate
    func VoiceRecognitionClientWorkStatus(aStatus: Int32, obj aObj: AnyObject!) {
        println("status + \(aStatus)")
        switch aStatus {
        case Int32(EVoiceRecognitionClientWorkStatusStartWorkIng.value):
            startUpdateVolumeTimer()
            updateUI("开始工作", label: mLabelState)
        case Int32(EVoiceRecognitionClientWorkStatusStart.value):
            updateUI("检测到用户说话", label: mLabelState)
        case Int32(EVoiceRecognitionClientWorkStatusEnd.value):
            updateUI("录音结束，等待服务器", label: mLabelState)
            stopUpdateVolumeTimer()
            mBaiduIndicator.hidden = false
            mBaiduIndicator.startAnimating()
        case Int32(EVoiceRecognitionClientWorkStatusFlushData.value):
            updateUI("连续上屏。。。", label: mLabelState)
            baiduUpdateResult(aObj)
        case Int32(EVoiceRecognitionClientWorkStatusFinish.value):
            updateUI("识别成功结束", label: mLabelState)
            baiduApiFinish(aObj)
        case Int32(EVoiceRecognitionClientWorkStatusError.value):
            updateUI("识别出错", label: mLabelState)
            baiduApiFinish(nil)
        default:
            break
        }
    }
    
    //  MARK: - App delegate
    override func viewWillDisappear(animated: Bool) {
        stopUpdateVolumeTimer()
        resetBaiduUI()
        resetBaiduApi()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
