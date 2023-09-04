//
//  DBNetworkHelper.m
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import "DBFNetworkHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+DBCrypto.h"
#import "DBLogerConfigure.h"
#import "DBCommonConst.h"

#if DBRelease
#define DB_UploadUrlString  @"https://openapitest.data-baker.com/logapp/log/uploadLog"

#else // 测试环境
#define DB_UploadUrlString  @"https://openapitest.data-baker.com/logapp/log/uploadLog"
#endif



typedef void (^DBCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^DBSuccessBlock)(NSDictionary *data);
typedef void (^DBFailureBlock)(NSError *error);

static NSString *DBUploadBoundary = @"DBUploadBoundary";
#define DBEncode(string) [string dataUsingEncoding:NSUTF8StringEncoding]
#define DBEnter [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

@interface DBFNetworkHelper ()<NSURLSessionDelegate>
@end

@implementation DBFNetworkHelper

//GET请求
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessBlock)successBlock failure:(DBFailureBlock)failureBlock
{
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:url];
    if ([parameters allKeys]) {
        [mutableUrl appendString:@"?"];
        for (id key in parameters) {
            NSString *value = [[parameters objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
        }
    }
    NSString *urlEnCode = [[mutableUrl substringToIndex:mutableUrl.length - 1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    //TODO:设置超时
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        bb_dispatch_main_async_safe(^{
            if (error) {
                failureBlock(error);
            } else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic[@"error"]) {
                    NSError * netError = [NSError errorWithDomain:@"DBNetworkHelper" code:70001 userInfo:dic];
                    failureBlock(netError);
                    return;
                }
                successBlock(dic);
            }
        });
    }];
    [dataTask resume];
}

//POST请求 使用NSMutableURLRequest可以加入请求头
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessBlock)successBlock failure:(DBFailureBlock)failureBlock
{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    //设置请求类型
    request.HTTPMethod = @"POST";
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];//token
    NSMutableDictionary * headerDic = [[NSMutableDictionary alloc]init];
    NSString * unixTime = [self getUnixTime];
    NSString * nounce = [self getNounce];
    headerDic[@"timestamp"] = unixTime;
    headerDic[@"nounce"] = nounce;
    [request setValue:unixTime forHTTPHeaderField:@"timestamp"];
    [request setValue:nounce forHTTPHeaderField:@"nounce"];
    [request setValue:[self getSignature:headerDic] forHTTPHeaderField:@"signature"];
    //把参数放到请求体内
    NSString *postStr = [self dictionaryToJsonString:parameters];
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        bb_dispatch_main_async_safe(^{
            if (error) { //请求失败
                failureBlock(error);
            } else {  //请求成功
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic[@"error"]) {
                    NSError * netError = [NSError errorWithDomain:@"DBNetworkHelper" code:70001 userInfo:dic];
                    failureBlock(netError);
                    return;
                }
                successBlock(dic);
            }
        });
    }];
    [dataTask resume];  //开始请求
}

+ (NSString *)dictionaryToJsonString:(NSDictionary *)dic{
    BOOL isVaildJson =  [NSJSONSerialization isValidJSONObject:dic];
    if (!isVaildJson) {
        return @"";
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return @"";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)getUnixTime{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long long int currentTime = (long long int)time;
    NSString *unixTime = [NSString stringWithFormat:@"%llu", currentTime];
    return unixTime;
}

+ (NSString *)getNounce{
    int a = arc4random() % 100000;
    NSString *str = [NSString stringWithFormat:@"%06d", a];
    return str;
}

+(NSString *)getSignature:(NSMutableDictionary*) params{
    NSArray *keyArray = [params allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortArray) {
        [valueArray addObject:[params objectForKey:sortString]];
    }
    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [signArray addObject:keyValueStr];
    }
    NSString *sign = [signArray componentsJoinedByString:@"&"];
    sign = [NSString stringWithFormat:@"%@&",sign];
    sign = [self MD5ForLower32Bate:sign];
    if ([self isBlank:sign]) {
        NSString *occurrencesString = @"s";
        NSRange range = [sign rangeOfString:occurrencesString];
        sign = [sign stringByReplacingCharactersInRange:range withString:@"b"];
    }
    sign = [NSString stringWithFormat:@"%@%@",sign,params[@"nounce"]];
    sign = [self MD5ForLower32Bate:sign];
    return sign;
}

+(NSString *)getLoginSignature:(NSMutableDictionary*) params{
    NSArray *keyArray = [params allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortArray) {
        [valueArray addObject:[params objectForKey:sortString]];
    }
    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [signArray addObject:keyValueStr];
    }
    NSString *sign = [signArray componentsJoinedByString:@"&"];
    sign = [NSString stringWithFormat:@"%@&v1",sign];
    sign = [self MD5ForLower32Bate:sign];
    if ([self isBlank:sign]) {
        NSString *occurrencesString = @"s";
        NSRange range = [sign rangeOfString:occurrencesString];
        sign = [sign stringByReplacingCharactersInRange:range withString:@"b"];
    }
    sign = [NSString stringWithFormat:@"%@%@",sign,params[@"nounce"]];
    sign = [self MD5ForLower32Bate:sign];
    return sign;
}

#pragma mark - 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str {
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}
/**
 * 判断字符串是否包含空格
 */
+ (BOOL)isBlank:(NSString *)str {
    NSRange _range = [str rangeOfString:@"s"];
    if (_range.location != NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

+ (void)uploadLevel:(DBLogLevel)level userMsg:(NSString *)msg  {
    NSString *leveStr = [self levelStringWithLevel:level];
    NSString *content = [NSString stringWithFormat:@"%@:[%@]:{%@}",[DBCommonConst currentTimeString],leveStr,msg];
    NSString *time = [DBLogerConfigure sharedInstance].time;
    NSDictionary *parameters = [self getBodyInfoWithLevel:level content:content time:time];
    NSString *auths = [self getAuthStringWithWithLevel:level content:msg time:time];
    [self log_postWithAuth:auths witDictionary:parameters success:^(NSDictionary * _Nonnull data) {
        NSLog(@"data:%@",data);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error:%@",error.description);
    }];

}

+ (void)log_postWithAuth:(NSString *)auth witDictionary:(NSDictionary *)params success:(DBSuccessBlock)successBlock failure:(DBFailureBlock)failureBlock{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:DB_UploadUrlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //设置请求类型
    request.HTTPMethod = @"POST";
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];//token
    NSLog(@"auth:%@",auth);
    [request setValue:auth forHTTPHeaderField:@"authorization"];
    NSString *postStr = [self dictionaryToJsonString:params];
    NSLog(@"postStr:%@",postStr);
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        bb_dispatch_main_async_safe(^{
            if (error) { //请求失败
                failureBlock(error);
            } else {  //请求成功
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic[@"error"]) {
                    NSError * netError = [NSError errorWithDomain:@"DBNetworkHelper" code:70001 userInfo:dic];
                    failureBlock(netError);
                    return;
                }
                successBlock(dic);
            }
        });
    }];
    [dataTask resume];  //开始请求
}

+ (NSDictionary *)getBodyInfoWithLevel:(DBLogLevel)level content:(NSString *)content time:(NSString *)time{
    NSDictionary *configureDict = [self getConfigureDictionaryWithLevel:level content:content time:time];
    NSDictionary *baseDict = [self getBaseInfoDictionary];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:configureDict];
    [mutableDictionary setObject:baseDict forKey:@"baseInfo"];
    return mutableDictionary;
}

+ (NSString *)getAuthStringWithWithLevel:(DBLogLevel)level content:(NSString *)content time:(NSString *)time {
    NSDictionary *configureDict = [self getConfigureDictionaryWithLevel:level content:content time:time];
    NSDictionary *baseDict = [self getBaseInfoDictionary];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:configureDict];
    [mutableDictionary addEntriesFromDictionary:baseDict];
    [mutableDictionary removeObjectForKey:@"contentList"];
    NSString *appendString = [NSString sha256StringWithDictionary:mutableDictionary];
    NSLog(@"method log:%s ,%d appendString:%@",__func__,__LINE__,appendString);
    NSString *shaString = [NSString sha256StringWithText:appendString];
    return shaString;
}

+ (NSDictionary *)getConfigureDictionaryWithLevel:(DBLogLevel)level content:(NSString *)content time:(NSString *)time  {
    NSString *leveStr = [self levelStringWithLevel:level];
    DBLogerConfigure *loger = [DBLogerConfigure sharedInstance];
    NSDictionary *dict = @{
        @"level":leveStr,
        @"userid":loger.userId,
        @"businessType":loger.businessType,
        @"time":time,
        @"contentList":@[content],
    };
    return dict;
}

+ (NSString*)levelStringWithLevel:(DBLogLevel)level {
    NSDictionary *dict = @{
        @(DBLogLevelDebug):@"debug",
        @(DBLogLevelInfo):@"info",
        @(DBLogLevelWarning):@"warning",
        @(DBLogLevelError):@"error"
    };
    NSString *string = dict[@(level)];
    return string;
}

+ (NSDictionary *)getBaseInfoDictionary {
    DBLogerConfigure *loger = [DBLogerConfigure sharedInstance];
    NSDictionary *params = @{
        @"systemVersion":loger.systemVersion,
        @"appVersion":loger.appVersion,
        @"appName":loger.appName,
        @"language":loger.language,
        @"appSystemVersion":loger.appSystemVersion
    };
    return params;
}



@end
