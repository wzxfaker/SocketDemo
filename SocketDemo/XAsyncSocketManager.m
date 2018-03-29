//
//  XAsyncSocketManager.m
//  SocketDemo
//
//  Created by admin on 2018/3/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XAsyncSocketManager.h"
#import "GCDAsyncSocket.h"

static  NSString * Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;

@interface XAsyncSocketManager()<GCDAsyncSocketDelegate>

/** <##> */
@property (nonatomic, strong) GCDAsyncSocket *gcdSocket;

@end

@implementation XAsyncSocketManager

+ (instancetype)sharedManager{
    static XAsyncSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initSocket];
    });
    return instance;
}

- (void)initSocket{
    _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (BOOL)connect{
    return [_gcdSocket connectToHost:Khost onPort:Kport error:nil];
}

- (void)disConnect{
    [_gcdSocket disconnect];
}

- (void)sendMsg:(NSString *)msg{
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdSocket writeData:data withTimeout:-1 tag:110];
}

- (void)pullMsg{
    //去读取当前消息队列中的未读消息
    //监听读数据的代理，只能监听10秒，10秒过后调用代理方法  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    //这个方法的作用就是去读取当前消息队列中的未读消息。记住，这里不调用这个方法，消息回调的代理是永远不会被触发的。而且必须是tag相同，如果tag不同，这个收到消息的代理也不会被处罚。
    [_gcdSocket readDataWithTimeout:-1 tag:110];
}

#pragma mark - GCDAsyncSocketDelegate
//连接成功时调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功：host:%@,port:%d",host,port);
    [self pullMsg];
    //心跳写在这🏀🏀🏀
    
}

//断开连接的时候调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接：host:%@,port:%d",sock.localHost,sock.localPort);
    //断线重连写在这🏀🏀
    
}

//写成功的回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"写成功的回调：%ld",tag);
}

//收到消息的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息--%@",msg);
    [self pullMsg];
}

@end
