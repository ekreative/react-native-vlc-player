#import "React/RCTView.h"

@class VLCMediaPlayer;

@interface RCTVLCPlayer : UIView

- (instancetype)initWithPlayer:(VLCMediaPlayer*)player;

@property (nonatomic) BOOL paused;
@property (nonatomic) float volume;

@property (nonatomic, copy) RCTDirectEventBlock onVLCPaused;
@property (nonatomic, copy) RCTDirectEventBlock onVLCStopped;
@property (nonatomic, copy) RCTDirectEventBlock onVLCBuffering;
@property (nonatomic, copy) RCTDirectEventBlock onVLCPlaying;
@property (nonatomic, copy) RCTDirectEventBlock onVLCEnded;
@property (nonatomic, copy) RCTDirectEventBlock onVLCError;
@property (nonatomic, copy) RCTDirectEventBlock onVLCProgress;
@property (nonatomic, copy) RCTDirectEventBlock onVLCVolumeChanged;

@end
