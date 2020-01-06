//
//  MOKOSecretTrainRecorder.m
//  MOKORecord
//
//  Created by Spring on 2017/4/26.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import "MOKORecorderTool.h"
#import "amr_wav_converter.h"
#import "SGGCDManager.h"
#define MOKOSecretTrainRecordFielName @"lvRecord.m4a"
#define MIN_RECORDER_TIME 1
#define TimerName @"audioTimer_999"
@interface MOKORecorderTool()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    BOOL isRecording;
    dispatch_source_t timer;
      NSUInteger __block audioTimeLength; //录音时长
}
//录音文件地址
@property (nonatomic, strong) NSURL *recordFileUrl;

@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation MOKORecorderTool

static MOKORecorderTool *instance = nil;
#pragma mark - 单例
+ (instancetype)sharedRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (void)startRecording
{
    // 录音时停止播放 删除曾经生成的文件
//    [self stopPlaying];
    [self destructionRecordingFile];
    
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    [self.recorder prepareToRecord];
       
    [self.recorder record];
       
    if ([self.recorder isRecording]) {
        isRecording = YES;
        [self activeTimer];
//        if (self.audioStartRecording) {
//            self.audioStartRecording(YES);
//        }
    } else {
//        if (self.audioStartRecording) {
//            self.audioStartRecording(NO);
//        }
    }
//    // 真机环境下需要的代码
//    self.session = [AVAudioSession sharedInstance];
//    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [self.recorder record];
}
- (void)activeTimer
{
    //录音时长
    audioTimeLength = 0;
    
    [[SGGCDManager sharedInstance]scheduledDispatchTimerWithName:TimerName timeInterval:1 queue:nil repeats:YES actionOption:AbandonPreviousAction action:^{
        audioTimeLength ++;
        if (audioTimeLength >= 60) { //大于等于60秒停止
            [self stopRecording];
        }
    }];
}
- (void)updateImage
{
    [self.recorder updateMeters];
    
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    //NSLog(@"%f", result);
    int no = 0;
    if (result > 0 && result <= 1.3) {
        no = 1;
    } else if (result > 1.3 && result <= 2) {
        no = 2;
    } else if (result > 2 && result <= 3.0) {
        no = 3;
    } else if (result > 3.0 && result <= 3.0) {
        no = 4;
    } else if (result > 5.0 && result <= 10) {
        no = 5;
    } else if (result > 10 && result <= 40) {
        no = 6;
    } else if (result > 40) {
        no = 7;
    }
    if ([self.delegate respondsToSelector:@selector(recorder:didstartRecoring:)])
    {
        [self.delegate recorder:self didstartRecoring: no];
    }
    else
    {
        
    }
}
- (void)stopRecording
{
    if ([self.recorder isRecording])
    {
        [self.recorder stop];
        
        isRecording = NO;
         
         //取消定时器
         if (timer) {
             dispatch_source_cancel(timer);
             timer = NULL;
         }
    }
}
- (void)playRecordingFile
{
    [self.recorder stop];// 播放时停止录音
    // 正在播放就返回
    if ([self.player isPlaying])
    {
        return;
    }
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:&error];
    self.player.delegate = self;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}
-(instancetype)init{
    if (self = [super init]) {
        NSString *wavRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:@"sangorRecordFie.aac"];
//        NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sangorRecordFie.amr"];

        if (![[NSFileManager defaultManager]fileExistsAtPath:wavRecordFilePath]) {
            [[NSData data] writeToFile:wavRecordFilePath atomically:YES];
        }
//        if (![[NSFileManager defaultManager]fileExistsAtPath:amrRecordFilePath]) {
//            [[NSData data] writeToFile:amrRecordFilePath atomically:YES];
//        }
//            NSString *wavRecordFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:@"sangorRecordFie.wav"];
        self.recordFileUrl = [NSURL fileURLWithPath:wavRecordFilePath];
        //        NSLog(@"%@", wavRecordFilePath);
                
                // 3.设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                // 音频格式
        setting[AVFormatIDKey] = @(kAudioFormatMPEG4AAC);
                // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        setting[AVSampleRateKey] = @(16000.0);
                // 音频通道数 1 或 2
        setting[AVNumberOfChannelsKey] = @(1);
                // 线性音频的位深度  8、16、24、32
        setting[AVLinearPCMBitDepthKey] = @(16);
                //录音的质量
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];

        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:NULL];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        
    }
    return self;
}

- (void)stopPlaying
{
    [self.player stop];
}

//#pragma mark - 懒加载
//- (AVAudioRecorder *)recorder {
//    if (!_recorder) {
//        // 1.获取沙盒地址
////        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
////        NSString *filePath = [path stringByAppendingPathComponent:MOKOSecretTrainRecordFielName];
//
//
////
////        [_recorder prepareToRecord];
//    }
//    return _recorder;
//}

- (void)destructionRecordingFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl)
    {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}


#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
    
    
//        //暂存录音文件路径
//    NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sangorRecordFie.acc"];
//    NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sangorRecordFie.amr"];
    
    //重点:把wav录音文件转换成amr文件,用于网络传输.amr文件大小是wav文件的十分之一左右
//    wave_file_to_amr_file([wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],[amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding], 1, 16);
//    
//    //返回amr音频文件Data,用于传输或存储
//    NSData *cacheAudioData = [NSData dataWithContentsOfURL:self.recordFileUrl];
    
    //大于最小录音时长时,发送数据
    if (audioTimeLength >= MIN_RECORDER_TIME) {
//        if (self.audioRecorderFinishRecording) {
//            self.audioRecorderFinishRecording(cacheAudioData, audioTimeLength);
//        }
        NSLog(@"大于最短时间");
        if (self.delegate &&[self.delegate respondsToSelector:@selector(recordFinish:duration:isSuccess:)]) {
            [self.delegate recordFinish:self.recordFileUrl duration:audioTimeLength isSuccess:YES];
        }
    } else {
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(recordFinish:duration:isSuccess:)]) {
            [self.delegate recordFinish:self.recordFileUrl duration:audioTimeLength isSuccess:NO];
        }
         
        NSLog(@"小于最短时间请重新录制");
        
//        if (self.audioRecordingFail) {
//            self.audioRecordingFail(@"录音时长小于设定最短时长");
//        }
    }
    
    isRecording = NO;
    
    //取消定时器
    if (timer) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }
}
#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //录音播放结束
    if ([self.delegate respondsToSelector:@selector(recordToolDidFinishPlay:)])
    {
        [self.delegate recordToolDidFinishPlay:self];
    }
}

@end
