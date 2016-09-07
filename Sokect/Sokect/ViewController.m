//
//  ViewController.m
//  Sokect
//
//  Created by qianhaifeng on 16/5/5.
//  Copyright © 2016年 qianhaifeng. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate>
@property(nonatomic,strong)GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *mesage;
@property (weak, nonatomic) IBOutlet UIButton *sender;
@property (nonatomic, strong)NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [socket connectToHost:@"192.168.1.129" onPort:8088 error:nil];
    
    self.socket = socket;
    [self.sender addTarget:self action:@selector(sendmessage:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma delegate

- (void)sendmessage:(UIButton*)sender{
    [self.socket writeData:[self.mesage.text dataUsingEncoding:NSUTF8StringEncoding ] withTimeout:-1 tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",dataStr);
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功");
    
    [self.socket readDataWithTimeout:-1 tag:0];
    //开启线程发送心跳
    [self.thread start];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接 %@",err);
    //再次可以重连
    if (err) {
//         [self.socket connectToHost:sock.connectedHost onPort:sock.connectedPort error:nil];
    }else{
//        正常断开
    }
   
}

- (void)threadStart{
    @autoreleasepool {
        [NSTimer scheduledTimerWithTimeInterval:29 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]run];
    }
}

- (void)heartBeat{
    [self.socket writeData:[@"heart" dataUsingEncoding:NSUTF8StringEncoding ] withTimeout:-1 tag:0];
}

- (NSThread*)thread{
    if (!_thread) {
        _thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadStart) object:nil];
    }
    return _thread;
}

@end
