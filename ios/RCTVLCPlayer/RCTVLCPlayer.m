#import "React/RCTConvert.h"
#import "RCTVLCPlayer.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "UIView+React.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileVLCKit.h>

static NSString *const statusKeyPath = @"status";
static NSString *const playbackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString *const playbackBufferEmptyKeyPath = @"playbackBufferEmpty";
static NSString *const readyForDisplayKeyPath = @"readyForDisplay";
static NSString *const playbackRate = @"rate";

@interface MPVolumeView()

@property (nonatomic, readonly) UISlider *volumeSlider;

@end

@implementation MPVolumeView (private_volume)

- (UISlider*)volumeSlider {
    for(id view in self.subviews) {
        if ([view isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider*)view;
            slider.continuous = NO;
            slider.value = AVAudioSession.sharedInstance.outputVolume;
            return slider;
        }
    }
    return nil;
}

@end


@interface RCTVLCPlayer()<VLCMediaPlayerDelegate>

@property (nonatomic) UISlider *volumeSlider;
@property (nonatomic, strong) VLCMediaPlayer *player;

@end


@implementation RCTVLCPlayer

@synthesize volume = _volume;


- (id)initWithPlayer:(VLCMediaPlayer*)player {
  if (self = [super init]) {
      _volume = -1.0;
      self.volumeSlider = [[[MPVolumeView alloc] init] volumeSlider];
      self.player = player;
      [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(volumeChanged:)
                                                   name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                 object:nil];

  }
  return self;
}


- (void)applicationWillResignActive:(NSNotification *)notification {
    if (!_paused) {
        [self setPaused:_paused];
    }
}


- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if(!_paused) {
        [self setPaused:NO];
    }
}


- (void)setPaused:(BOOL)paused {
    if (self.player) {
        if (paused) {
            [self.player pause];
        } else {
            [self.player play];
        }
        _paused = paused;
    }
}


- (void)setVolume:(float)volume {
    if ((_volume != volume)) {
        _volume = volume;
        self.volumeSlider.value = volume;
    }
}


- (float)volume {
    return self.volumeSlider.value;
}


- (void)setSource:(NSDictionary *)source {
    if(self.player) {
        [self.player pause];
        self.player.drawable = nil;
        self.player.delegate = nil;
    }

    NSString* uri    = [source objectForKey:@"uri"];
    BOOL    autoplay = [RCTConvert BOOL:[source objectForKey:@"autoplay"]];
    NSURL* _uri    = [NSURL URLWithString:uri];

    //init player && play
    [self.player setDrawable:self];
    self.player.delegate = self;
    self.player.media = [VLCMedia mediaWithURL:_uri];
    [self setPaused:!autoplay];
}


- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    [self updateVideoProgress];
}


- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    VLCMediaPlayerState state = self.player.state;
    switch (state) {
        case VLCMediaPlayerStatePaused:
            _paused = YES;
            if (self.onVLCPaused) {
                self.onVLCPaused(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateStopped:
            if (self.onVLCStopped) {
                self.onVLCStopped(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateBuffering:
            if (self.onVLCBuffering) {
                self.onVLCBuffering(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStatePlaying:
            _paused = NO;
            if (self.onVLCPlaying) {
                self.onVLCPlaying(@{ @"target": self.reactTag,
                                  @"seekable": [NSNumber numberWithBool:[self.player isSeekable]],
                                  @"duration":[NSNumber numberWithInt:[self.player.media.length intValue]] });
            }
            break;
        case VLCMediaPlayerStateEnded:
            [self.player stop];
            if (self.onVLCEnded) {
                self.onVLCEnded(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateError:
            if (self.onVLCError) {
                self.onVLCError(@{ @"target": self.reactTag });
            }
            [self _release];
            break;
        default:
            break;
    }
}


- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (_volume != volume) {
        _volume = volume;
        if (self.onVLCVolumeChanged) {
            self.onVLCVolumeChanged(@{@"volume": [NSNumber numberWithFloat: volume]});
        }
    }
}


- (void)updateVideoProgress {
    int currentTime   = [[self.player time] intValue];
    int remainingTime = [[self.player remainingTime] intValue];
    int duration      = [self.player.media.length intValue];

    if( currentTime >= 0 && currentTime < duration) {
        if (self.onVLCProgress) {
            self.onVLCProgress(@{ @"target": self.reactTag,
                               @"currentTime": [NSNumber numberWithInt:currentTime],
                               @"remainingTime": [NSNumber numberWithInt:remainingTime],
                               @"duration":[NSNumber numberWithInt:duration],
                               @"position":[NSNumber numberWithFloat:self.player.position] });
        }
    }
}


- (void)jumpBackward:(int)interval {
    if(interval>=0 && interval <= [self.player.media.length intValue]) {
        [self.player jumpBackward:interval];
    }
}


- (void)jumpForward:(int)interval {
    if(interval>=0 && interval <= [self.player.media.length intValue]) {
        [self.player jumpForward:interval];
    }
}


- (void)setSeek:(float)pos {
    if([self.player isSeekable]) {
        if(pos >= 0 && pos <= 1.0) {
            [self.player setPosition:pos];
        }
    }
}


- (void)setSnapshotPath:(NSString*)path {
    if(self.player) {
        [self.player saveVideoSnapshotAt:path withWidth:0 andHeight:0];
    }
}


- (void)setRate:(float)rate {
    [self.player setRate:rate];
}


- (void)_release {
    [self.player stop];
    self.player.drawable = nil;
    self.player.delegate = nil;
    self.player = nil;
}


#pragma mark - Lifecycle
- (void)removeFromSuperview {
    [self _release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

@end
