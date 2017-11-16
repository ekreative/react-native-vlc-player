#import "RCTVLCPlayerManager.h"
#import "RCTVLCPlayer.h"
#import <MobileVLCKit.h>

@implementation RCTVLCPlayerManager

+ (VLCMediaPlayer*)sharedVLCPlayer {
    static VLCMediaPlayer *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[VLCMediaPlayer alloc] init];
    });
    return sharedPlayer;
}

RCT_EXPORT_MODULE();

- (UIView *)view {
    return [[RCTVLCPlayer alloc] initWithPlayer:[RCTVLCPlayerManager sharedVLCPlayer]];
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL);
RCT_EXPORT_VIEW_PROPERTY(seek, float);
RCT_EXPORT_VIEW_PROPERTY(rate, float);
RCT_EXPORT_VIEW_PROPERTY(snapshotPath, NSString);
RCT_EXPORT_VIEW_PROPERTY(onPaused, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStopped, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBuffering, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaying, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onEnded, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock);


@end
