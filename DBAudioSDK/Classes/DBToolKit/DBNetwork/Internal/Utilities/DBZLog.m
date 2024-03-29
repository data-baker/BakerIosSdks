//
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "DBZLog.h"
#import "DBLogCollectKit.h"

NS_ASSUME_NONNULL_BEGIN

extern void DBZErrorLog(NSString *format, ...)
{
    __block va_list arg_list;
    va_start (arg_list, format);

    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];

    va_end(arg_list);

    LogerInfo(@"[SocketRocket] %@", formattedString);
}

extern void DBZDebugLog(NSString *format, ...)
{
#ifdef DBZ_DEBUG_LOG_ENABLED
//    DBZErrorLog(@"%@",format);
    __block va_list arg_list;
    va_start (arg_list, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    LogerInfo(@"[SocketRocket] %@", formattedString);
    
#endif
}

NS_ASSUME_NONNULL_END
