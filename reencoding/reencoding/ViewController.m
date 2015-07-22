//
//  ViewController.m
//  reencoding
//
//  Created by wld on 22/07/2015.
//  Copyright (c) 2015 wld. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buton;

@end

@implementation ViewController
@synthesize videoAsset;
@synthesize videoTrack;
@synthesize videoWriterInput;
@synthesize videoWriter;
@synthesize videoReaderOutput;
@synthesize videoReader;
@synthesize audioWriterInput;
@synthesize audioTrack;
@synthesize audioReaderOutput;
@synthesize audioReader;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ecodeAction:(id)sender {
    [self.buton setTitle:@"Press home button now" forState:UIControlStateNormal];
    [self performSelector:@selector(startEncode) withObject:nil afterDelay:5];
}

-(void)startEncode{
    [self.buton setTitle:@"Start encode" forState:UIControlStateNormal];
    NSString *inputPath=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"m4v"];
    NSString *outputFilePath=[NSTemporaryDirectory() stringByAppendingString:@"temp.mov"];
    [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:inputPath] options:nil];
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count==0 || [videoAsset tracksWithMediaType:AVMediaTypeAudio].count==0 ) {
        NSLog(@"Video don't contain sound");
        return;
    }else{
        videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGSize videoSize = videoTrack.naturalSize;
        NSMutableDictionary *videoWriterCompressionSettings =  [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3000000], AVVideoAverageBitRateKey, nil];
        NSMutableDictionary *videoWriterSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
        videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoWriterSettings];
        videoWriterInput.expectsMediaDataInRealTime = YES;
        videoWriterInput.transform = videoTrack.preferredTransform;
        videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputFilePath] fileType:AVFileTypeQuickTimeMovie error:nil];
        
        [videoWriter addInput:videoWriterInput];
        NSMutableDictionary *videoReaderSettings = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
        videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
        [videoReader addOutput:videoReaderOutput];
        //setup audio writer
        audioWriterInput = [AVAssetWriterInput
                            assetWriterInputWithMediaType:AVMediaTypeAudio
                            outputSettings:nil];
        audioWriterInput.expectsMediaDataInRealTime = YES;
        [videoWriter addInput:audioWriterInput];
        
        audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
        [audioReader addOutput:audioReaderOutput];
        [videoWriter startWriting];
        [videoReader startReading];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
        [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
            
            while ([videoWriterInput isReadyForMoreMediaData]) {
                
                CMSampleBufferRef sampleBuffer=[videoReaderOutput copyNextSampleBuffer];
                
                if ([videoReader status] == AVAssetReaderStatusReading && sampleBuffer) {
                    [videoWriterInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                }
                
                else {
                    NSLog(@"reader status: %ld",(long)[videoReader status]);
                    [videoWriterInput markAsFinished];
                    if ([videoReader status] == AVAssetReaderStatusCompleted) {
                        [audioReader startReading];
                        [videoWriter startSessionAtSourceTime:kCMTimeZero];
                        dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue2", NULL);
                        NSLog(@"start audio");
                        [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
                            while (audioWriterInput.readyForMoreMediaData) {
                                CMSampleBufferRef sampleBuffer;
                                if ([audioReader status] == AVAssetReaderStatusReading &&
                                    (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                    [audioWriterInput appendSampleBuffer:sampleBuffer];
                                    CFRelease(sampleBuffer);
                                }
                                else {
                                    [audioWriterInput markAsFinished];
                                    
                                    if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                        [videoWriter finishWritingWithCompletionHandler:^(){
                                            NSLog(@"%@",videoWriter);
                                            NSLog(@"Write Ended with Success");
                                        }];
                                    }
                                    if ([videoReader status] == AVAssetReaderStatusCancelled) {
                                        NSLog(@"conversionCanceled");
                                   
                                        break;
                                    }
                                    if ([videoReader status] == AVAssetReaderStatusFailed) {
                                        NSLog(@"conversionFAILED %@",videoReader.error);
                                    
                                        break;
                                    }
                                    if ([videoReader status] == AVAssetReaderStatusUnknown) {
                                        NSLog(@"conversionUNKNOWN");
                                       
                                        break;
                                    }
                                }
                            }
                            
                        }];
                    }
                    if ([videoReader status] == AVAssetReaderStatusCancelled) {
                        NSLog(@"conversionCanceled");
                        break;
                    }
                    if ([videoReader status] == AVAssetReaderStatusFailed) {
                        NSLog(@"conversionFAILED %@",videoReader.error);
                        break;
                    }
                    if ([videoReader status] == AVAssetReaderStatusUnknown) {
                        NSLog(@"conversionUNKNOWN");
                        break;
                    }
                }
            }
        }];
        
    }
}
@end
