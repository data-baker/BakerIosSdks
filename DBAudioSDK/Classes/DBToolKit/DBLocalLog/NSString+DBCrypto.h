//
//  NSString+DBCrypto.h
//  DBLogCollectKit
//
//  Created by biaobei on 2022/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (DBCrypto)

/// sha256 add secret to encrypto
+ (NSString *)sha256StringWithText:(NSString *)text;

/// 按照后台的要求进行shaString 的拼接
+ (NSString *)sha256StringWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
