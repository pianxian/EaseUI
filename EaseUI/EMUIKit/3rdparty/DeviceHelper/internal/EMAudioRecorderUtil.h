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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef enum : NSUInteger {
    GCDAbandonPreviousAction, // 废除之前的任务
    GCDMergePreviousAction    // 将之前的任务合并到新的任务中
} GCDActionOption;
@interface GCDManager :NSObject
+ (GCDManager *)sharedInstance;

/**
 启动一个timer，默认精度为0.1秒
 
 @param timerName       timer的名称，作为唯一标识
 @param interval        执行的时间间隔
 @param queue           timer将被放入的队列，也就是最终action执行的队列。传入nil将自动放到一个子线程队列中
 @param repeats         timer是否循环调用
 @param option          多次schedule同一个timer时的操作选项(目前提供将之前的任务废除或合并的选项)
 @param action          时间间隔到点时执行的block
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(GCDActionOption)option
                                action:(dispatch_block_t)action;

/**
 撤销某个timer
 
 @param timerName timer的名称，作为唯一标识
 */
- (void)cancelTimerWithName:(NSString *)timerName;

/**
 撤销所有的timer
 */
- (void)cancelAllTimer;
@end

@interface EMAudioRecorderUtil : NSObject

+(BOOL)isRecording;

// Start recording
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// Stop recording
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// Cancel recording
+(void)cancelCurrentRecording;

// Current recorder
+(AVAudioRecorder *)recorder;
@end
