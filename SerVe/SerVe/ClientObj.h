//
//  ClientObj.h
//  SerVe
//
//  Created by qianhaifeng on 16/9/7.
//  Copyright © 2016年 qianhaifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@interface ClientObj : NSObject
@property(nonatomic, strong)GCDAsyncSocket *scocket;
@property(nonatomic, strong)NSDate *timeNew; //更新最新通讯时间
@end
