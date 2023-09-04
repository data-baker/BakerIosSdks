//
//  NSString+DBCrypto.m
//  DBLogCollectKit
//
//  Created by biaobei on 2022/5/10.
//

#import "NSString+DBCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static NSString *sha256 =  @"15sMTZ4tzrGwf28NloSWCyEHUipnXhmgu9O37RDLa0ceIkP6qxVvFYAbBdJKQj";

@implementation NSString (DBCrypto)

- (NSString *)SHA256
{
    const char *s = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *outData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash = [outData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

+ (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSUTF8StringEncoding] ;
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    return HMAC;
}

+ (NSString *)sha256StringWithText:(NSString *)text {
    NSString *secretString = [self hmac:text withKey:sha256];
    return secretString;
}
// enmerator the dictionary by order https://stackoverflow.com/questions/17960068/with-fast-enumeration-and-an-nsdictionary-iterating-in-the-order-of-the-keys-is
+ (NSString *)sha256StringWithDictionary:(NSDictionary *)dictionary {
    NSMutableArray *allKeys = [[dictionary allKeys] mutableCopy];
    [allKeys sortUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    __block NSString *tempString = @"";
    [allKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        tempString = [tempString stringByAppendingFormat:@"%@_%@",obj,[dictionary objectForKey:obj]];
        if (idx != allKeys.count - 1) {
            tempString =[tempString stringByAppendingString:@"_"];
        }
    }];
    return tempString;
}

@end
