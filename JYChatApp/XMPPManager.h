//
//  XMPPManager.h
//  JYChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 李金岩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"


@interface XMPPManager : NSObject

//通信管道
@property(nonatomic, strong)XMPPStream *xmppStream;

//好友花名册
@property(nonatomic, strong)XMPPRoster *xmppRoster;

@property(nonatomic, strong)XMPPRosterCoreDataStorage *coreDataStorage;

//聊天消息类
@property(nonatomic, strong)XMPPMessageArchiving *messageArchiving;

//被管理对象上下文
@property(nonatomic, strong)NSManagedObjectContext *context;

/**
 * 单例
 **/

+(instancetype)shareInstance;



/**
 *   注册
 *@param 用户名
 *@return 密码
 **/



- (void) registerWithUserName:(NSString *)name
                     passWord:(NSString *)passWord;



//登录

- (void) loginWithUserName:(NSString *)name
                  passWord:(NSString *)passWord;




@end
