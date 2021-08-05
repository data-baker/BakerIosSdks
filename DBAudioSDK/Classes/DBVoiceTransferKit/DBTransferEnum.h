//
//  DBTransferEnum.h
//  DBVoiceTransfer
//
//  Created by linxi on 2021/3/22.
//

#ifndef DBTransferEnum_h
#define DBTransferEnum_h


typedef NS_ENUM(NSUInteger,DBErrorState) {
    
    DBErrorStateFileReadFailed = 19110001, // 文件读取失败
    DBErrorStateParsing = 19110002, // 网络数据解析失败
    DBErrorStateFailedSocketConnect = 19110003, // 网络连接失败
    DBErrorStateMicrophoneNoGranted = 19110003, // 没有麦克风权限


};
#endif /* DBTransferEnum_h */
