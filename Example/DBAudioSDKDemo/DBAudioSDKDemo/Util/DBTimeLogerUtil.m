//
//  DBTimeLogerUtil.m
//  DBEvaluateDemo
//  Created by 林喜 on 2022/12/30.
//

#import "DBTimeLogerUtil.h"

typedef NS_ENUM(NSUInteger,LogType) {
    LogTypeTTS = 1, // 合成
    LogTypeASR    , // 识别
};

@interface DBTimeLogerUtil ()
@property(nonatomic,copy)NSString * vendorName;
@property(nonatomic,assign)CFAbsoluteTime startTime;
@property(nonatomic,assign)NSInteger packageIndex;
@property(nonatomic,copy)NSString * synthesisText;
@property(nonatomic,assign)CFAbsoluteTime connectTime;
@property(nonatomic,assign)CFAbsoluteTime firstPime;
@property(nonatomic,assign)LogType logerType;

/// asr识别到的文本
@property(nonatomic,copy)NSString * asrText;

@end

@implementation DBTimeLogerUtil

+ (instancetype)shareInstance {
    static DBTimeLogerUtil *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[DBTimeLogerUtil alloc]init];
        [util resetPageIndex];
    });
    return util;
}

- (void)resetPageIndex {
    self.packageIndex = 1;
}
// MARK: Public Method
- (void)logerASRStartTimeWithVendor:(NSString *)vendor {
    self.vendorName = vendor;
    self.logerType = LogTypeASR;
    [self setLogerStart];
}

- (CFTimeInterval)getAsrTotalTime {
    return CFAbsoluteTimeGetCurrent() - self.startTime;
}

- (void)setLogerStart {
    self.logFlag = NO;
    self.startTime = CFAbsoluteTimeGetCurrent();
}

- (void)logerStartTimeWithSynthesisText:(NSString *)text {
    self.synthesisText = text;
    self.logerType = LogTypeTTS;
    [self setLogerStart];
}


- (void)logerConnectTime {
    self.connectTime = CFAbsoluteTimeGetCurrent() - self.startTime;
}

- (void)logerAsRText:(NSString *)text {
    self.asrText = text;
}

- (void)logerPackageTime {
    self.logFlag = YES;
    self.firstPime = CFAbsoluteTimeGetCurrent() - self.startTime;
    [self logerCurrentSynthessis];
    self.packageIndex ++;
}



- (void)logerCurrentSynthessis {
    
    NSString *typeInfo = @"首包";
    NSString *text = @"";
    switch (self.logerType) {
        case LogTypeTTS:
            typeInfo = @"首包";
            text = self.synthesisText;
            break;
        case LogTypeASR:
            typeInfo = @"尾包";
            text = self.asrText;
            break;
    }
    
    NSString *synInfo = [NSString stringWithFormat:@"%@-第%2ld包-连接时间:%f-%@返回时间:%f-文本:%@",self.vendorName,(long)self.packageIndex,self.connectTime*1000,typeInfo,self.firstPime*1000,text];
    NSLog(@"%@",synInfo);
}

// 转化工具
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)logTransferStart {
    
}





@end
