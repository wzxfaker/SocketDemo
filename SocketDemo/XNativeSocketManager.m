//
//  XNativeSocketManager.m
//  SocketDemo
//
//  Created by admin on 2018/3/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XNativeSocketManager.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface XNativeSocketManager()

/** <##> */
@property (nonatomic, assign) int clientSocket;

@end

@implementation XNativeSocketManager

+ (instancetype)sharedManager{
    static XNativeSocketManager *_sockerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sockerManager = [[self alloc] init];
        [_sockerManager initSocket];
//        [_sockerManager pullMsg];
    });
    return _sockerManager;
}

- (void)initSocket{
    //每次连接前先断开
    if (_clientSocket != 0) {
        [self disConnect];
        _clientSocket = 0;
    }
    //创建客户端
    _clientSocket = CreateClientSocket();
    //服务器IP,本机作为服务器，127.0.0.1代表本地ip
    const char *server_ip = "127.0.0.1";
    //服务器端口
    short server_port = 6969;
    //等于0说明连接失败
    if (ConnectionToServer(_clientSocket,server_ip,server_port) == 0) {
        printf("connect to server fail\n");
        return;
    }
    printf("连接成功");
}

static int CreateClientSocket(){
    int ClientSocket = 0;
    /**
     //创建一个socket，返回值类型为int（socket其实就是Int类型）
     参数1：addressFamily IPv4(AF_INET) 或 IPv6(AF_INET6)
     参数2：type 表示 socket 的类型，通常是流stream(SOCK_STREAM) 或数据报文datagram(SOCK_DGRAM)
     参数3：protocol 参数通常设置为0，以便让系统自动为我们选择合适的协议，对于 stream socket 来说会是 TCP 协议(IPPROTO_TCP)，而对于 datagram来说会是 UDP 协议(IPPROTO_UDP)
     */
    ClientSocket = socket(AF_INET, SOCK_STREAM, 0);
    return ClientSocket;
}

static int ConnectionToServer(int client_socket,const char *server_ip,unsigned short server_port){
    //生成一个sockaddr_in类型结构体
    struct sockaddr_in sAddr = {0};
    sAddr.sin_len = sizeof(sAddr);
    //设置IPV4
    sAddr.sin_family = AF_INET;
    //inet_aton是一个改进的方法来将一个字符串IP地址转换为一个32位的网络序列IP地址
    //如果这个函数成功，函数的返回值非零，如果输入地址不正确则会返回零
    inet_aton(server_ip, &sAddr.sin_addr);
    //htons是将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port = htons(server_port);
    //用scoket和服务端地址，发起连接。
    //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
    //注意：该接口调用会阻塞当前线程，直到服务器返回。
    if (connect(client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr)) == 0) {
        return client_socket;
    }
    return 0;
}

#pragma mark - 对内逻辑
//新线程来接收消息
- (void)pullMsg{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveMsg) object:nil];
    [thread start];
}

//收取服务端发送的消息
- (void)receiveMsg{
    while (1) {//保证线程存活
        char recv_Msg[1024] = {0};
        //接收字节长度
        size_t reLen = recv(self.clientSocket, recv_Msg, sizeof(recv_Msg), 0);
        NSData *data = [NSData dataWithBytes:recv_Msg length:reLen];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到的数据--%@",str);
    }
}

#pragma mark - 对外逻辑
- (void)connect{
    [self initSocket];
}

- (void)disConnect{
    close(self.clientSocket);
}

- (void)sendMsg:(NSString *)msg{
    const char *send_Msg = [msg UTF8String];
    send(self.clientSocket, send_Msg, strlen(send_Msg)+1, 0);
}
@end
