//
//  DBVPResponseModel.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 声纹注册的base Model
@interface DBVPResponseModel : NSObject

/// SUCCESS 表示调用成功
@property(nonatomic,copy)NSString * err_msg;

/// 90000 表示调用成功
@property(nonatomic,copy)NSNumber * err_no;

/// 日子跟踪Id
@property(nonatomic,copy)NSString * log_id;

/// 声纹特征id
@property(nonatomic,copy)NSString * registerid;


+ (instancetype)responseModelWithError:(NSError *)error;

@end


/// 声纹注册的验证
@interface DBRegisterVPResponseModel :DBVPResponseModel

/// 注册成功次数，为3时表示完成注册
@property(nonatomic,assign)NSInteger  suc_num;

@end

/// 声纹1:1 的验证
@interface DBMatchOneVPResponseModel : DBVPResponseModel
/// 1 表示比对成功，0 表示比对失败
@property(nonatomic,assign)NSInteger matchStatus;

/// 比对分数
@property(nonatomic,copy)NSString * score;

@end

/// 声纹1:N的验证
@interface DBMatchMoreVPResponseModel : DBVPResponseModel

/// 匹配到的声纹特征 id
@property(nonatomic,assign)NSInteger spkid;

/// 比对分数
@property(nonatomic,copy)NSString * score;

/// 声纹关联的名字
@property(nonatomic,copy)NSString * name;


@end

/// 查询声纹状态码
@interface DBVPStatusResponnseModel : DBVPResponseModel

/// 声纹注册次数，3：注册成功，0：未注册
@property(nonatomic,copy)NSString * status;

@end



NS_ASSUME_NONNULL_END
