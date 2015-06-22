//
//  TestViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit
import Charts

class TestViewController: UIViewController, MVoiceRecognitionClientDelegate, VTResponseDelegate {

    // constants
    let ANSWER_8K_SEARCH_FILE_NAME: String = "search_8k_answer.txt"
    let ANSWER_16K_SEARCH_FILE_NAME: String = "search_16k_answer.txt"
    let ANSWER_8K_INPUT_FILE_NAME: String = "input_8k_answer.txt"
    let ANSWER_16K_INPUT_FILE_NAME: String = "input_16k_answer.txt"
    let ANSWER_8K_DOMAIN_FILE_NAME: String = "domain_8k_answer.txt"
    let ANSWER_16K_DOMAIN_FILE_NAME: String = "domain_16k_answer.txt"
    
    let FILE_8K_SEARCH: String = "search_8k"
    let FILE_16K_SEARCH: String = "search_16k"
    let FILE_8K_INPUT: String = "input_8k"
    let FILE_16K_INPUT: String = "input_16k"
    let FILE_8K_DOMAIN: String = "domain_8k"
    let FILE_16K_DOMAIN: String = "domain_16k"
    
    let TEST_CONFIG_SAMPLERATE_8K: Int = 8000
    let TEST_CONFIG_SAMPLERATE_16K: Int = 16000
    let TEST_CONFIG_SAMPLERATE_8K_AND_16K: Int = 0
    let TEST_CONFIG_DOMAIN_SEARCH: Int = 10005
    let TEST_CONFIG_DOMAIN_INPUT: Int = 20000
    let TEST_CONFIG_DOMAIN_DOMAIN: Int = -1
    
    let MAX_RETRY_TIME: Int = 3
    
    // io file name
    var RECO_RESULT_OUTPUT_FILE_NAME = "recognition_result.txt"
    var ERROR_OUTPUT_FILE_NAME = "error.txt"
    
    // ui ref definition
    @IBOutlet var mLabelAnswerRegion: UILabel!
    @IBOutlet var mLabelAnswerHint: UILabel!
    @IBOutlet var mLabelTestInfo: UILabel!
    @IBOutlet var mLabelRecogntionSuccessRate: UILabel!
    @IBOutlet var mLabelRecognitionAccuracyRate: UILabel!
    @IBOutlet var mLabelTestInfoHint: UILabel!
    @IBOutlet var mLabelSuccessRateHint: UILabel!
    @IBOutlet var mLabelAccuracyRateHint: UILabel!
    @IBOutlet var mLabelTestProgress: UILabel!
    @IBOutlet var mLabelRecognitionResult: UILabel!
    
    // test config
    var mTestConfig: TestConfig!
    var mVoiceRecognitionClient: BDVoiceRecognitionClient?
    var mVoiceRecognitionFileRecognizer: BDVRFileRecognizer?
    
    // test variable
    var mAnswer8k: [String: String] = [String: String]()
    var mAnswer16k: [String: String] = [String: String]()
    var mCurrentAnswerMap: [String: String] = [String: String]()
    var mFileArray8k: [String] = [String]()
    var mFileArray16k: [String] = [String]()
    var mCurrentFileArray: [String] = [String]()
    var mCurrentRecognition: String = String()
    var mCurrentFileIndex: Int = 0
    var mCurrentFileName = String()
    var mCurrentAnswer = String()
    var mFile8kDirName: String = String()
    var mFile16kDirName: String = String()
    var mCurrentTestFileDirName: String = String()
    var mCurrentSampleRate: Int32 = -1
    var mCurrentRetryTime: Int = 0
    var mCurrentRoundMaxTestNumber: Int = 0
    
    // test info counter
    lazy var mTrafficCounter: TestInfoCounter = TestInfoCounter()
    lazy var mSuccessRateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mAccurateRateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluTriggeredCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluAccurateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluOnlineResolveCounter: TestInfoCounter = TestInfoCounter()
    lazy var mRecognitionTimeCounter: TestInfoCounter = TestInfoCounter(needHistory: true)
    lazy var mResponseTimeCounter: TestInfoCounter = TestInfoCounter(needHistory: true)
    lazy var mMemCounter: TestInfoCounter = TestInfoCounter(needHistory: true)
    lazy var mCpuCounter: TestInfoCounter = TestInfoCounter(needHistory: true)
    
    lazy var mTestSum: TestSummarize = TestSummarize()
    lazy var lastVersonData: LastVersionData = LastVersionData()
    var m8kDisplayer: ResultDisplayer?
    var m16kDisplayer: ResultDisplayer?
    
    // input recognition array
    lazy var mUploadContent: String = String()
    lazy var mInputRecognitionResultsJsonArray: [String] = [String]()
    lazy var mUploadJson: [String: AnyObject] = [String: AnyObject]()
    
    // test queue
    lazy var mTestTaskQueue: NSOperationQueue = NSOperationQueue()
    lazy var mCheckWordAccuracyQueue: NSOperationQueue = NSOperationQueue()
    
    let domainAndFilenameMap: [String: String] = ["telephone": "call", "message": "msg", "music": "music", "app": "app", "navigate_instruction": "navi", "contacts": "contact", "setting": "cmd", "tv_instruction": "channel", "player_instruction": "player", "radio": "radio"]
    
    // some control variables
    var mIsFirstUpdate: Bool = true
    var mIsSingleFileTest: Bool = false
    
    // output file definenation
    var recoResultOutputFileHandler: BDVRFileWriter!
    var errorOutputFileHandler: BDVRFileWriter!
    
    var checkPerformanceThread: CheckPerformanceThread?
    
    // MARK: - Override UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !loadFileNameAndAnswer() {
            mLabelTestInfo.text = ""
            return
        }
        startOneRoundTask()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Load File
    
    func loadFileNameAndAnswer() -> Bool {
        var answer8kFileName: String, answer16kFileName: String
        
        switch mTestConfig.testType {
        case .Search:
            answer8kFileName = ANSWER_8K_SEARCH_FILE_NAME
            answer16kFileName = ANSWER_16K_SEARCH_FILE_NAME
            mFile8kDirName = FILE_8K_SEARCH
            mFile16kDirName = FILE_16K_SEARCH
        case .Input:
            answer8kFileName = ANSWER_8K_INPUT_FILE_NAME
            answer16kFileName = ANSWER_16K_INPUT_FILE_NAME
            mFile8kDirName = FILE_8K_INPUT
            mFile16kDirName = FILE_16K_INPUT
        case .Domain:
            answer8kFileName = ANSWER_8K_DOMAIN_FILE_NAME
            answer16kFileName = ANSWER_16K_DOMAIN_FILE_NAME
            mFile8kDirName = FILE_8K_DOMAIN
            mFile16kDirName = FILE_16K_DOMAIN
        default:
            break
        }
        populateAnswerAndFileArray(answer8kFileName, answerMap: &mAnswer8k, dirName: mFile8kDirName, fileArray: &mFileArray8k)
        populateAnswerAndFileArray(answer16kFileName, answerMap: &mAnswer16k, dirName: mFile16kDirName, fileArray: &mFileArray16k)
        return true
    }
    
    func populateAnswerAndFileArray(fileName: String, inout answerMap: [String: String], dirName: String, inout fileArray: [String]) {
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if dirs != nil {
            // documents directory
            let documentDir = dirs![0]
            // answer file ref
            let answerFilePath = documentDir.stringByAppendingPathComponent("voicerecognition").stringByAppendingPathComponent(fileName)
            // load answer
            let cfEnc = CFStringEncodings.GB_18030_2000
            let gb2132Enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            let answerFileContent: String? = String(contentsOfFile: answerFilePath, encoding:gb2132Enc, error: nil)
            if let content = answerFileContent {
                let lines: [String] = content.componentsSeparatedByString("\n")
                for line in lines {
                    let fileNameAndAnswer = line.componentsSeparatedByString(":")
                    if fileNameAndAnswer.count == 2 {
                        let fileName: String = fileNameAndAnswer[0]
                        let answer: String = fileNameAndAnswer[1]
                        answerMap[fileName] = answer
                    }
                }
            }

            // load file array
            let fileDirPath = documentDir.stringByAppendingPathComponent("voicerecognition").stringByAppendingPathComponent(dirName)
            
            let fileListOfDir: [String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(fileDirPath, error: nil) as! [String]
            for fileItem in fileListOfDir {
                if fileItem.pathExtension.lowercaseString == "pcm" {
                    fileArray.append(fileItem)
                }
            }
        }
    }
    
    // MARK: - Start Test
    
    func startOneRoundTask() {
        beforeOneRoundTask()
        switch mTestConfig.testSampleRate {
            case TEST_CONFIG_SAMPLERATE_16K:
                startOneRoundAutoTest(TEST_CONFIG_SAMPLERATE_16K)
            default:
                // include 2 situations, 1: user select only 8k; 2: user select 8k && 16k, which would test 8k first
                startOneRoundAutoTest(TEST_CONFIG_SAMPLERATE_8K)
        }
    }
    
    func beforeOneRoundTask() {
        mTestTaskQueue.maxConcurrentOperationCount = 1

        updateUI("准确率: ", label: mLabelAccuracyRateHint)
        updateUI("识别率: ", label: mLabelSuccessRateHint)
        
        // judge if it is singlefile test according to the config.singleFileName
        if let fileName = mTestConfig.singleTestFileName {
            mIsSingleFileTest = true
        } else {
            mIsSingleFileTest = false
        }
        
        // init file handler
        recoResultOutputFileHandler = BDVRFileWriter(fileName: RECO_RESULT_OUTPUT_FILE_NAME)
        errorOutputFileHandler = BDVRFileWriter(fileName: ERROR_OUTPUT_FILE_NAME)
        
    }
    
    func startOneRoundAutoTest(currentSampleRate: Int) {
        initOneSampleValues()
        switch currentSampleRate {
        case TEST_CONFIG_SAMPLERATE_8K:
            mCurrentFileArray = mFileArray8k
            mCurrentAnswerMap = mAnswer8k
            mCurrentTestFileDirName = mFile8kDirName
            break
        case TEST_CONFIG_SAMPLERATE_16K:
            mCurrentFileArray = mFileArray16k
            mCurrentAnswerMap = mAnswer16k
            mCurrentTestFileDirName = mFile16kDirName
            break
        default:
            break
        }
        mCurrentSampleRate = Int32(currentSampleRate)
        mCurrentRoundMaxTestNumber = mTestConfig.testNumber > mCurrentFileArray.count ? mCurrentFileArray.count : mTestConfig.testNumber
        
        self.startOneRoundRecognition()
    }
    
    func initOneSampleValues() {
        mRecognitionTimeCounter.resetCounter()
        mResponseTimeCounter.resetCounter()
        mSuccessRateCounter.resetCounter()
        mAccurateRateCounter.resetCounter()
        mMemCounter.resetCounter()
        mCpuCounter.resetCounter()
        mTrafficCounter.resetCounter()
        if mTestConfig.testType == TestType.Domain {
            mNluAccurateCounter.resetCounter()
            mNluOnlineResolveCounter.resetCounter()
            mNluTriggeredCounter.resetCounter()
        }
        
        mCurrentFileIndex = 0
        
        // performance thread
        self.checkPerformanceThread = CheckPerformanceThread(mem: self.mMemCounter, cpu: self.mCpuCounter)
//        self.checkPerformanceThread!.start()

    }
    
    func startOneRoundRecognition() {
        var oneRoundRecogntionOperation: NSBlockOperation = NSBlockOperation(block: {
            self.oneRoundRecognitionProcess()
        })
        mTestTaskQueue.addOperation(oneRoundRecogntionOperation)
    }
    
    func oneRoundRecognitionProcess() {
        println("=============== one recognition operation start ===============")
        NSThread.sleepForTimeInterval(1)
        beforeOneRoundRcognition()
        
        setClientConfig()
        var status = Int(mVoiceRecognitionFileRecognizer!.startFileRecognition())
        if status != Int(EVoiceRecognitionStartWorking.value) {
            println("File recognizer start working failed, status is: " + String(status))
        }
    }
    
    func setClientConfig() {
        let fileFullPath: String = getFullFilePath(mCurrentTestFileDirName, fileName: mCurrentFileName)
        let propList: [Int] = generatePropList(mTestConfig.testType)
        var cid: Int = 0
        println("full file path is: " + fileFullPath)
        // init the file recognizer
        mVoiceRecognitionFileRecognizer = BDVRFileRecognizer(fileRecognizerWithFilePath: fileFullPath, sampleRate: mCurrentSampleRate, propertyGroup: propList, cityID: cid, delegate: self)
        
        // congfig the recognizer
        BDVoiceRecognitionClient.sharedInstance().setApiKey("Hfda5OQKftXEUkjyzYhTW6Wk", withSecretKey: "fb0a3b19be7ebdeeb592978e1c2ce172")
        mVoiceRecognitionFileRecognizer!.appCode = "6164553";
        mVoiceRecognitionFileRecognizer!.datFilePath = NSBundle.mainBundle().pathForResource("s_1", ofType: "")
        
        println(mVoiceRecognitionFileRecognizer!.datFilePath)
        if mTestConfig.testType == TestType.Input {
            // input
            mVoiceRecognitionFileRecognizer!.LMDatFilePath = NSBundle.mainBundle().pathForResource("s_2_InputMethod", ofType: "")
            BDVoiceRecognitionClient.sharedInstance().setResourceType(RESOURCE_TYPE_POST)
        } else if mTestConfig.testType == TestType.Domain {
            // domain
            mVoiceRecognitionFileRecognizer!.LMDatFilePath = NSBundle.mainBundle().pathForResource("s_2_Navi", ofType: "")
            // map
            BDVoiceRecognitionClient.sharedInstance().setResourceType(RESOURCE_TYPE_NLU)
        } else {
            // search
            BDVoiceRecognitionClient.sharedInstance().setResourceType(RESOURCE_TYPE_NONE)
        }
        // set strategy
//        mVoiceRecognitionFileRecognizer!.recognitionStrategy = Int32(RECOGNITION_STRATEGY_ONLINE.value)
        
        // set time out
//        BDVoiceRecognitionClient.sharedInstance().setOnlineWaitTime(1)
        
        mVoiceRecognitionFileRecognizer!.recogGrammSlot = ["$name_CORE": "李胜\n",
                                        "$song_CORE": "最后的战役\n",
                                        "$app_CORE": "百度浏览器\n",
                                        "$artist_CORE": "周杰伦\n"]
    }
    
    func generatePropList(type: TestType) -> [Int] {
        var propList: [Int] = [Int]()
        switch type {
        case .Search:
            propList.append(Int(EVoiceRecognitionPropertySearch.value))
        case .Input:
            propList.append(Int(EVoiceRecognitionPropertyInput.value))
        default:
            // domain types, get prop according to the test file name prefix, such as call_male73.pcm
            switch mCurrentFileName.componentsSeparatedByString("_")[0] {
            case "call", "msg":
                propList.append(Int(EVoiceRecognitionPropertyCall.value))
            case "music":
                propList.append(Int(EVoiceRecognitionPropertyMusic.value))
            case "app":
                propList.append(Int(EVoiceRecognitionPropertyApp.value))
            case "navi":
                propList.append(Int(EVoiceRecognitionPropertyMap.value))
            case "contact":
                propList.append(Int(EVoiceRecognitionPropertyContacts.value))
            case "cmd":
                propList.append(Int(EVoiceRecognitionPropertySetting.value))
            case "channel":
                propList.append(Int(EVoiceRecognitionPropertyTVInstruction.value))
            case "player":
                propList.append(Int(EVoiceRecognitionPropertyPlayerInstruction.value))
            case "radio":
                propList.append(Int(EVoiceRecognitionPropertyRadio.value))
            default:
                break
            }
        }
        return propList
    }

    func getFullFilePath(dir: String, fileName: String) -> String {
        var fullPath = String()
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if dirs != nil {
            // get documents directory
            let docDir = dirs![0]
            fullPath = docDir.stringByAppendingPathComponent("voicerecognition").stringByAppendingPathComponent(dir).stringByAppendingPathComponent(fileName)
        }
        return fullPath
    }
    
    func beforeOneRoundRcognition() {
        let round = mCurrentFileIndex + 1
        mResponseTimeCounter.startValue = NSDate()
        mIsFirstUpdate = true
        
        if mIsSingleFileTest {
            mCurrentFileName = mTestConfig.singleTestFileName!
        } else {
            mCurrentFileName = mCurrentFileArray[mCurrentFileIndex]
        }
        
        mCurrentAnswer = mCurrentAnswerMap[mCurrentFileName]!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        mTestSum.fileName = mCurrentFileName
        mTestSum.round = String(round)
        mTestSum.sampleRate = String(mCurrentSampleRate)
        updateUI(mTestSum.toString(), label: mLabelTestInfo)
        updateUI(mCurrentAnswer, label: mLabelAnswerRegion)
        updateUI("", label: mLabelRecognitionResult)
    }
    
    func resolveRecognition(obj: AnyObject, isFinish: Bool) -> String {
        if isFinish {
            println("[audio server return raw object is]: \(obj)")
        }
        var tmpResult: String = ""
        switch mTestConfig.testType {
        case .Search:
            var resultsArray: [String] = obj as! [String]
            tmpResult = resultsArray[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        case .Input:
            tmpResult = ""
            if !isFinish {
                var candidates: [String] = obj as! [String]
                tmpResult = candidates[0]
            } else {
                // in the dic, key is recognition text, value is confidence
                for resultSplit in obj as! [[[String: Int]]]{
                    // get first candidate
                    var firstCandidate = resultSplit[0]
                    var keyArray = Array(firstCandidate.keys)
                    tmpResult += keyArray[0]
                }
            }
        case .Domain:
            var rootArray = obj as! [String]
            var nluResult = rootArray[0]
            // partial result is different from final ones
            if !isFinish {
                // partial result
                tmpResult = nluResult
            } else {
                // final result
                var jsonError: NSError?
                let nluResultJSON = NSJSONSerialization.JSONObjectWithData(nluResult.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError)as! [String: AnyObject]
                // get item list, which is an jsonArray
                let itemListArray = nluResultJSON["item"] as! [String]
                tmpResult = itemListArray[0]
                if itemListArray.count > 1 {
                    // server result
                    mNluOnlineResolveCounter.plusOneRoundValue(ONE_ROUND_RESULT.Success.rawValue)
                } else {
                    // embed result
                    mNluOnlineResolveCounter.plusOneRoundValue(ONE_ROUND_RESULT.Fail.rawValue)
                }
                
                let jsonRes = nluResultJSON["json_res"] as! String
                let domainName: String = resolveDomainFromJson(jsonRes)
                println(domainName)
                if isDomainCorrect(domainName, fileName: mCurrentFileName) {
                    mNluAccurateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Success.rawValue)
                } else {
                    mNluAccurateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Fail.rawValue)
                }
            }
        default:
            break
        }
        println(tmpResult)
        return getRidOfLicenseWarning(tmpResult)
    }
    
    func getRidOfLicenseWarning(rawResult: String) -> String {
        let potentialRange = rawResult.rangeOfString("]")
        if let range = potentialRange {
            let actualRecognitionResultIndex = advance(range.startIndex, 1)
            let actualRecognitionResult = rawResult.substringFromIndex(actualRecognitionResultIndex)
            return actualRecognitionResult
        } else {
            return rawResult
        }
    }
    
    func isDomainCorrect(domain: String, fileName: String) -> Bool {
        let fileNamePrefix = fileName.componentsSeparatedByString("_")[0]
        if let correctPrefix = domainAndFilenameMap[domain] {
            if fileNamePrefix == correctPrefix {
                return true
            }
        }
        return false
    }
    
    func resolveDomainFromJson(jsonResString: String) -> String {
        println("[json res string is]: \(jsonResString)")
        var returnDomain: String = String()
        // {"json_res":"{\"result\":[{\"score\":1,\"domain\":\"radio\",\"object\":[]
        // ,\"intent\":\"open\",\"demand\":0}],\"parsed_text\":\"FM\"
        // ,\"raw_text\":\"FM\"}","item":["[百度语音试用服务122天后到期]FM"]}
        var jsonError: NSError?
        let jsonResJSON = NSJSONSerialization.JSONObjectWithData(jsonResString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError) as! [String: AnyObject]
        let resultArrayJSON = jsonResJSON["results"] as! [AnyObject]
        if resultArrayJSON.count > 0 {
            // bug, sometime the reuslt arry is empty
            let oneResult = resultArrayJSON[0] as! [String: AnyObject]
            returnDomain = oneResult["domain"] as! String
        }
        return returnDomain
    }
    
    func getStatistics() {
        // get recognition time
        mRecognitionTimeCounter.finishValue = NSDate()
        if let date = mRecognitionTimeCounter.finishValue as? NSDate {
            mRecognitionTimeCounter.plusOneRoundValue(date.timeIntervalSinceDate(mRecognitionTimeCounter.startValue as! NSDate))
        }
        
        // write result to output file
        recoResultOutputFileHandler.writeLine(mCurrentFileName + ":" + mCurrentRecognition)
    }
    
    func afterOneRoundRecognition(isFinishSuccessFully: Bool) {
        // after one round recogniton, no matter succeed or fail, this program needs to
        // record the useful information
        getStatistics()
        if !isFinishSuccessFully {
            mCurrentRetryTime++
            // only count one time fail
            if mCurrentRetryTime == 1 {
                mSuccessRateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Fail.rawValue)
            }
            // exceed the max retry time, it's time to move on
            if mCurrentRetryTime >= MAX_RETRY_TIME {
                mCurrentRetryTime = 0
                mCurrentFileIndex++
            }
        } else {
            // recognition success, need record the current result
            recordOneRoundResults()
            mCurrentRetryTime = 0
            mCurrentFileIndex++
            mSuccessRateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Success.rawValue)
        }
        
        if mCurrentFileIndex < mCurrentRoundMaxTestNumber {
            updateUI(String(format: "%1.2f", mSuccessRateCounter.getAverValue()), label: mLabelRecogntionSuccessRate)
            if mTestConfig.testType == TestType.Search {
                updateUI(String(format: "%1.2f", mAccurateRateCounter.getAverValue()), label: mLabelRecognitionAccuracyRate)
            }
            // just start another round recognition
            startOneRoundRecognition()
        } else {
            // one round auto test over
            switch mTestConfig.testSampleRate {
            case TEST_CONFIG_SAMPLERATE_8K:
                afterOneRoundAutotest()
                afterOneRoundTask()
            case TEST_CONFIG_SAMPLERATE_16K:
                afterOneRoundAutotest()
                afterOneRoundTask()
            case TEST_CONFIG_SAMPLERATE_8K_AND_16K:
                if mCurrentSampleRate == Int32(TEST_CONFIG_SAMPLERATE_8K) {
                    // need to run 8k and 16k, now 8k is over, 16 needed to be run
                    afterOneRoundAutotest()
                    startOneRoundAutoTest(TEST_CONFIG_SAMPLERATE_16K)
                } else {
                    // both 8k and 16k are over
                    afterOneRoundAutotest()
                    afterOneRoundTask()
                }
                break
            default:
                break
            }
        }
    }
    
    func recordOneRoundResults() {
        // there is a little difference between mode search and input
        if mTestConfig.testType == TestType.Search {
            // search mode need to judge if current result is accurate.
            if mCurrentRecognition == mCurrentAnswer {
                mAccurateRateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Success.rawValue)
            } else {
                mAccurateRateCounter.plusOneRoundValue(ONE_ROUND_RESULT.Fail.rawValue)
            }
        } else {
            // input mode need to record recognitoon to get accuracy rate.
            // the accuracy calculator is on server
            // [add 2015/01/26] in domain test, we need word accuracy.
            // mReconigtionResult could be null, because in nlu mode, there is
            // a likelihood that mReconigtionResult can't be resolved correctly
            mInputRecognitionResultsJsonArray.append(mCurrentFileName + ":" + mCurrentRecognition)
        }
    }
    
    func afterOneRoundTask() {
        // transform the json object into string
        mUploadContent = NSString(data: NSJSONSerialization.dataWithJSONObject(mUploadJson, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!, encoding: NSUTF8StringEncoding)! as String
        var uploadRecognitionResultOperation: CalculateWordAccuracyOperation
        if mTestConfig.testType == TestType.Search {
            // for now, search mode doesn't need send result to server
//            uploadRecognitionResultOperation = CalculateWordAccuracyOperation(inQueue: mCheckWordAccuracyQueue,
//                withContent: mUploadContent, toUrl:SEARCH_URL, delegate: self)
            showTestResult(m8kDisplayer, displayer16k: m16kDisplayer)
        } else {
            uploadRecognitionResultOperation = CalculateWordAccuracyOperation(inQueue: mCheckWordAccuracyQueue,
                withContent: mUploadContent, toUrl:INPUT_URL, delegate: self)
            uploadRecognitionResultOperation.send()
        }
    }
    
    func showTestResult(displayer8k: ResultDisplayer?, displayer16k: ResultDisplayer?) {
        updateUI("8k测试信息", label: mLabelAccuracyRateHint)
        updateUI("16k测试信息", label: mLabelSuccessRateHint)
        if let dis8k = displayer8k {
            updateUI(dis8k.toString(), label: mLabelRecognitionAccuracyRate)
        }
        if let dis16k = displayer16k {
            updateUI(dis16k.toString(), label: mLabelRecogntionSuccessRate)
        }
    }
    
    func afterOneRoundAutotest() {
        self.checkPerformanceThread?.stopChecking()
        
        setDisplayer(mCurrentSampleRate)
        generateSendPackage()
        mInputRecognitionResultsJsonArray.removeAll(keepCapacity: false)
    }
    
    func setDisplayer(sampleRate: Int32) {
        if mCurrentSampleRate == Int32(TEST_CONFIG_SAMPLERATE_8K) {
            // 8k result displayer
            m8kDisplayer = ResultDisplayer()
            m8kDisplayer!.accuracyRate = String(format: "%1.2f", mAccurateRateCounter.getAverValue())
            m8kDisplayer!.successRate = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
            m8kDisplayer!.responseTime = String(format: "%1.2fs", mResponseTimeCounter.getAverValue())
            m8kDisplayer!.recognitionTime = String(format: "%1.2fs", mRecognitionTimeCounter.getAverValue())
            m8kDisplayer!.memoryUsage = String(format: "%1.2fK", mMemCounter.getAverValue())
            m8kDisplayer!.cpuUsage = String(format: "%1.2f%%", mCpuCounter.getAverValue())
        } else {
            // 16k
            if mTestConfig.testType == TestType.Domain {
                m16kDisplayer = DomainResultDisplayer()
            } else {
                m16kDisplayer = ResultDisplayer()
            }
            m16kDisplayer!.accuracyRate = String(format: "%1.2f", mAccurateRateCounter.getAverValue())
            m16kDisplayer!.successRate = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
            m16kDisplayer!.responseTime = String(format: "%1.2fs", mResponseTimeCounter.getAverValue())
            m16kDisplayer!.recognitionTime = String(format: "%1.2fs", mRecognitionTimeCounter.getAverValue())
            m16kDisplayer!.memoryUsage = String(format: "%1.2fK", mMemCounter.getAverValue())
            m16kDisplayer!.cpuUsage = String(format: "%1.2f%%", mCpuCounter.getAverValue())
            if let displayer = m16kDisplayer as? DomainResultDisplayer {
                displayer.nluAccurateRate = String(format: "%1.2f", mNluAccurateCounter.getAverValue())
                displayer.nluOnlineRate = String(format: "%1.2f", mNluOnlineResolveCounter.getAverValue())
            }
        }
    }
    
    func generateSendPackage() {
        mUploadJson["mail_prefix"] = "lisheng02"
        if mTestConfig.testType == TestType.Search {
            // the uploaded package for search mode
            switch mCurrentSampleRate {
            case Int32(TEST_CONFIG_SAMPLERATE_8K):
                var result8kJson: [String: String] = [String: String]()
                result8kJson["SuccessRate"] = m8kDisplayer!.successRate
                result8kJson["AccuracyRate"] = m8kDisplayer!.accuracyRate
                result8kJson["ResponseTime"] = m8kDisplayer!.responseTime
                result8kJson["RecognitionTime"] = m8kDisplayer!.recognitionTime
                result8kJson["MEM"] = m8kDisplayer!.memoryUsage
                result8kJson["CPU"] = m8kDisplayer!.cpuUsage
                mUploadJson["result_8k"] = result8kJson
            case Int32(TEST_CONFIG_SAMPLERATE_16K):
                var result16kJson: [String: String] = [String: String]()
                result16kJson["SuccessRate"] = m16kDisplayer!.successRate
                result16kJson["AccuracyRate"] = m16kDisplayer!.accuracyRate
                result16kJson["ResponseTime"] = m16kDisplayer!.responseTime
                result16kJson["RecognitionTime"] = m16kDisplayer!.recognitionTime
                result16kJson["MEM"] = m16kDisplayer!.memoryUsage
                result16kJson["CPU"] = m16kDisplayer!.cpuUsage
                mUploadJson["result_16k"] = result16kJson
            default:
                break
            }
        } else {
            // the uploaded package for modes that need to get word accuracy, such as
            // input and domain
            switch mCurrentSampleRate {
            case Int32(TEST_CONFIG_SAMPLERATE_8K):
                mUploadJson["8k_result"] = mInputRecognitionResultsJsonArray
                mUploadJson["8k_success_rate"] = m8kDisplayer!.successRate
                mUploadJson["8k_recognition_time"] = m8kDisplayer!.recognitionTime
                mUploadJson["8k_response_time"] = m8kDisplayer!.responseTime
                mUploadJson["8k_mem_usage"] = m8kDisplayer!.memoryUsage
                mUploadJson["8k_cpu_usage"] = m8kDisplayer!.cpuUsage
            case Int32(TEST_CONFIG_SAMPLERATE_16K):
                mUploadJson["16k_result"] = mInputRecognitionResultsJsonArray
                mUploadJson["16k_success_rate"] = m16kDisplayer!.successRate
                mUploadJson["16k_recognition_time"] = m16kDisplayer!.recognitionTime
                mUploadJson["16k_response_time"] = m16kDisplayer!.responseTime
                mUploadJson["16k_mem_usage"] = m16kDisplayer!.memoryUsage
                mUploadJson["16k_cpu_usage"] = m16kDisplayer!.cpuUsage
                if mTestConfig.testType == TestType.Domain {
                    mUploadJson["16k_nlu_triggered_rate"] = String(format: "%1.2f", mNluAccurateCounter.getAverValue())
                }
            default:
                break
            }
        }
    }
    
    func updateUI(text: String, label: UILabel) {
        dispatch_async(dispatch_get_main_queue(), {
            label.text = text
        })
    }
    
    // MARK: - MVoiceRecognitionClientDelegate
    
    func VoiceRecognitionClientWorkStatus(aStatus: Int32, obj aObj: AnyObject!) {
        switch aStatus {
        case Int32(EVoiceRecognitionClientWorkStatusStartWorkIng.value):
            // start working
            updateUI("开始工作", label: mLabelTestProgress)
        case Int32(EVoiceRecognitionClientWorkStatusStart.value):
            updateUI("检测到用户说话", label: mLabelTestProgress)
        case Int32(EVoiceRecognitionClientWorkStatusEnd.value):
            updateUI("录音结束，等待服务器", label: mLabelTestProgress)
            mRecognitionTimeCounter.startValue = NSDate()
        case Int32(EVoiceRecognitionClientWorkStatusFlushData.value):
            updateUI("连续上屏", label: mLabelTestProgress)
            // partial result
            if mIsFirstUpdate {
                mResponseTimeCounter.finishValue = NSDate()
                if let date = mResponseTimeCounter.finishValue as? NSDate {
                    mResponseTimeCounter.plusOneRoundValue(date.timeIntervalSinceDate(mResponseTimeCounter.startValue as! NSDate))
                }
                mIsFirstUpdate = false
            }
            mCurrentRecognition = resolveRecognition(aObj, isFinish: false)
            updateUI(mCurrentRecognition, label: mLabelRecognitionResult)
        case Int32(EVoiceRecognitionClientWorkStatusFinish.value):
            // update ui state first
            updateUI("识别结束", label: mLabelTestProgress)
            // final result
            mCurrentRecognition = resolveRecognition(aObj, isFinish: true)
            updateUI(mCurrentRecognition, label: mLabelRecognitionResult)
            afterOneRoundRecognition(true)
        case Int32(EVoiceRecognitionClientWorkStatusError.value):
            updateUI("识别出错", label: mLabelTestProgress)
            afterOneRoundRecognition(false)
        default:
            break
        }

    }
    
    func VoiceRecognitionClientErrorStatus(aStatus: Int32, subStatus aSubStatus: Int32) {
        println("error happens")
        var errorInfo: String = mCurrentFileName + ": "
        switch aStatus {
        case Int32(EVoiceRecognitionClientErrorStatusClassVDP.value):
            errorInfo += ("audio process happens: " + String(aSubStatus))
            println("audio process happens: " + String(aSubStatus))
            break
        case Int32(EVoiceRecognitionClientErrorStatusClassRecord.value):
            errorInfo += ("audio record error happens: " + String(aSubStatus))
            println("audio record error happens: " + String(aSubStatus))
            break
        case Int32(EVoiceRecognitionClientErrorStatusClassLocalNet.value):
            errorInfo += ("network error: " + String(aSubStatus))
            println("network error: " + String(aSubStatus))
            break
        case Int32(EVoiceRecognitionClientErrorStatusClassServerNet.value):
            errorInfo += ("server error: " + String(aSubStatus))
            println("engine error: " + String(aSubStatus))
            break
        default:
            break
        }
        errorOutputFileHandler.writeLine(errorInfo)

    }
    
    func VoiceRecognitionClientNetWorkStatus(aStatus: Int32) {
        
    }
    
    // MARK: - VTResponseDelegate
    
    func onResponseGotten(response: AnyObject) {
        let dic: [String: AnyObject] = response as! [String: AnyObject]
        for (key, value) in dic {
            switch key {
            case RESPONSE_8K_ACCURACY_KEY:
                if let displayer8K = m8kDisplayer {
                    // sample rate 8k test
                    displayer8K.accuracyRate = value as! String
                }
            case RESPONSE_16K_ACCURACY_KEY:
                // RESPONSE_16K_ACCURACY_KEY
                if let displayer16K = m16kDisplayer {
                    // sample rate 16k test
                    displayer16K.accuracyRate = value as! String
                }
            case RESPONSE_LAST_VERSION_KEY:
                // RESPONSE_LAST_VERSION_KEY
                if let lastDatas = value as? [[String: String]] {
                    for oneSampleRateData in lastDatas {
                        switch oneSampleRateData[StatKey.SAMPLE_RATE.rawValue]! {
                        case "8k":
                            lastVersonData.inflateData(KEY_8K_DATA, lastVersionData: oneSampleRateData)
                        case "16k":
                            lastVersonData.inflateData(KEY_16K_DATA, lastVersionData: oneSampleRateData)
                        default:
                            break
                        }
                    }
                }
            default:
                break
            }
        }
        showTestResult(m8kDisplayer, displayer16k: m16kDisplayer)
    }
    
    func onResponseError(errorType: VTResponseError) {
        switch errorType {
        case VTResponseError.VTResponseNetworkError:
            updateUI("发送测试结果网络连接错误", label: mLabelTestProgress)
            break
        case VTResponseError.VTResponseResolutionError:
            updateUI("测试服务器返回结果格式有误", label: mLabelTestProgress)
            break
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_detail_stat" {
            let detailVC = segue.destinationViewController as! DetailResultViewController
            detailVC.pageTitles = ["response time", "mem usage", "cpu usage"]
            detailVC.pageValues = [
                mResponseTimeCounter.getHistoryValue(),
                mMemCounter.getHistoryValue(),
                mCpuCounter.getHistoryValue()
            ]
        }
    }
    
}
