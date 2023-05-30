//
//  DBZSocketRocketUtility.m
//  SUN
//
//  Created by linxi on 19/11/6.
//  Copyright © 标贝. All rights reserved.
//

#import "DBZSocketRocketUtility.h"
#import <DBZSocketRocket.h>

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@interface DBZSocketRocketUtility()<DBZWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
    NSTimeInterval _logTimeIntever;
}

@property (nonatomic,strong) DBZWebSocket *socket;

@property (nonatomic,copy) NSString *urlString;

@property(atomic,assign,readwrite)DBSocketDelegateAvailableMethods  availableDelegateMethods;

@end

@implementation DBZSocketRocketUtility

+ (DBZSocketRocketUtility *)instance {
//    static DBZSocketRocketUtility *Instance = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
        DBZSocketRocketUtility * Instance = [[DBZSocketRocketUtility alloc] init];
//    });
    return Instance;
}

- (void)setDelegate:(id<DBZSocketCallBcakDelegate>)delegate {
    
        _delegate = delegate;
        self.availableDelegateMethods = (DBSocketDelegateAvailableMethods){
            .webSocketDidOpenNote = [delegate respondsToSelector:@selector(webSocketDidOpenNote)],
            .webSocketDidCloseNote = [delegate respondsToSelector:@selector(webSocketDidCloseNote:)],
            .webSocketdidReceiveMessageNote = [delegate respondsToSelector:@selector(webSocketdidReceiveMessageNote:)],
            .webSocketdidConnectFailed = [delegate respondsToSelector:@selector(webSocketdidConnectFailed:)]
            
        };
}

#pragma mark - **************** public methods
-(void)DBZWebSocketOpenWithURLString:(NSString *)urlString {
    
    //如果是同一个url return
    if (self.socket) {
        return;
    }
    
    if (!urlString) {
        return;
    }
    
    self.urlString = urlString;
    
    self.socket = [[DBZWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
//    NSLog(@"socket %@,请求的websocket地址：%@",self.socket,self.socket.url.absoluteString);

    //DBZWebSocketDelegate 协议
    self.socket.delegate = self;   
    
    //开始连接
    [self.socket open];
}

- (void)DBZWebSocketClose {
    if (self.socket){
        [self.socket close];
        self.socket = nil;
    }
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)sendData:(id)data {
    // 记录时间
    NSTimeInterval timeIntever = [[NSDate date] timeIntervalSince1970];
    _logTimeIntever = timeIntever;
//    NSLog(@"data:%@ onlineSynthesizerParameters %@",[NSDate date],data);
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                [self reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                
                [self reConnect];
            }
        } else {
//            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}

#pragma mark - **************** private mothodes
//重连机制
- (void)reConnect {
    [self DBZWebSocketClose];
    if (reConnectTime > self.timeOut) {
        //您的网络状况不是很好，请检查网络后重试
        reConnectTime = 0;
        NSDictionary *message = @{@"code":@"90005",@"message":@"failed connect sever"};
        if (self.availableDelegateMethods.webSocketdidConnectFailed) {
            [self.delegate webSocketdidConnectFailed:message];
        }
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self DBZWebSocketOpenWithURLString:self.urlString];
    });
    
    // default time is 10s
    if (reConnectTime == 0) {
        reConnectTime = 10;
    } else {
        reConnectTime += 4;
    }
}


//取消心跳
- (void)destoryHeartBeat {
   __block  typeof(heartBeat) weakHeartBeat = heartBeat;
    dispatch_main_async_safe(^{
        if (weakHeartBeat) {
            if ([weakHeartBeat respondsToSelector:@selector(isValid)]){
                if ([weakHeartBeat isValid]){
                    [weakHeartBeat invalidate];
                    weakHeartBeat = nil;
                }
            }
        }
    })
}

//初始化心跳
- (void)initHeartBeat {
  __block  typeof(heartBeat) weakHeartBeat = heartBeat;
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        weakHeartBeat = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:weakHeartBeat forMode:NSRunLoopCommonModes];
    })
}

- (void)sentheart {
    //发送心跳 和后台可以约定发送什么内容  一般可以调用ping  我这里根据后台的要求 发送了data给他
    NSDictionary *dict = @{@"key":@"123"};
    NSString *jsonString = [self dictionaryToJson:dict];
    [self sendData:jsonString];
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
//pingPong
- (void)ping {
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil error:nil];
    }
}

#pragma mark - **************** DBZWebSocketDelegate
- (void)webSocketDidOpen:(DBZWebSocket *)webSocket {
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳
    _logTimeIntever = [[NSDate date] timeIntervalSince1970];
    if (webSocket == self.socket) {
//        NSLog(@"************************** socket 连接成功************************** ");
        if (self.availableDelegateMethods.webSocketDidOpenNote) {
            [self.delegate webSocketDidOpenNote];
        }
    }
}

- (void)webSocket:(DBZWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (webSocket == self.socket) {
//        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        if (error.code == 50 || error.code == 2145 ) { // 网络错误，就直接回调错误
            NSDictionary *message = @{@"code":@"90005",@"message":@"failed connect sever"};
            if (self.availableDelegateMethods.webSocketdidConnectFailed) {
                [self.delegate webSocketdidConnectFailed:message];
            }
            return ;
        }
        //连接失败就重连
        [self reConnect];
    }
}

- (void)webSocket:(DBZWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {

    if (webSocket == self.socket) {
//        NSLog(@"************************** socket连接断开************************** ");
        [self DBZWebSocketClose];
    }
    if (self.availableDelegateMethods.webSocketDidCloseNote) {
        [self.delegate webSocketDidCloseNote:nil];
    }
}

/*
 该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
- (void)webSocket:(DBZWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
//    NSLog(@"reply===%@",reply);
}

- (void)webSocket:(DBZWebSocket *)webSocket didReceiveMessage:(id)message  {
    NSTimeInterval timeIntever = [[NSDate date] timeIntervalSince1970];
    
    NSTimeInterval countIntever = timeIntever - _logTimeIntever;
    _logTimeIntever = timeIntever;
    
    if (webSocket == self.socket) {
//        NSLog(@"************************** socket收到数据了 时间差%3f************************** ",countIntever);
//        NSLog(@"message:%@",message);
        if (self.availableDelegateMethods.webSocketdidReceiveMessageNote) {
            [self.delegate webSocketdidReceiveMessageNote:message];
        }
    }
}

#pragma mark - **************** setter getter
- (SRReadyState)socketReadyState {
    return self.socket.readyState;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
