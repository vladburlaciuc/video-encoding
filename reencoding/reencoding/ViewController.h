//
//  ViewController.h
//  reencoding
//
//  Created by wld on 22/07/2015.
//  Copyright (c) 2015 wld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property(nonatomic,strong) AVAsset *videoAsset;
@property(nonatomic,strong) AVAssetTrack *videoTrack;
@property(nonatomic,strong) AVAssetWriterInput* videoWriterInput;
@property(nonatomic,strong) AVAssetWriter *videoWriter;
@property(nonatomic,strong) AVAssetReaderTrackOutput *videoReaderOutput;
@property(nonatomic,strong) AVAssetReader *videoReader;
@property(nonatomic,strong) AVAssetWriterInput* audioWriterInput;
@property(nonatomic,strong) AVAssetTrack* audioTrack;
@property(nonatomic,strong) AVAssetReaderOutput *audioReaderOutput;
@property(nonatomic,strong) AVAssetReader *audioReader;
@end

