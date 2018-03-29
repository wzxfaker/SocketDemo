//
//  XAsyncSocketManager.h
//  SocketDemo
//
//  Created by admin on 2018/3/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XAsyncSocketManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)connect;

- (void)disConnect;

- (void)sendMsg:(NSString *)msg;

- (void)pullMsg;
@end
