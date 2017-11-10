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

@implementation RCTVLCPlayer
{

  /* Required to publish events */
    RCTEventDispatcher *_eventDispatcher;
//    VLCMediaPlayer *_player;

    BOOL _paused;
    BOOL _started;

}

static VLCMediaPlayer *_player = nil;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
  if ((self = [super init])) {
    _eventDispatcher = eventDispatcher;

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

- (VLCMediaPlayer*)sharedPlayer {
    @synchronized(self) {
        if (!_player) {
            _player = [[VLCMediaPlayer alloc] init];
        }
    }
    return _player;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (!_paused) {
        [self setPaused:_paused];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
  [self applyModifiers];
}

- (void)applyModifiers
{
    if(!_paused)
        [self play];
}

- (void)setPaused:(BOOL)paused
{
    //NSLog(@">>>>paused %i",paused);
    if(self.sharedPlayer){
        if(!_started)
            [self play];
        else {
            [self.sharedPlayer pause];
            _paused = paused;
        }
    }
}

-(void)play
{
    if(self.sharedPlayer){
        [self.sharedPlayer play];
        _paused = NO;
        _started = YES;
    }
}

-(void)setSource:(NSDictionary *)source
{
//    if(self.sharedPlayer){
//        [self _release];
//    }
    NSArray* options = [source objectForKey:@"initOptions"];
    NSString* uri    = [source objectForKey:@"uri"];
    BOOL    autoplay = [RCTConvert BOOL:[source objectForKey:@"autoplay"]];
    NSURL* _uri    = [NSURL URLWithString:uri];

    //init player && play
//    _player = [[VLCMediaPlayer alloc] initWithOptions:options];
    [self.sharedPlayer setDrawable:self];
    self.sharedPlayer.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerStateChanged:) name:VLCMediaPlayerStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerTimeChanged:) name:VLCMediaPlayerTimeChanged object:nil];
    self.sharedPlayer.media = [VLCMedia mediaWithURL:_uri];
    if(autoplay)
        [self play];
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    [self updateVideoProgress];
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    VLCMediaPlayerState state = self.sharedPlayer.state;
    switch (state) {
        case VLCMediaPlayerStatePaused:
            _paused = YES;
            //NSLog(@"VLCMediaPlayerStatePaused %i",VLCMediaPlayerStatePaused);
            [_eventDispatcher sendInputEventWithName:@"onVideoPaused"
                                                body:@{
                                                       @"target": self.reactTag
                                                       }];
            break;
        case VLCMediaPlayerStateStopped:
            //NSLog(@"VLCMediaPlayerStateStopped %i",VLCMediaPlayerStateStopped);
            [_eventDispatcher sendInputEventWithName:@"onVideoStopped"
                                                body:@{
                                                       @"target": self.reactTag
                                                       }];
            break;
        case VLCMediaPlayerStateBuffering:
            //NSLog(@"VLCMediaPlayerStateBuffering %i",VLCMediaPlayerStateBuffering);
            [_eventDispatcher sendInputEventWithName:@"onVideoBuffering"
                                                body:@{
                                                       @"target": self.reactTag
                                                       }];
            break;
        case VLCMediaPlayerStatePlaying:
            _paused = NO;
            //NSLog(@"VLCMediaPlayerStatePlaying %i",VLCMediaPlayerStatePlaying);
            [_eventDispatcher sendInputEventWithName:@"onVideoPlaying"
                                                body:@{
                                                       @"target": self.reactTag,
                                                       @"seekable": [NSNumber numberWithBool:[self.sharedPlayer isSeekable]],
                                                       @"duration":[NSNumber numberWithInt:[self.sharedPlayer.media.length intValue]]
                                                       }];
            break;
        case VLCMediaPlayerStateEnded:
            //NSLog(@"VLCMediaPlayerStateEnded %i",VLCMediaPlayerStateEnded);
            [_eventDispatcher sendInputEventWithName:@"onVideoEnded"
                                                body:@{
                                                       @"target": self.reactTag
                                                       }];
            break;
        case VLCMediaPlayerStateError:
            //NSLog(@"VLCMediaPlayerStateError %i",VLCMediaPlayerStateError);
            [_eventDispatcher sendInputEventWithName:@"onVideoError"
                                                body:@{
                                                       @"target": self.reactTag
                                                       }];
            [self _release];
            break;
        default:
            //NSLog(@"state %i",state);
            break;
    }
}

-(void)updateVideoProgress
{

    int currentTime   = [[self.sharedPlayer time] intValue];
    int remainingTime = [[self.sharedPlayer remainingTime] intValue];
    int duration      = [self.sharedPlayer.media.length intValue];

    if( currentTime >= 0 && currentTime < duration) {
        [_eventDispatcher sendInputEventWithName:@"onVideoProgress"
                                            body:@{
                                                   @"target": self.reactTag,
                                                   @"currentTime": [NSNumber numberWithInt:currentTime],
                                                   @"remainingTime": [NSNumber numberWithInt:remainingTime],
                                                   @"duration":[NSNumber numberWithInt:duration],
                                                   @"position":[NSNumber numberWithFloat:self.sharedPlayer.position]
                                                   }];
    }
}

- (void)jumpBackward:(int)interval
{
    if(interval>=0 && interval <= [self.sharedPlayer.media.length intValue])
        [self.sharedPlayer jumpBackward:interval];
}

- (void)jumpForward:(int)interval
{
    if(interval>=0 && interval <= [self.sharedPlayer.media.length intValue])
        [self.sharedPlayer jumpForward:interval];
}

-(void)setSeek:(float)pos
{
    if([self.sharedPlayer isSeekable]){
        if(pos>=0 && pos <= 1){
            [self.sharedPlayer setPosition:pos];
        }
    }
}

-(void)setSnapshotPath:(NSString*)path
{
  if(self.sharedPlayer)
    [self.sharedPlayer saveVideoSnapshotAt:path withWidth:0 andHeight:0];
}

-(void)setRate:(float)rate
{
    [self.sharedPlayer setRate:rate];
}

- (void)_release
{
    [self.sharedPlayer pause];
    [self.sharedPlayer stop];
//    self.sharedPlayer = nil;
    _eventDispatcher = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Lifecycle
- (void)removeFromSuperview
{
    [self _release];
    [super removeFromSuperview];
}

@end
