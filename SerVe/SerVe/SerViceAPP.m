//
//  SerViceAPP.m
//  SerVe
//
//  Created by qianhaifeng on 16/5/5.
//  Copyright © 2016年 qianhaifeng. All rights reserved.
//

#import "SerViceAPP.h"
#import "GCDAsyncSocket.h"
#import "ClientObj.h"
@interface SerViceAPP()<GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket *serve;
@property(nonatomic, strong)NSMutableArray *arrayClient;
@property(nonatomic, strong)NSThread *checkThread;
@end

@implementation SerViceAPP

-(instancetype)init{
    if (self = [super init]) {
        self.serve = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        self.checkThread = [[NSThread alloc]initWithTarget:self selector:@selector(checkClientOnline) object:nil];
        [self.checkThread start];
    }
    
    return self;
}

-(NSMutableArray *)arrayClient{
    if (!_arrayClient) {
        _arrayClient = [NSMutableArray array];
    }
    
    return _arrayClient;
}

-(void)openSerVice{
    
    NSError *error;
   BOOL sucess = [self.serve acceptOnPort:8088 error:&error];
    if (sucess) {
        NSLog(@"端口开启成功,并监听客户端请求连接...");
    }else {
        NSLog(@"端口开启失...");
    }
}

#pragma delegate

- (void)socket:(GCDAsyncSocket *)serveSock didAcceptNewSocket:(GCDAsyncSocket *)clientSocket{
    NSLog(@"%@ IP: %@: %zd 客户端请求连接...",clientSocket,clientSocket.connectedHost,clientSocket.connectedPort);
    // 1.将客户端socket保存起来
    ClientObj *client = [[ClientObj alloc]init];
    client.scocket = clientSocket;
    client.timeNew = [NSDate date];
    [self.arrayClient addObject:client];
    [clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag  {
    NSString *clientStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",clientStr);
    NSString *log = [NSString stringWithFormat:@"IP:%@ %zd data: %@",clientSocket.connectedHost,clientSocket.connectedPort,clientStr];
   
    for (ClientObj *socket in self.arrayClient) {
         if (![clientSocket isEqual:socket.scocket]) {
             //群聊 发送给其他客户端
             [self writeDataWithSocket:socket.scocket str:log];
         }else{
             ///更新最新时间
             socket.timeNew = [NSDate date];
         }
    }
    [clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"又下线");
    NSMutableArray *arrayNew = [NSMutableArray array];
    for (ClientObj *socket in self.arrayClient ) {
        if ([socket.scocket isEqual:sock]) {
            continue;
        }
        [arrayNew addObject:socket   ];
    }
    self.arrayClient = arrayNew;
}

-(void)exitWithSocket:(GCDAsyncSocket *)clientSocket{
//    [self writeDataWithSocket:clientSocket str:@"成功退出\n"];
//    [self.arrayClient removeObject:clientSocket];
//    
//    NSLog(@"当前在线用户个数:%ld",self.arrayClient.count);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"数据发送成功..");
}

- (void)writeDataWithSocket:(GCDAsyncSocket*)clientSocket str:(NSString*)str{
    [clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

#pragma checkTimeThread

//开启线程 启动runloop 循环检测客户端socket最新time

- (void)checkClientOnline{
    @autoreleasepool {
        [NSTimer scheduledTimerWithTimeInterval:35 target:self selector:@selector(repeatCheckClinetOnline) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]run];
    }
}

//移除 超过心跳的 client
- (void)repeatCheckClinetOnline{
    if (self.arrayClient.count == 0) {
        return;
    }
    NSDate *date = [NSDate date];
    NSMutableArray *arrayNew = [NSMutableArray array];
    for (ClientObj *socket in self.arrayClient ) {
        if ([date timeIntervalSinceDate:socket.timeNew]>30) {
            continue;
        }
        [arrayNew addObject:socket   ];
    }
    self.arrayClient = arrayNew;
}
@end
