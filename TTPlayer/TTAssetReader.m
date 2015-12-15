//
//  TTAssetReader.m
//  TTPlayerExample
//
//  Created by liang on 12/15/15.
//  Copyright (c) 2015 tina. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "TTAssetReader.h"

@interface TTAssetReader ()
@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetTrack *track;
@property (nonatomic, strong) AVAssetReaderTrackOutput *trackOutput;

@end

@implementation TTAssetReader

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
        NSError *error;
        self.assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        self.track = tracks[0];
        NSDictionary *options = @{(__bridge_transfer NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        self.trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:self.track outputSettings:options];
        [self.assetReader addOutput:self.trackOutput];
        [self.assetReader startReading];
    }
    return self;
}

#pragma mark getter/setter
- (float)nominalFrameRate
{
    return self.track.nominalFrameRate;
}

#pragma mark public
- (CVImageBufferRef)readNextBuffer
{
    if (self.assetReader.status == AVAssetReaderStatusReading &&
        self.track.nominalFrameRate > 0) {
        CMSampleBufferRef sampleBuffer = [self.trackOutput copyNextSampleBuffer];
        if (sampleBuffer) {
            CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            return buffer;
        }
    }
    return nil;
}

@end
