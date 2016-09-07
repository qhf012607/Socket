//
//  main.m
//  SerVe
//
//  Created by qianhaifeng on 16/5/5.
//  Copyright © 2016年 qianhaifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerViceAPP.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        SerViceAPP *app = [[SerViceAPP alloc]init    ];
        [app  openSerVice];
        [[NSRunLoop mainRunLoop]run];
    }
    return 0;
}
