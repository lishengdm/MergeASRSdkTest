//
//  BDVRErrorCodes.h
//  VoiceRecognitionEngine
//
//  Created by lappi on 4/30/15.
//  Copyright (c) 2015 baidu. All rights reserved.
//

#ifndef VoiceRecognitionEngine_BDVRErrorCodes_h
#define VoiceRecognitionEngine_BDVRErrorCodes_h

// 枚举 - 语音识别错误通知状态分类
typedef enum TVoiceRecognitionClientErrorStatusClass
{
    EVoiceRecognitinoClientErrorStatusClassGeneral = 900,
    EVoiceRecognitionClientErrorStatusClassVDP = 1100,        // 语音数据处理过程出错
    EVoiceRecognitionClientErrorStatusClassRecord = 1200,     // 录音出错
    EVoiceRecognitionClientErrorStatusClassLocalNet = 1300,   // 本地网络联接出错
    EVoiceRecognitionClientErrorStatusClassServerNet = 3000,  // 服务器返回网络错误
    EVoiceRecognitionClientErrorStatusClassOffline = 4000,    // 离线识别出错
}TVoiceRecognitionClientErrorStatusClass;

// 枚举 - 语音识别错误通知状态
typedef enum TVoiceRecognitionClientErrorStatus
{
    EVoiceRecognitionClientErrorOK = 0,                         // Success.
    
    // =================================== Generic errors ==================================================
    /* Engine is busy, cancel VR first and try again. */
    EVoiceRecognitionClientErrorBusy = EVoiceRecognitinoClientErrorStatusClassGeneral+1,
    /* Initialization failed */
    EVoiceRecognitionClientErrorInitError,
    /* Invalid parameters */
    EVoiceRecognitionClientErrorParam,
    /* Engine is not initialized */
    EVoiceRecognitionClientErrorNotInit,
    /* Requested feature is not supported by this version of SDK */
    EVoiceRecognitionClientErrorNotSupport,
    /* error is unknown (may be passed with any ErrorStatusClass) */
    EVoiceRecognitionClientErrorUnknown,
    /*
     * Retry not supported with current parameters.
     * Make sure that recognition strategy is RECOGNITION_STRATEGY_ONLINE
     * and that retry support flag is enabled
     */
    EVoiceRecognitionClientErrorRetryNotSupport,
    /* Retry requested, but there was no audio data recorded */
    EVoiceRecognitionClientErrorRetryNoAudioData,
    
    // ============================ 以下状态为错误通知，出现错语后，会自动结束本次识别 =============================
    EVoiceRecognitionClientErrorStatusUnKnow = EVoiceRecognitionClientErrorStatusClassVDP+1,          // 未知错误(异常)
    EVoiceRecognitionClientErrorStatusNoSpeech,               // 用户未说话
    EVoiceRecognitionClientErrorStatusShort,                  // 用户说话声音太短
    EVoiceRecognitionClientErrorStatusException,              // 语音前端库检测异常
    
    
    EVoiceRecognitionClientErrorStatusChangeNotAvailable = EVoiceRecognitionClientErrorStatusClassRecord+1,     // 录音设备不可用
    EVoiceRecognitionClientErrorStatusIntrerruption,          // 录音中断
    
    
    EVoiceRecognitionClientErrorNetWorkStatusUnusable = EVoiceRecognitionClientErrorStatusClassLocalNet+1,            // 网络不可用
    EVoiceRecognitionClientErrorNetWorkStatusError,               // 网络发生错误
    EVoiceRecognitionClientErrorNetWorkStatusTimeOut,             // 网络本次请求超时
    EVoiceRecognitionClientErrorNetWorkStatusParseError,          // 解析失败
    
    
    //服务器返回错误
    EVoiceRecognitionClientErrorNetWorkStatusServerParamError = EVoiceRecognitionClientErrorStatusClassServerNet+1,       // 协议参数错误
    EVoiceRecognitionClientErrorNetWorkStatusServerRecognError,      // 识别过程出错
    EVoiceRecognitionClientErrorNetWorkStatusServerNoFindResult,     // 没有找到匹配结果
    EVoiceRecognitionClientErrorNetWorkStatusServerAppNameUnknownError,     // AppnameUnkown错误
    EVoiceRecognitionClientErrorNetWorkStatusServerSpeechQualityProblem,    // 声音不符合识别要求
    EVoiceRecognitionClientErrorNetWorkStatusServerSpeechTooLong,           // 语音过长
    EVoiceRecognitionClientErrorNetWorkStatusServerUnknownError,            // 未知错误
    EVoiceRecognitionClientErrorNetWorkStatusGetAccessTokenFailed,
    
    //离线识别错误
    EVoiceRecognitionClientErrorOfflineEngineGetLicenseFailed = EVoiceRecognitionClientErrorStatusClassOffline + 1, // 获取license失败
    EVoiceRecognitionClientErrorOfflineEngineVerifyLicenseFaild,            // 验证license失败
    EVoiceRecognitionClientErrorOfflineEngineDatFileNotExist,               // 指定的模型文件不存在
    EVoiceRecognitionClientErrorOfflineEngineSetSlotFailed,                 // 设置离线识别引擎槽失败
    EVoiceRecognitionClientErrorOfflineEngineInitializeFailed,              // 初始化失败
    EVoiceRecognitionClientErrorOfflineEngineSetParamFailed,                // 设置参数错误
    EVoiceRecognitionClientErrorOfflineEngineLMDataFileNotExist,            // 导航模型文件不存在
    EVoiceRecognitionClientErrorOfflineEngineSetPropertyFailed,             // 设置识别垂类失败
    EVoiceRecognitionClientErrorOfflineEngineFeedAudioDataFailed,           // 识别失败
    EVoiceRecognitionClientErrorOfflineEngineStopRecognitionFailed,         // 识别失败
    EVoiceRecognitionClientErrorOfflineEngineRecognizeFailed,               // 识别失败
}TVoiceRecognitionClientErrorStatus;

#endif
