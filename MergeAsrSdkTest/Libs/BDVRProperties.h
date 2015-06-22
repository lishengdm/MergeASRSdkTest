//
//  BDVRProperties.h
//  VoiceRecognitionEngine
//
//  Created by lappi on 4/24/15.
//  Copyright (c) 2015 baidu. All rights reserved.
//

#ifndef VoiceRecognitionEngine_BDVRProperties_h
#define VoiceRecognitionEngine_BDVRProperties_h

// 枚举 - 语音识别类型
typedef enum TBDVoiceRecognitionProperty
{
    EVoiceRecognitionPropertyMusic = 10001, // 音乐
    EVoiceRecognitionPropertyVideo = 10002, // 视频
    EVoiceRecognitionPropertyApp = 10003, // 应用
    EVoiceRecognitionPropertyWeb = 10004, // web
    EVoiceRecognitionPropertySearch = 10005, // 热词
    EVoiceRecognitionPropertyEShopping = 10006, // 电商&购物
    EVoiceRecognitionPropertyHealth = 10007, // 健康&母婴
    EVoiceRecognitionPropertyCall = 10008, // 打电话
    EVoiceRecognitionPropertySong = 10009, // 录歌识别
    EVoiceRecognitionPropertyMedicalCare = 10052, // 医疗
    EVoiceRecognitionPropertyCar = 10053, // 汽车
    EVoiceRecognitionPropertyCatering = 10054, // 娱乐餐饮
    EVoiceRecognitionPropertyFinanceAndEconomics = 10055, // 财经
    EVoiceRecognitionPropertyGame = 10056, // 游戏
    EVoiceRecognitionPropertyCookbook = 10057, // 菜谱
    EVoiceRecognitionPropertyAssistant = 10058, // 助手
    EVoiceRecognitionPropertyRecharge = 10059, // 话费充值
    EVoiceRecognitionPropertyMap = 10060,  // 地图
    EVoiceRecognitionPropertyInput = 20000, // 输入
    // 离线垂类
    EVoiceRecognitionPropertyContacts = 100014, // 联系人指令
    EVoiceRecognitionPropertySetting = 100016, // 手机设置
    EVoiceRecognitionPropertyTVInstruction = 100018, // 电视指令
    EVoiceRecognitionPropertyPlayerInstruction = 100019, // 播放器指令
    EVoiceRecognitionPropertyRadio = 100020, // 收音机
} TBDVoiceRecognitionProperty;


typedef enum TBDVoiceRecognitionStrategy
{
    RECOGNITION_STRATEGY_ONLINE = 0,        // 在线识别
    RECOGNITION_STRATEGY_OFFLINE,           // 离线识别
    RECOGNITION_STRATEGY_ONLINE_PRI,        // 在线优先
    RECOGNITION_STRATEGY_OFFLINE_PRI,       // 离线优先
}TBDVoiceRecognitionStrategy;

// 枚举 - 设置识别语言
typedef enum TBDVoiceRecognitionLanguage
{
    EVoiceRecognitionLanguageChinese = 0,
    EVoiceRecognitionLanguageCantonese,
    EVoiceRecognitionLanguageEnglish,
    EVoiceRecognitionLanguageSichuanDialect,
}TBDVoiceRecognitionLanguage;

// 枚举 - 语音识别请求资源类型
typedef enum TBDVoiceRecognitionResourceType
{
    RESOURCE_TYPE_DEFAULT = -1,
    RESOURCE_TYPE_NONE = 0,     // 纯语音识别结果
    RESOURCE_TYPE_NLU = 1,      // 语义解析结果
    RESOURCE_TYPE_WISE = 2,     // wise结果
    RESOURCE_TYPE_WISE_NLU = 3, // 语义和wise结果
    RESOURCE_TYPE_POST = 4,     // 后处理结果
    RESOURCE_TYPE_AUDIO_DA = 8, // audio_da
} TBDVoiceRecognitionResourceType;

#endif
