//
//  DBTransferModel.h
//  DBVoiceTransfer
//
//  Created by linxi on 2021/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBTransferModel : NSObject
/// 错误码，0 代表成功其他代表识别，参考错误码说明。
@property (nonatomic , assign) NSInteger              errcode;
///  错误信息描述
@property (nonatomic , copy) NSString               * errmsg;
/// 是否为最后一包，当时发送最后一包数据时设置为true 告诉调用方输出完成
@property (nonatomic , assign) NSInteger              lastpkg;
/// 会话唯一id，用于追踪定位问题。
@property (nonatomic , assign) NSInteger              traceid;

@end

NS_ASSUME_NONNULL_END
