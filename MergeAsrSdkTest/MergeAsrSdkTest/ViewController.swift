//
//  ViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // ui ref
    @IBOutlet var mLabelTestConfigDisplay: UILabel!
    @IBOutlet var mLabelSourceFileProcess: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        var finalString = setTestConfig()
        
        mLabelTestConfigDisplay.text = finalString

    }
    
    func setTestConfig() -> String {
        var wholeInfo: String = String()
        var userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let number = userDefault.valueForKey(KEY_TEST_NUMBER) as? Int {
            wholeInfo += "test number: " + String(number) + "\n"
        }
        
        if let domain = userDefault.valueForKey(KEY_TEST_DOMAIN) as? Int {
            wholeInfo += "test domain: " + TEST_DOMAIN_DETAIL_ARRAY[find(TEST_DOMAIN_VALUE_ARRAY, domain)!] + "\n"
        }
        
        if let sample_rate = userDefault.valueForKey(KEY_TEST_SAMPLE_RATE) as? Int {
            wholeInfo += "test sample rate: " + TEST_SAMPLE_RATE_NAME_ARRAY[find(TEST_SAMPLE_RATE_VALUE_ARRAY, sample_rate)!]
        }
        return wholeInfo
    }
    
    @IBAction func mBtnStartTest(sender: AnyObject) {
        println("ibaction")
        if let tmpConfig = getConfigFromSetting() {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let testViewController : TestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_controller") as TestViewController
            testViewController.mTestConfig = tmpConfig
            self.navigationController?.pushViewController(testViewController, animated: true)
        } else {
            // show a toast
        }
        
    }
    
    func getConfigFromSetting() -> TestConfig? {
        var config: TestConfig?
        var mUserDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let number = mUserDefaults.valueForKey(KEY_TEST_NUMBER) as? Int {
            if let sampleRate = mUserDefaults.valueForKey(KEY_TEST_SAMPLE_RATE) as? Int {
                if let domain = mUserDefaults.valueForKey(KEY_TEST_DOMAIN) as? Int {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let destViewController: TestViewController = segue.destinationViewController as TestViewController
//        var testConfig: TestConfig = TestConfig()
//        testConfig.testNumber = mUserDefaults.valueForKey(KEY_TEST_NUMBER) as Int
//        testConfig.testSampleRate = mUserDefaults.valueForKey(KEY_TEST_SAMPLE_RATE) as Int
//        println("prepare for segue")
    }
}

