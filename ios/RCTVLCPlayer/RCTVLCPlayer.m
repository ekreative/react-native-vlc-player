#import "React/RCTConvert.h"
#import "RCTVLCPlayer.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "UIView+React.h"
#import <MobileVLCKit.h>

static NSString *const statusKeyPath = @"status";
static NSString *const playbackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString *const playbackBufferEmptyKeyPath = @"playbackBufferEmpty";
static NSString *const readyForDisplayKeyPath = @"readyForDisplay";
static NSString *const playbackRate = @"rate";

@interface RCTVLCPlayer()<VLCMediaPlayerDelegate>

@property (nonatomic, strong) VLCMediaPlayer *player;

@end


@implementation RCTVLCPlayer


- (id)initWithPlayer:(VLCMediaPlayer*)player {
  if (self = [super init]) {
      self.player = player;
      [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
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


- (void)setSource:(NSDictionary *)source {   
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
            if (self.onPaused) {
                self.onPaused(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateStopped:
            if (self.onStopped) {
                self.onStopped(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateBuffering:
            if (self.onBuffering) {
                self.onBuffering(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStatePlaying:
            _paused = NO;
            if (self.onPlaying) {
                self.onPlaying(@{ @"target": self.reactTag,
                                  @"seekable": [NSNumber numberWithBool:[self.player isSeekable]],
                                  @"duration":[NSNumber numberWithInt:[self.player.media.length intValue]] });
            }
            break;
        case VLCMediaPlayerStateEnded:
            [self.player stop];
            if (self.onEnded) {
                self.onEnded(@{ @"target": self.reactTag });
            }
            break;
        case VLCMediaPlayerStateError:
            if (self.onError) {
                self.onError(@{ @"target": self.reactTag });
            }
            [self _release];
            break;
        default:
            break;
    }
}


- (void)updateVideoProgress {
    int currentTime   = [[self.player time] intValue];
    int remainingTime = [[self.player remainingTime] intValue];
    int duration      = [self.player.media.length intValue];

    if( currentTime >= 0 && currentTime < duration) {
        if (self.onProgress) {
            self.onProgress(@{ @"target": self.reactTag,
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
    [super removeFromSuperview];
}

@end
