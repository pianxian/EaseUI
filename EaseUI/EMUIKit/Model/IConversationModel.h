/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EMConversation;

/** @brief 环信会话模型协议 */
@protocol IConversationModel <NSObject>

/** @brief 会话对象 */
@property (strong, nonatomic, readonly) EMConversation *conversation;
/** @brief 会话的标题(主要用户UI显示) */
@property (strong, nonatomic) NSString *title;
/** @brief conversationId的头像url */
@property (strong, nonatomic) NSString *avatarURLPath;
/** @brief conversationId的头像 */
@property (strong, nonatomic) UIImage *avatarImage;
//用户状态：1开播主播，2上麦用户，3普通用户
@property (assign, nonatomic) NSInteger ustatus;
//主播间id：用户状态为1和2时此字段值大于0并且为直播间id，其他时候此字段值为0
@property (assign, nonatomic) NSInteger liveroomid;
//用户uid
@property (nonatomic, assign) NSInteger uid;

/*!
 @method
 @brief 初始化会话对象模型
 @param conversation    会话对象
 @return 会话对象模型
 */
- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
