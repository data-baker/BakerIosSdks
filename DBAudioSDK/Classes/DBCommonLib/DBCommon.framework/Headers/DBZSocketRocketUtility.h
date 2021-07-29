//
//  DBZSocketRocketUtility.h
//  SUN
//
//  Created by linxi on 19/11/6.
//  Copyright © 标贝. All rights reserved.
//

#import <Foundation/Foundation.h>

#if OBJC_BOOL_IS_BOOL

struct DBSocketDelegateAvailableMethods {
    BOOL webSocketDidOpenNote : 1;
    BOOL webSocketDidCloseNote : 1;
    BOOL webSocketdidReceiveMessageNote : 1;
    BOOL webSocketdidConnectFailed : 1;
};

#else

struct DBSocketDelegateAvailableMethods {
    BOOL webSocketDidOpenNote;
    BOOL webSocketDidCloseNote;
    BOOL webSocketdidReceiveMessageNote;
    BOOL webSocketdidConnectFailed;
};
#endif


@protocol DBZSocketCallBcakDelegate <NSObject>


// socket打开了，建立了连接
- (void)webSocketDidOpenNote;

// socket关闭了
- (void)webSocketDidCloseNote:(id)object;

// socket,收到了消息
- (void)webSocketdidReceiveMessageNote:(id)object;

// socket连接失败
- (void)webSocketdidConnectFailed:(id)object;


@end

typedef struct DBSocketDelegateAvailableMethods DBSocketDelegateAvailableMethods;

@interface DBZSocketRocketUtility : NSObject

// 超时时间
@property(nonatomic,assign) NSTimeInterval timeOut;

@property(nonatomic,weak)id<DBZSocketCallBcakDelegate> delegate;

@property(atomic,readonly)DBSocketDelegateAvailableMethods  availableDelegateMethods;

/** 开始连接 */
- (void)DBZWebSocketOpenWithURLString:(NSString *)urlString;

/** 关闭连接 */
- (void)DBZWebSocketClose;

/** 发送数据 */
- (void)sendData:(id)data;


+ (DBZSocketRocketUtility *)instance;

@end
