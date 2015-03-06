//
//  ViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, BDRecognizerViewDelegate {

    // ui ref
    @IBOutlet var mScrollView: UIScrollView!
    @IBOutlet var mLabelTestConfigDisplay: UILabel!
    @IBOutlet var mLabelSourceFileProcess: UILabel!
    @IBOutlet var mTextViewFileName: UITextField!
    @IBOutlet var mButtonStartSingleFileTest: UIButton!
    
    let KEYBOARD_OFFSET: Double = 50
    let mUserDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var recognizerViewController: BDRecognizerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mTextViewFileName.delegate = self
        if let fileName = mUserDefault.valueForKey(KEY_SINGLE_TEST_FILE_NAME) as? String {
            self.mTextViewFileName.placeholder = fileName
            self.mTextViewFileName.text = fileName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        var finalString = setTestConfig()
        mLabelTestConfigDisplay.text = finalString
        registerForKeyboardNotifications()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dissmissKeyboard");
        
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        let destViewController: TestViewController = segue.destinationViewController as TestViewController
        //        var testConfig: TestConfig = TestConfig()
        //        testConfig.testNumber = mUserDefaults.valueForKey(KEY_TEST_NUMBER) as Int
        //        testConfig.testSampleRate = mUserDefaults.valueForKey(KEY_TEST_SAMPLE_RATE) as Int
        //        println("prepare for segue")
    }
    
    // MARK: - setting configuration
    
    func setTestConfig() -> String {
        var wholeInfo: String = String()
        if let number = mUserDefault.valueForKey(KEY_TEST_NUMBER) as? Int {
            wholeInfo += "test number: " + String(number) + "\n"
        }
        
        if let domain = mUserDefault.valueForKey(KEY_TEST_DOMAIN) as? Int {
            wholeInfo += "test domain: " + TEST_DOMAIN_DETAIL_ARRAY[find(TEST_DOMAIN_VALUE_ARRAY, domain)!] + "\n"
        }
        
        if let sample_rate = mUserDefault.valueForKey(KEY_TEST_SAMPLE_RATE) as? Int {
            wholeInfo += "test sample rate: " + TEST_SAMPLE_RATE_NAME_ARRAY[find(TEST_SAMPLE_RATE_VALUE_ARRAY, sample_rate)!]
        }
        return wholeInfo
    }
    
    func getConfigFromSetting() -> TestConfig? {
        var config: TestConfig?
        
        if let number = mUserDefault.valueForKey(KEY_TEST_NUMBER) as? Int {
            if let sampleRate = mUserDefault.valueForKey(KEY_TEST_SAMPLE_RATE) as? Int {
                if let domain = mUserDefault.valueForKey(KEY_TEST_DOMAIN) as? Int {
                    if number > 0 {
                        config = TestConfig()
                        config!.testNumber = number
                        config!.testSampleRate = sampleRate
                        config!.testType = getTestType(UInt32(domain))
                    }
                }
            }
        }
        return config
    }
    
    func getTestType(prop: UInt32) -> TestType {
        var type: TestType
        switch prop {
        case EVoiceRecognitionPropertySearch.value:
            type = .Search
        case EVoiceRecognitionPropertyInput.value:
            type = .Input
        default:
            type = .Domain
        }
        return type
    }
    
    func setUIDialogParams(paramsObject: BDRecognizerViewParamsObject) {
        paramsObject.apiKey = "8MAxI5o7VjKSZOKeBzS4XtxO"
        paramsObject.secretKey = "Ge5GXVdGQpaxOmLzc8fOM8309ATCz9Ha"
        paramsObject.licenseFilePath = NSBundle.mainBundle().pathForResource("bdasr_license", ofType: "dat")
        paramsObject.datFilePath = NSBundle.mainBundle().pathForResource("s_1", ofType:"")
        // paramsObject.LMDatFilePath = NSBundle.mainBundle().pathForResource("s_2_InputMethod", ofType:"")
        
        //        paramsObject.recogPropList = [20000]
        paramsObject.isShowTipAfter3sSilence = true;
        paramsObject.tipsList = ["我要记账", "买苹果花了十块钱", "买牛奶五块钱"]
    }
    
    // MARK: - IBAction
    
    @IBAction func startUITest(sender: AnyObject) {
        let paramsObject: BDRecognizerViewParamsObject = BDRecognizerViewParamsObject()
        // set paramsObject
        setUIDialogParams(paramsObject)
        // init ui view controller
        recognizerViewController = BDRecognizerViewController(origin: CGPointMake(20, 64), withTheme: BDTheme.defaultTheme())
        recognizerViewController.delegate = self
        recognizerViewController.enableFullScreenMode = false
        recognizerViewController.startWithParams(paramsObject)
    }
    
    @IBAction func mBtnStartTest(sender: AnyObject) {
        startTestTask(false)
    }
    
    @IBAction func SingleFileTest(sender: AnyObject) {
        showSingleTestViewModule()
    }
    
    @IBAction func startSingleFileTest(sender: AnyObject) {
        startTestTask(true)
    }
    
    func startTestTask(isSingTest: Bool) {
        if let tmpConfig = getConfigFromSetting() {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let testViewController : TestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_controller") as TestViewController
            if isSingTest {
                // if it is single file test, we should revise the config a little
                tmpConfig.testNumber = 1
                tmpConfig.singleTestFileName = self.mTextViewFileName.text
                mUserDefault.setValue(self.mTextViewFileName.text, forKey: KEY_SINGLE_TEST_FILE_NAME)
            }
            testViewController.mTestConfig = tmpConfig
            self.navigationController?.pushViewController(testViewController, animated: true)
        } else {
            // show a toast
        }
    }
    
    // MARK: - keyboard handler
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //        NSDictionary* info = [notification userInfo];
        let info = notification.userInfo as [String: AnyObject]
        //        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        if let keyboardRect = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = keyboardRect.CGRectValue().size
            let buttonOrigin = self.mTextViewFileName.frame.origin;
            let buttonHeight = self.mTextViewFileName.frame.size.height;
            var visibleRect = self.view.frame;
            visibleRect.size.height -= (keyboardSize.height + CGFloat(KEYBOARD_OFFSET));
            // judge if the view is covered
            println("cover? visible rect is \(visibleRect), origin point is \(buttonOrigin)")
            if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
                let scrollPoint: CGPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
                mScrollView.setContentOffset(scrollPoint, animated: true)
            }
        } else {
            println("fuck")
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.mScrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.dissmissKeyboard()
        return false
    }
    
    func dissmissKeyboard() {
        self.view.endEditing(true)
    }
    
    func showSingleTestViewModule() {
        mTextViewFileName.hidden = false
        mButtonStartSingleFileTest.hidden = false
    }
    
    // MARK: - MVoiceRecognitionClientDelegate
    func onEndWithViews(aBDRecognizerViewController: BDRecognizerViewController, withResults aResults: [AnyObject]) {
//        var s = aResults[0] as String
        println("over \(aResults)")
    }
    
    func onRecordDataArrived(recordData: NSData, sampleRate: Int) {}
    
    /**
    * @brief 录音结束
    */
    func onRecordEnded() {}
    
    /**
    * @brief 返回中间识别结果
    *
    * @param results
    *            中间识别结果
    */
    func onPartialResults(results: String) {}
    
    /**
    * @brief 发生错误
    *
    * @param errorCode
    *            错误码
    */
    func onError(errorCode: Int) {}
    
    /**
    * @brief 提示语出现
    */
    func onTipsShow() {}
    
    func onSpeakFinish() {}
    
    func onRetry() {}
    
    /**
    * @brief 弹窗关闭
    */
    func onClose() {}
    
}

