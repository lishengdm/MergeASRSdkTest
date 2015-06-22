//
//  BDVoiceRecognitionClient.h
//  BDVoiceRecognitionClient
//
//  Created by liujunqi on 12-4-1.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BDVRProperties.h"
#import "BDVRErrorCodes.h"


// 枚举 - 播放录音提示音
enum TVoiceRecognitionPlayTones
{
    EVoiceRecognitionPlayTonesRecStart = 1,                 // 录音开始提示音
    EVoiceRecognitionPlayTonesRecEnd = 2,                   // 录音结束提示音
    //所有日志打开
    EVoiceRecognitionPlayTonesAll = (EVoiceRecognitionPlayTonesRecStart | EVoiceRecognitionPlayTonesRecEnd )
};

// 枚举 - 调用启动语音识别，返回结果（startVoiceRecognition）
typedef enum TVoiceRecognitionStartWorkResult
{
    EVoiceRecognitionStartWorking = 2000,                    // 开始工作
    EVoiceRecognitionStartWorkNOMicrophonePermission,        // 没有麦克风权限
    EVoiceRecognitionStartWorkNoAPIKEY,                      // 没有设定应用API KEY
    //EVoiceRecognitionStartWorkGetAccessTokenFailed,          // 获取accessToken失败 (relocated EVoiceRecognitionClientErrorNetWorkStatusGetAccessTokenFailed)
    EVoiceRecognitionStartWorkNetUnusable,                   // 当前网络不可用
    EVoiceRecognitionStartWorkDelegateInvaild,               // 没有实现MVoiceRecognitionClientDelegate中VoiceRecognitionClientWorkStatus方法,或传入的对像为空
    EVoiceRecognitionStartWorkRecorderUnusable,              // 录音设备不可用
    EVoiceRecognitionStartWorkPreModelError,                 // 启动预处理模块出错
    EVoiceRecognitionStartWorkPropertyInvalid,               // 设置的识别属性无效
    EVoiceRecognitionStartWorkOfflineEngineNotInit,          // 离线引擎没有初始化
    EVoiceRecognitionStartWorkOfflineEngineNotSupport,       // 离线不支持的垂类识别
}TVoiceRecognitionStartWorkResult;

// 枚举 - 语音识别状态
typedef enum TVoiceRecognitionClientWorkStatus
{
    EVoiceRecognitionClientWorkStatusNone = 0,               // 空闲
    EVoiceRecognitionClientWorkPlayStartTone,                // 播放开始提示音
    EVoiceRecognitionClientWorkPlayStartToneFinish,          // 播放开始提示音完成
    EVoiceRecognitionClientWorkStatusStartWorkIng,           // 识别工作开始，开始采集及处理数据
    EVoiceRecognitionClientWorkStatusStart,                  // 检测到用户开始说话
    //EVoiceRecognitionClientWorkStatusSentenceEnd,            // 输入模式下检测到语音说话完成
    EVoiceRecognitionClientWorkStatusEnd,                    // 本地声音采集结束结束，等待识别结果返回并结束录音
    EVoiceRecognitionClientWorkPlayEndTone,                  // 播放结束提示音
    EVoiceRecognitionClientWorkPlayEndToneFinish,            // 播放结束提示音完成
    
    EVoiceRecognitionClientWorkStatusNewRecordData,          // 录音数据回调
    EVoiceRecognitionClientWorkStatusFlushData,              // 连续上屏
    //EVoiceRecognitionClientWorkStatusReceiveData,            // 输入模式下有识别结果返回
    EVoiceRecognitionClientWorkStatusFinish,                 // 语音识别功能完成，服务器返回正确结果
    
    EVoiceRecognitionClientWorkStatusCancel,                 // 用户取消
    EVoiceRecognitionClientWorkStatusError                   // 发生错误，详情见VoiceRecognitionClientErrorStatus接口通知
}TVoiceRecognitionClientWorkStatus;

// 枚举 - 网络工作状态
typedef enum TVoiceRecognitionClientNetWorkStatus
{
    EVoiceRecognitionClientNetWorkStatusStart = 1000,        // 网络开始工作
    EVoiceRecognitionClientNetWorkStatusEnd,                 // 网络工作完成
}TVoiceRecognitionClientNetWorkStatus;

// 枚举 - 设定采样率
typedef enum TVoiceRecognitionRecordSampleRateFlags
{
    EVoiceRecognitionRecordSampleRateAuto = 0,        //日志文件
    EVoiceRecognitionRecordSampleRate8K,              //录音原文件
    EVoiceRecognitionRecordSampleRate16K,             //本地处理后的录音文件
    
}TVoiceRecognitionRecordSampleRateFlags;

// @protocol - MVoiceRecognitionClientDelegate
// @brief - 语音识别工作状态通知
@protocol MVoiceRecognitionClientDelegate<NSObject>
@optional

- (void)VoiceRecognitionClientWorkStatus:(int) aStatus obj:(id)aObj;              //aStatus TVoiceRecognitionClientWorkStatus


- (void)VoiceRecognitionClientErrorStatus:(int) aStatus subStatus:(int)aSubStatus;//aStatus TVoiceRecognitionClientErrorStatusClass;aSubStatus TVoiceRecognitionClientErrorStatus


- (void)VoiceRecognitionClientNetWorkStatus:(int) aStatus;                        //aStatus TVoiceRecognitionClientNetWorkStatus

@end // MVoiceRecognitionClientDelegate

@interface BDVoiceRecognitionClient : NSObject
//－－－－－－－－－－－－－－－－－－－类方法－－－－－－－－－－－－－－－－－－－－－－－－
// 创建语音识别客户对像，该对像是个单例
+ (BDVoiceRecognitionClient *)sharedInstance;

// 释放语音识别客户端对像
+ (void)releaseInstance;


//－－－－－－－－－－－－－－－－－－－识别方法－－－－－－－－－－－－－－－－－－－－－－－
// 判断是否可以录音
- (BOOL)isCanRecorder;

// 开始语音识别，需要实现MVoiceRecognitionClientDelegate代理方法，并传入实现对像监听事件
// 返回值参考 TVoiceRecognitionStartWorkResult
- (TVoiceRecognitionStartWorkResult)startVoiceRecognition:(id<MVoiceRecognitionClientDelegate>)aDelegate;

// Check if voice recognition can be retried with previously recorded data
- (BOOL)isRetryAvailable;

// Retry voice recognition with previously recorded data
// if aDelegate is nil, previously used delegate will be used
- (TVoiceRecognitionStartWorkResult)retryVoiceRecognition:(id<MVoiceRecognitionClientDelegate>)aDelegate;

// 说完了，用户主动完成录音时调用
- (void)speakFinish;

// 结束本次语音识别
- (void)stopVoiceRecognition;

/**
 * @brief 获取当前识别的采样率
 *
 * @return 采样率(16000/8000)
 */
- (int)getCurrentSampleRate;

// 设置识别类型列表, 除EVoiceRecognitionPropertyInput和EVoiceRecognitionPropertySong外
// 可以识别类型复合
- (void)setPropertyList: (NSArray*)prop_list;

// cityID仅对EVoiceRecognitionPropertyMap识别类型有效
- (void)setCityID: (NSInteger)cityID;

// 获取当前识别类型列表
- (NSArray*)getRecognitionPropertyList;

//－－－－－－－－－－－－－－－－－－－提示音－－－－－－－－－－－－－－－－－－－－－－－
// 播放提示音，默认为播放,录音开始，录音结束提示音
// BDVoiceRecognitionClientResources/Tone
// record_start.caf   录音开始声音文件
// record_end.caf     录音结束声音文件
// 声音资源需要加到项目工程里，用户可替换资源文件，文件名不可以变，建音提示音不宜过长，0。5秒左右。
// aTone 取值参考 TVoiceRecognitionPlayTones，如没有找到文件，则返回ＮＯ
- (BOOL)setPlayTone:(int)aTone isPlay:(BOOL)aIsPlay;


//－－－－－－－－－－－－－－－－－－－音源信息－－－－－－－－－－－－－－－－－－－－－－－
// 监听当前音量级别，如果在工作状态设定，返回结果为ＮＯ ，且本次调用无效
- (BOOL)listenCurrentDBLevelMeter;

// 获取当前音量级别，取值需要考虑全平台
- (int)getCurrentDBLevelMeter;

// 取消监听音量级别
- (void)cancelListenCurrentDBLevelMeter;


//－－－－－－－－－－－－－－－－－－－产品相关－－－－－－－－－－－－－－－－－－－－－－－
// 如果与百度语音技术部有直接合作关系，才需要考虑此方法，否则请使用setApiKey:withSecretKey:方法
- (void)setProductId:(NSString *)aProductId;

// 如果与百度语音技术部有直接合作关系，才需要考虑此方法，否则请勿随意设置服务器地址
// 根据识别类型选择mode，EVoiceRecognitionPropertyInput请传入EVoiceRecognitionPropertyInput
// 其余传入EVoiceRecognitionPropertySearch即可
// 从下一次识别开始生效
- (void)setServerURL:(NSString *)url withMode:(int)mode;

//- - - - - - - - - - - - - - - -功能设置- - - - - - - - - - - - - - - - - - - -
// 定制功能
// 定制语义解析功能请传入key=BDVR_CONFIG_KEY_NEED_NLU，如果开启此功能，将返回带语义的json串，含义详见开发文档说明
#define BDVR_CONFIG_KEY_NEED_NLU @"nlu"
// 定制通讯录识别功能请传入key=BDVR_CONFIG_KEY_ENABLE_CONTACTS，如果开启此功能，将优先返回通讯录识别结果
#define BDVR_CONFIG_KEY_ENABLE_CONTACTS @"enable_contacts"
// 定制SDK是否对AudioSession进行操作，如果外部需要操作AudioSession，应当通过此接口禁止SDK对AudioSession进行操作
#define BDVR_CONFIG_KEY_DISABLE_AUDIO_SESSION_CONTROL @"disable_audio_session_control"
/**
 * If enabled, SDK will keep recorded data and in case of error you may retry recognition with recorded data
 * by returning EVoiceRecognitionErrorActionRetry from VoiceRecognitionClientErrorStatus callback
 */
#define BDVR_CONFIG_KEY_ENABLE_VR_RETRY_SUPPORT @"enable_voice_recognition_retry_support"
- (void)setConfig:(NSString *)key withFlag:(BOOL)flag;

// 设置识别语言，有效值参见枚举类型TVoiceRecognitionLanguage
- (void)setLanguage:(int)language;

//－－－－－－－－－－－－－－－－－－－开发者身份验证－－－－－－－－－－－－－－－－－－－－
// 设置开发者申请的api key和secret key
- (void)setApiKey:(NSString *)apiKey withSecretKey:(NSString *)secretKey;

//－－－－－－－－－－－－－－－－－－－浏览器标识设置－－－－－－－－－－－－－－－－－－－－
// 设置浏览器标识，资源返回时会根据UA适配
// userAgent参数可通过[UIWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]获取
- (void)setBrowserUa:(NSString *)userAgent;

//－－－－－－－－－－－－－－－－－－－更新地理位置信息－－－－－－－－－－－－－－－－－－－－
// 更新当前地理位置信息，与地理位置相关的资源会优先返回附近资源信息
// 请传入通过GPS获取到的经纬度数据
- (void)updateLocation:(CLLocation *)location;

//- - - - - - - - - - - - - - - -其他参数设置- - - - - - - - - - - - - - - - - -
// 设置params，每次识别开始前都需要进行设置，目前支持如下参数：
#define BDVR_PARAM_KEY_TEXT @"txt" // 上传文本，如果设置了该字段，将略过语音输入和识别阶段
#define BDVR_PARAM_KEY_OTHER_PARAM @"pam" // 其他参数
#define BDVR_PARAM_KEY_STATISTICS @"stc" // 统计信息
#define BDVR_PARAM_KEY_LIGHT_APP_UID @"ltp" // 轻应用参数(uid)
#define BDVR_PARAM_KEY_USER_AGENT @"user-agent" // UA
- (void)setParamForKey:(NSString *)key withValue:(NSString *)value;

// 关闭标点
- (void)disablePuncs:(BOOL)flag;

- (void)setResourceType:(TBDVoiceRecognitionResourceType)resourceType;
- (TBDVoiceRecognitionResourceType)getResourceType;

// 设置是否需要对录音数据进行端点检测
- (void)setNeedVadFlag: (BOOL)flag;

// 设置是否需要对录音数据进行压缩
- (void)setNeedCompressFlag: (BOOL)flag;

/**
 * @brief 设置识别策略
 *
 * @param strategy 识别策略
 *
 * @return void
 */
- (void)setRecognitionStrategy: (TBDVoiceRecognitionStrategy)strategy;

/**
 * @brief 加载离线识别引擎
 *
 * @param appCode 用户获取的appCode
 * @param licenseFile 用户授权文件路径
 * @param datFilePath 识别模型文件路径
 * @param LMDatFilePath 导航使用的识别模型文件，没有可以设置为nil
 * @param dictSlot 垂类识别时，设置语法槽
 *
 * @return 成功返回0，失败返回TVoiceRecognitionClientErrorStatus错误码
 */
- (int)loadOfflineEngine: (NSString*)appCode
                 license: (NSString*)licenseFile
                 datFile: (NSString*)datFilePath
               LMDatFile: (NSString*)LMDatFilePath
               grammSlot: (NSDictionary*)dictSlot;

/**
 * @brief 设置在线识别时等待超时时间，等待超时后，将同步启用离线识别
 *
 * @param time 等待服务器反馈时间
 *
 */
- (void)setOnlineWaitTime:(NSTimeInterval)time;

/**
 * @brief 是否正在进行离线识别
 *
 */
- (BOOL)isOfflineRecognition;
//－－－－－－－－－－－－－－－－－－－版本号－－－－－－－－－－－－－－－－－－－－－－－－
// 获取版本号
- (NSString*)libVer;

@end
