#import "React/RCTView.h"

@class VLCMediaPlayer;

@interface RCTVLCPlayer : UIView

- (instancetype)initWithPlayer:(VLCMediaPlayer*)player;

@property (nonatomic) BOOL paused;
@property (nonatomic) float volume;

@property (nonatomic, copy) RCTDirectEventBlock onPaused;
@property (nonatomic, copy) RCTDirectEventBlock onStopped;
@property (nonatomic, copy) RCTDirectEventBlock onBuffering;
@property (nonatomic, copy) RCTDirectEventBlock onPlaying;
@property (nonatomic, copy) RCTDirectEventBlock onEnded;
@property (nonatomic, copy) RCTDirectEventBlock onError;
@property (nonatomic, copy) RCTDirectEventBlock onProgress;
@property (nonatomic, copy) RCTDirectEventBlock onVolumeChanged;

@end
