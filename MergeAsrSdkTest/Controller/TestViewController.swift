//
//  TestViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

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
    
    let MAX_RETRY_TIME: Int = 5
    
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
    lazy var mRecognitionTimeCounter: TestInfoCounter = TestInfoCounter()
    lazy var mSuccessRateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mAccurateRateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mResponseTimeCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluTriggeredCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluAccurateCounter: TestInfoCounter = TestInfoCounter()
    lazy var mNluOnlineResolveCounter: TestInfoCounter = TestInfoCounter()
    
    lazy var mTestSum: TestSummarize = TestSummarize()
    var m8kDisplayer: ResultDisplayer?
    var m16kDisplayer: ResultDisplayer?
    
    // input recognition array
    lazy var mUploadContent: String = String()
    var mInputRecognitionResultsJsonArray: [String]?
    var mUploadRecognitionResultsJsonObject: [String: String]?
    
    // test queue
    lazy var mTestTaskQueue: NSOperationQueue = NSOperationQueue()
    lazy var mCheckWordAccuracyQueue: NSOperationQueue = NSOperationQueue()
    
    let domainAndFilenameMap: [String: String] = ["telephone": "call", "message": "msg", "music": "music", "app": "app", "navigate_instruction": "navi", "contacts": "contact", "setting": "cmd", "tv_instruction": "channel", "player_instruction": "player", "radio": "radio"]
    
    // some control variables
    var mIsFirstUpdate: Bool = true
    var mIsSingleFileTest: Bool = false
    
    // MARK: - Override UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !loadFileNameAndAnswer() {
            mLabelTestInfo.text = ""
            return
        }
        startOneRoundTask()
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
            let answerFileContent: String? = String(contentsOfFile: answerFilePath, encoding:NSUTF8StringEncoding, error: nil)
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
            
            let fileListOfDir: [String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(fileDirPath, error: nil) as [String]
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
        mUploadRecognitionResultsJsonObject = [String: String]()

        updateUI("准确率: ", label: mLabelAccuracyRateHint)
        updateUI("识别率: ", label: mLabelSuccessRateHint)
        
        // judge if it is singlefile test according to the config.singleFileName
        if let fileName = mTestConfig.singleTestFileName {
            mIsSingleFileTest = true
        } else {
            mIsSingleFileTest = false
        }
    }
    
    
    
    func startOneRoundAutoTest(currentSampleRate: Int) {
        initOneRoundValues()
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
    
    func initOneRoundValues() {
        mRecognitionTimeCounter.resetCounter()
        mResponseTimeCounter.resetCounter()
        mSuccessRateCounter.resetCounter()
        mAccurateRateCounter.resetCounter()
        
        mCurrentFileIndex = 0
        mInputRecognitionResultsJsonArray = [String]()
    }
    
    func startOneRoundRecognition() {
        var oneRoundRecogntionOperation: NSBlockOperation = NSBlockOperation({
            self.oneRoundRecognitionProcess()
        })
        mTestTaskQueue.addOperation(oneRoundRecogntionOperation)
    }
    
    func oneRoundRecognitionProcess() {
        println("=============== one recognition operation start ===============")
        beforeOneRoundRcognition()
        
        let fileFullPath: String = getFullFilePath(mCurrentTestFileDirName, fileName: mCurrentFileName)
        let propList: [Int] = generatePropList(mTestConfig.testType)
        var cid: Int = 0
        BDVoiceRecognitionClient.sharedInstance().setApiKey("8MAxI5o7VjKSZOKeBzS4XtxO", withSecretKey: "Ge5GXVdGQpaxOmLzc8fOM8309ATCz9Ha")
        println("full file path is: " + fileFullPath)
        // init the file recognizer
        mVoiceRecognitionFileRecognizer = BDVRFileRecognizer(fileRecognizerWithFilePath: fileFullPath, sampleRate: mCurrentSampleRate, propertyGroup: propList, cityID: cid, delegate: self)
        
        // congfig the recognizer
        mVoiceRecognitionFileRecognizer!.appCode = "";
        mVoiceRecognitionFileRecognizer!.licenseFilePath = NSBundle.mainBundle().pathForResource("bdasr_license", ofType: "dat")
        mVoiceRecognitionFileRecognizer!.datFilePath = NSBundle.mainBundle().pathForResource("s_1", ofType: "")
        
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
            mVoiceRecognitionFileRecognizer!.LMDatFilePath = NSBundle.mainBundle().pathForResource("s_2_Navi", ofType: "")
            BDVoiceRecognitionClient.sharedInstance().setResourceType(RESOURCE_TYPE_NONE)
        }
        // set strategy
        mVoiceRecognitionFileRecognizer!.recognitionStrategy = Int32(RECOGNITION_STRATEGY_OFFLINE_PRI.value)
        // start file recognition
        var status = Int(mVoiceRecognitionFileRecognizer!.startFileRecognition())
        
        if status != Int(EVoiceRecognitionStartWorking.value) {
            println("File recognizer start working failed, status is: " + String(status))
        }
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
        mRecognitionTimeCounter.startValue = NSDate()
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
            println("[server return raw object is]: \(obj)")
        }
        var tmpResult: String?
        switch mTestConfig.testType {
        case .Search:
            var resultsArray: [String] = obj as [String]
            tmpResult = resultsArray[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        case .Input:
            tmpResult = ""
            if !isFinish {
                var candidates: [String] = obj as [String]
                tmpResult = candidates[0]
            } else {
                // in the dic, key is recognition text, value is confidence
                for resultSplit in obj as [[[String: Int]]]{
                    // get first candidate
                    var firstCandidate = resultSplit[0]
                    var keyArray = Array(firstCandidate.keys)
                    tmpResult = keyArray[0]
                }
            }
        case .Domain:
            var rootArray = obj as [String]
            var nluResult = rootArray[0]
            // partial result is different from final ones
            if !isFinish {
                // partial result
                tmpResult = nluResult
            } else {
                // final result
                var jsonError: NSError?
                let nluResultJSON = NSJSONSerialization.JSONObjectWithData(nluResult.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError) as [String: AnyObject]
                // get item list, which is an jsonArray
                let itemListArray = nluResultJSON["item"] as [String]
                tmpResult = itemListArray[0]
                if itemListArray.count > 1 {
                    // server result
                    mNluOnlineResolveCounter.plusOneRoundValue(ONE_ROUND_RESULT.Success.rawValue)
                } else {
                    // embed result
                    mNluOnlineResolveCounter.plusOneRoundValue(ONE_ROUND_RESULT.Fail.rawValue)
                }
                
                let jsonRes = nluResultJSON["json_res"] as String
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
        println(tmpResult!)
        return getRidOfLicenseWarning(tmpResult!)
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
        let jsonResJSON = NSJSONSerialization.JSONObjectWithData(jsonResString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError) as [String: AnyObject]
        let resultArrayJSON = jsonResJSON["results"] as [AnyObject]
        if resultArrayJSON.count > 0 {
            // bug, sometime the reuslt arry is empty
            let oneResult = resultArrayJSON[0] as [String: AnyObject]
            returnDomain = oneResult["domain"] as String
        }
        return returnDomain
    }
    
    func getStatistics() {
        // get recognition time
        mRecognitionTimeCounter.finishValue = NSDate()
        if let date = mRecognitionTimeCounter.finishValue as? NSDate {
            mRecognitionTimeCounter.plusOneRoundValue(date.timeIntervalSinceDate(mRecognitionTimeCounter.startValue as NSDate))
        }
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
            generateSendPackage()
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
            mInputRecognitionResultsJsonArray!.append(mCurrentFileName + ":" + mCurrentRecognition)
        }
    }
    
    func afterOneRoundTask() {
        // transform the json object into string
        mUploadContent = NSString(data: NSJSONSerialization.dataWithJSONObject(mUploadRecognitionResultsJsonObject!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!, encoding: NSUTF8StringEncoding)!
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
        resetTaskVariable()
    }
    
    func resetTaskVariable() {
        mUploadRecognitionResultsJsonObject = nil
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
        setDisplayer(mCurrentSampleRate)
        mInputRecognitionResultsJsonArray = nil
    }
    
    func setDisplayer(sampleRate: Int32) {
        if mCurrentSampleRate == Int32(TEST_CONFIG_SAMPLERATE_8K) {
            // 8k result displayer
            m8kDisplayer = ResultDisplayer()
            m8kDisplayer!.accuracyRate = String(format: "准确率: %1.2f", mAccurateRateCounter.getAverValue())
            m8kDisplayer!.successRate = String(format: "识别率: %1.2f", mSuccessRateCounter.getAverValue())
            m8kDisplayer!.responseTime = String(format: "响应时间: %1.2fs", mResponseTimeCounter.getAverValue())
            m8kDisplayer!.recognitionTime = String(format: "识别时间: %1.2fs", mRecognitionTimeCounter.getAverValue())
        } else {
            // 16k
            if mTestConfig.testType == TestType.Domain {
                m16kDisplayer = DomainResultDisplayer()
            } else {
                m16kDisplayer = ResultDisplayer()
            }
            m16kDisplayer!.accuracyRate = String(format: "准确率: %1.2f", mAccurateRateCounter.getAverValue())
            m16kDisplayer!.successRate = String(format: "识别率: %1.2f", mSuccessRateCounter.getAverValue())
            m16kDisplayer!.responseTime = String(format: "响应时间: %1.2fs", mResponseTimeCounter.getAverValue())
            m16kDisplayer!.recognitionTime = String(format: "识别时间: %1.2fs", mRecognitionTimeCounter.getAverValue())
            if let displayer = m16kDisplayer as? DomainResultDisplayer {
                displayer.nluAccurateRate = String(format: "nlu准确率: %1.2f", mNluAccurateCounter.getAverValue())
                displayer.nluOnlineRate = String(format: "server识别占比: %1.2f", mNluOnlineResolveCounter.getAverValue())
            }
        }
    }
    
    func generateSendPackage() {
        mUploadRecognitionResultsJsonObject!["mail_prefix"] = "lisheng02"
        if mTestConfig.testType == TestType.Search {
            // the uploaded package for search mode
            switch mCurrentSampleRate {
            case Int32(TEST_CONFIG_SAMPLERATE_8K):
                var result8kJson: [String: String] = [String: String]()
                result8kJson["[Success Rate]"] = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
                result8kJson["[Accuracy Rate]"] = String(format: "%1.2f", mAccurateRateCounter.getAverValue())
                result8kJson["[Response Rate]"] = String(format: "%1.2f", mResponseTimeCounter.getAverValue())
                result8kJson["[Recognition Rate]"] = String(format: "%1.2f", mRecognitionTimeCounter.getAverValue())
                let result8kJsonData = NSJSONSerialization.dataWithJSONObject(result8kJson, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
                mUploadRecognitionResultsJsonObject!["result_8k"] = NSString(data: result8kJsonData, encoding: NSUTF8StringEncoding)
            case Int32(TEST_CONFIG_SAMPLERATE_16K):
                var result16kJson: [String: String] = [String: String]()
                result16kJson["[Success Rate]"] = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
                result16kJson["[Accuracy Rate]"] = String(format: "%1.2f", mAccurateRateCounter.getAverValue())
                result16kJson["[Response Rate]"] = String(format: "%1.2f", mResponseTimeCounter.getAverValue())
                result16kJson["[Recognition Rate]"] = String(format: "%1.2f", mRecognitionTimeCounter.getAverValue())
                let result16kJsonData = NSJSONSerialization.dataWithJSONObject(result16kJson, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
                mUploadRecognitionResultsJsonObject!["result_16k"] = NSString(data: result16kJsonData, encoding: NSUTF8StringEncoding)
            default:
                break
            }
        } else {
            // the uploaded package for modes that need to get word accuracy, such as input and domain
            switch mCurrentSampleRate {
            case Int32(TEST_CONFIG_SAMPLERATE_8K):
                let result8kJsonData = NSJSONSerialization.dataWithJSONObject(mInputRecognitionResultsJsonArray!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
                mUploadRecognitionResultsJsonObject!["8k_result"] = NSString(data: result8kJsonData, encoding: NSUTF8StringEncoding)
                mUploadRecognitionResultsJsonObject!["8k_success_rate"] = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
                mUploadRecognitionResultsJsonObject!["8k_recognition_time"] = String(format: "%1.2f", mRecognitionTimeCounter.getAverValue())
                mUploadRecognitionResultsJsonObject!["8k_response_time"] = String(format: "%1.2f", mResponseTimeCounter.getAverValue())
            case Int32(TEST_CONFIG_SAMPLERATE_16K):
                let result16kJsonData = NSJSONSerialization.dataWithJSONObject(mInputRecognitionResultsJsonArray!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
                mUploadRecognitionResultsJsonObject!["16k_result"] = NSString(data: result16kJsonData, encoding: NSUTF8StringEncoding)
                mUploadRecognitionResultsJsonObject!["16k_success_rate"] = String(format: "%1.2f", mSuccessRateCounter.getAverValue())
                mUploadRecognitionResultsJsonObject!["16k_recognition_time"] = String(format: "%1.2f", mRecognitionTimeCounter.getAverValue())
                mUploadRecognitionResultsJsonObject!["16k_response_time"] = String(format: "%1.2f", mResponseTimeCounter.getAverValue())
                if mTestConfig.testType == TestType.Domain {
                    mUploadRecognitionResultsJsonObject!["16k_nlu_triggered_rate"] = String(format: "%1.2f", mNluAccurateCounter.getAverValue())
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
    
    func VoiceRecognitionClientWorkStatus(aStatus: Int, obj aObj: AnyObject) {
        switch aStatus {
        case Int(EVoiceRecognitionClientWorkStatusStartWorkIng.value):
            // start working
            ()
        case Int(EVoiceRecognitionClientWorkStatusStart.value):
            updateUI("检测到用户说话", label: mLabelTestProgress)
        case Int(EVoiceRecognitionClientWorkStatusEnd.value):
            updateUI("录音结束，等待服务器", label: mLabelTestProgress)
        case Int(EVoiceRecognitionClientWorkStatusFlushData.value):
            updateUI("连续上屏", label: mLabelTestProgress)
            // partial result
            if mIsFirstUpdate {
                mResponseTimeCounter.finishValue = NSDate()
                if let date = mResponseTimeCounter.finishValue as? NSDate {
                    mResponseTimeCounter.plusOneRoundValue(date.timeIntervalSinceDate(mResponseTimeCounter.startValue as NSDate))
                }
                mIsFirstUpdate = false
            }
            mCurrentRecognition = resolveRecognition(aObj, isFinish: false)
            updateUI(mCurrentRecognition, label: mLabelRecognitionResult)
        case Int(EVoiceRecognitionClientWorkStatusFinish.value):
            // update ui state first
            updateUI("识别结束", label: mLabelTestProgress)
            // final result
            mCurrentRecognition = resolveRecognition(aObj, isFinish: true)
            updateUI(mCurrentRecognition, label: mLabelRecognitionResult)
            afterOneRoundRecognition(true)
        case Int(EVoiceRecognitionClientWorkStatusError.value):
            updateUI("识别出错", label: mLabelTestProgress)
            afterOneRoundRecognition(false)
        default:
            break
        }
    }
    
    func VoiceRecognitionClientErrorStatus(aStatus: Int, subStatus aSubStatus: Int) {
        println("error happens")
        switch aStatus {
        case Int(EVoiceRecognitionClientErrorStatusClassVDP.value):
            println("audio process happens: " + String(aSubStatus))
            break
        case Int(EVoiceRecognitionClientErrorStatusClassRecord.value):
            println("audio record error happens: " + String(aSubStatus))
            break
        case Int(EVoiceRecognitionClientErrorStatusClassLocalNet.value):
            println("network error: " + String(aSubStatus))
            break
        case Int(EVoiceRecognitionClientErrorStatusClassServerNet.value):
            println("server error: " + String(aSubStatus))
            break
        default:
            break
        }
    }
    
    func VoiceRecognitionClientNetWorkStatus(aStatus: Int) {
    }
    
    // MARK: - VTResponseDelegate
    
    func onResponseGotten(response: AnyObject) {
        let dic: [String: String] = response as [String: String]
        for (key, value) in dic {
            switch key {
            case RESPONSE_8K_ACCURACY_KEY:
                if let displayer8K = m8kDisplayer {
                    // sample rate 8k test
                    displayer8K.accuracyRate = "准确率: " + value
                }
            default:
                // RESPONSE_16K_ACCURACY_KEY
                if let displayer16K = m16kDisplayer {
                    // sample rate 16k test
                    displayer16K.accuracyRate = "准确率: " + value
                }
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
            updateUI("测试结果格式有误", label: mLabelTestProgress)
            break
        default:
            break
        }
    }
    
}
