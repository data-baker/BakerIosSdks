//
//  DBNetworkHelper.m
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import "DBEngraverNetworkHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "DBVoiceEngraverEnumerte.h"

static NSString *DBUploadBoundary = @"DBUploadBoundary";
#define DBEncode(string) [string dataUsingEncoding:NSUTF8StringEncoding]
#define DBEnter [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

@interface DBEngraverNetworkHelper ()<NSURLSessionTaskDelegate,NSURLSessionDelegate>

@end

@implementation DBEngraverNetworkHelper


//GET请求
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock
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
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode]];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failureBlock(error);
            } else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                successBlock(dic);
                
            }
        });
    }];
    [dataTask resume];
}

//POST请求 使用NSMutableURLRequest可以加入请求头
- (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock
{
    NSAssert(successBlock, @"请设置successBlock");
    NSAssert(failureBlock, @"请设置failureBlock");

    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    //如果想要设置网络超时的时间的话，可以使用下面的方法：    
    //设置请求类型
    request.HTTPMethod = @"POST";
    NSMutableDictionary * headerDic = [[NSMutableDictionary alloc]init];
    NSString * unixTime = [self getUnixTime];
    NSString * nounce = [self getNounce];
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:self.token forHTTPHeaderField:@"token"];//token
    [request setValue:self.clientId forHTTPHeaderField:@"clientId"];//坐标
    [request setValue:nounce forHTTPHeaderField:@"nounce"];//坐标 l
    [request setValue:unixTime forHTTPHeaderField:@"timestamp"];
    headerDic[@"timestamp"] = unixTime;
    headerDic[@"nounce"] = nounce;
    headerDic[@"token"] = self.token;
    headerDic[@"clientId"] = self.clientId;
    [request setValue:[self getSignature:headerDic] forHTTPHeaderField:@"signature"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //把参数放到请求体内
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [mutableDictionary addEntriesFromDictionary:parameters];
    mutableDictionary[@"language"] = @"zh_CN";
    NSString *postStr = [self dictionaryToJson:mutableDictionary];
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) { //请求失败
                failureBlock(error);
            } else {  //请求成功
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSInteger errorCode = [dic[@"code"] integerValue];
                
                if (errorCode != 20000) {
                    if (errorCode == 00011 || errorCode == 11) {
                        static NSInteger retry = 3;
                        if (retry < 0) {
                            NSError *error = [NSError errorWithDomain:DBErrorDomain code:[dic[@"code"] integerValue] userInfo:@{@"message":dic[@"message"]}];
                            failureBlock(error);
                            return;
                        }
                        [self.delegate updateTokenSuccessHandler:^(NSDictionary * _Nonnull dict) {
                            [self postWithUrlString:url parameters:parameters success:successBlock failure:failureBlock];
                        } failureHander:failureBlock];
                        retry--;
                        return;
                    }
                    NSError *error = [NSError errorWithDomain:DBErrorDomain code:[dic[@"code"] integerValue] userInfo:@{@"message":dic[@"message"]}];
                    failureBlock(error);
                }
                else {
                    successBlock(dic);
                }
                
            }
        });
    }];
    [dataTask resume];  //开始请求
}



//重新封装参数 加入app相关信息
+ (NSString *)parseParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:params];
    [parameters setValue:@"zh_CN" forKey:@"language"];
    NSLog(@"请求参数:%@",parameters);
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    //实例化一个key枚举器用来存放dictionary的key
   
   //加密处理 将所有参数加密后结果当做参数传递
   //parameters = @{@"i":@"加密结果 抽空加入"};
   
    NSEnumerator *keyEnum = [parameters keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@", key,[params valueForKey:key]];
        [result appendString:keyValueFormat];
    }
    return result;
}

- (void)uploadWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock {
    
    NSString *path = parameters[@"path"];
    NSString *name = parameters[@"name"];
    NSParameterAssert(path);
    NSParameterAssert(name);
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 60;
    
    // 校验签名
    NSMutableDictionary * headerDic = [[NSMutableDictionary alloc]init];
    NSString * unixTime = [self getUnixTime];
    NSString * nounce = [self getNounce];
    //将需要的信息放入请求头 随便定义了几个
    [request setValue:self.token forHTTPHeaderField:@"token"];//token
    [request setValue:self.clientId forHTTPHeaderField:@"clientId"];//坐标
    [request setValue:nounce forHTTPHeaderField:@"nounce"];//坐标 l
    [request setValue:unixTime forHTTPHeaderField:@"timestamp"];
    headerDic[@"timestamp"] = unixTime;
    headerDic[@"nounce"] = nounce;
    headerDic[@"token"] = self.token;
    headerDic[@"clientId"] = self.clientId;
    [request setValue:[self getSignature:headerDic] forHTTPHeaderField:@"signature"];
    
//    // 设置boundary,ContentType
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",DBUploadBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // 设置请求数据l内容
    request.HTTPMethod = @"POST";
    NSString *sessionId = parameters[@"sessionId"];
    NSString *originText = parameters[@"originText"];
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    mutableDict[@"sessionId"] = sessionId;
    mutableDict[@"originText"] = originText;
    // 获取请求数据的长度
    NSData *data = [self getDataWithPath:path params:mutableDict];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //6、获取上传的数据
    NSData *uploadData = data;
    //7、创建上传任务 上传的数据来自getData方法
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:uploadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failureBlock(error);
            }else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"code"] integerValue] != 20000) { 
                    NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateNetworkDataError userInfo:dic];
                    failureBlock(error);
                }else {
                    successBlock(dic);
                }
                
            }
        });
    }];
    [task resume];
}

-(NSData *)getDataWithPath:(NSString *)path params:(NSDictionary *)params
{
    
    NSMutableData *data = [NSMutableData data];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 拼接普通参数的上传格式.
            // 1. 普通参数上边界
            NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",DBUploadBoundary];
            // 服务器接收参数的key值.
            [headerStrM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            
            // 将普通参数上边界添加到请求体中
            [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
            
            // 2. 普通参数内容
            NSString * objValue = [NSString stringWithFormat:@"%@",obj];
            NSData *parameterData = [objValue dataUsingEncoding:NSUTF8StringEncoding];
            
            // 将普通参数内容添加到请求体中
            [data appendData:parameterData];
        }];
    [data appendData:DBEnter];
    [data appendData:DBEncode(@"--")];
    [data appendData:DBEncode(DBUploadBoundary)];
    [data appendData:DBEnter];
    [data appendData:DBEncode(@"Content-Disposition: form-data; name=\"file\"; filename=\"record.wav\"")];
    
    [data appendData:DBEnter];
    
    [data appendData:DBEncode(@"Content-Type: audio/wav")];
    [data appendData:DBEnter];
    
    [data appendData:DBEnter];

    NSData *wavData = [NSData dataWithContentsOfFile:path];
    [data appendData:wavData];
    
    [data appendData:DBEnter];
        
    [data appendData:DBEncode(@"--")];
    [data appendData:DBEncode(DBUploadBoundary)];
    [data appendData:DBEncode(@"--")];
    [data appendData:DBEnter];
    
    return data;
}


// MARK: Private Methods
- (NSString *)getNounce {
    int a = arc4random() % 100000;
    NSString *str = [NSString stringWithFormat:@"%06d", a];
    return str;
}

- (NSString *)getUnixTime {
    
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long long int currentTime = (long long int)time;
    NSString *unixTime = [NSString stringWithFormat:@"%llu", currentTime];
    return unixTime;
    
}
- (NSString *)getSignature:(NSMutableDictionary*) params{
    
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
    sign = [NSString stringWithFormat:@"%@&v2",sign];
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
- (BOOL)isBlank:(NSString *)str{
    NSRange _range = [str rangeOfString:@"s"];
    if (_range.location != NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

-(NSString *)MD5ForLower32Bate:(NSString *)str{
    
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


// MARK: 设置代理的回调 -- DBParamsDelegate

- (NSDictionary *)paramasDelegateRequestParamas {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"token"] = self.token;
    dict[@"clientId"] = self.clientId;
    NSString * unixTime = [self getUnixTime];
    NSString * nounce = [self getNounce];
    dict[@"timestamp"] = unixTime;
    dict[@"nounce"] = nounce;
    dict[@"signature"] = [self getSignature:dict];
    return dict;
    
}

- (void)logMessage:(NSString *)format, ... {
    if (self.enableLog) {
        // 1. 首先创建多参数列表
        va_list args;
            // 2. 开始初始化参数, start会从format中 依次提取参数, 类似于类结构体中的偏移量 offset 的 方式
        va_start(args, format);
        NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        NSLog(@"%@",str);
    }
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}

- (NSString *)makeFile {
    
    NSString *docPath= NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *PCMPath = [docPath stringByAppendingPathComponent:@"PCM"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:PCMPath]) {
        [manager removeItemAtPath:PCMPath error:nil];
    }
    BOOL isSuccess = [manager createDirectoryAtPath:PCMPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if (isSuccess) {
        NSLog(@"文件夹创建成功");
    }else {
        PCMPath = @"";
        NSLog(@"文件夹创建失败");
    }
    return PCMPath;
}

- (BOOL)clearAudioFile {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *pcmPath = [cachePath stringByAppendingPathComponent:@"PCM"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:pcmPath]) {
        NSError *error;
        BOOL ret = [manager removeItemAtPath:pcmPath error:&error];
        if (error) {
            [self logMessage:@"%@", error.description];
        }
        return ret;
    }
    return YES;
    
}

- (BOOL)removeFileWithFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"error%@",error);
            return NO;
        }
    }
    return YES;
}
@end
