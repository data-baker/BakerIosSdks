//
//  NSString+Util.m
//  DBAudioSDK
//
//  Created by 林喜 on 2023/8/22.
//

#import "NSString+Util.h"

@implementation NSString (Util)


- (BOOL)p_isEmpty {
    if (self.length == 0 || self == nil) {
        return YES;
    }
    return NO;
}


@end
