//
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "DBZError.h"

#import "DBZWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

NSError *DBZErrorWithDomainCodeDescription(NSString *domain, NSInteger code, NSString *description)
{
    return [NSError errorWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}

NSError *DBZErrorWithCodeDescription(NSInteger code, NSString *description)
{
    return DBZErrorWithDomainCodeDescription(DBZWebSocketErrorDomain, code, description);
}

NSError *DBZErrorWithCodeDescriptionUnderlyingError(NSInteger code, NSString *description, NSError *underlyingError)
{
    return [NSError errorWithDomain:DBZWebSocketErrorDomain
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: description,
                                       NSUnderlyingErrorKey: underlyingError }];
}

NSError *SRHTTPErrorWithCodeDescription(NSInteger httpCode, NSInteger errorCode, NSString *description)
{
    return [NSError errorWithDomain:DBZWebSocketErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: description,
                                       DBZHTTPResponseErrorKey: @(httpCode) }];
}

NS_ASSUME_NONNULL_END
