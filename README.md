# react-native-vlc-player

A `<VLCPlayer>` component for react-native

Based on [react-native-vlcplayer](https://github.com/xiongchuan86/react-native-vlcplayer) from [xiongchuan86](https://github.com/xiongchuan86) and on [react-native-vlc-player](https://github.com/ghondar/react-native-vlc-player) from [ghondar](https://github.com/ghondar)

### Add it to your project

Run `npm i -S react-native-vlc-player`

#### iOS

- add `pod 'MobileVLCKit-unstable', '3.0.0a44'` in Podfile (stable version of VLCKit not working in iOS 11 yet)
- `pod install` inside ./ios/ folder
- `rnpm link react-native-vlc-player`
- also you must disable bitcode option in target build settings (otherwise it not linked correctly for armv7)
- also you must add `libstdc++.6.0.9.tbd` to `Linked Framework and Libraries`

#### Android

- in settings.gradle change:

  `new File(rootProject.projectDir, '../node_modules/react-native-vlc-player/android')`

  to

  `new File(rootProject.projectDir, '../node_modules/react-native-vlc-player/android/vlc')`
- in *MainApplication.java* you need to import `com.rusmigal.vlcplayer.VLCPlayerPackage` instead of `com.vlcplayer.VLCPlayerPackage`

## Usage

```
<VLCPlayer
    ref='vlcplayer'
    paused={this.state.paused}
    style={styles.vlcplayer}
    source={{uri: this.props.uri, initOptions: ['--codec=avcodec']}}
    onVLCProgress={this.onProgress.bind(this)}
    onVLCEnded={this.onEnded.bind(this)}
    onVLCStopped={this.onEnded.bind(this)}
    onVLCPlaying={this.onPlaying.bind(this)}
    onVLCBuffering={this.onBuffering.bind(this)}
    onVLCPaused={this.onPaused.bind(this)}
 />

```
### Properties
source.initOptions - only for iOS
rate - only for iOS
snapshotPath - only for iOS

### Callbacks
onBuffering - only for iOS

## Static Methods

`seek(seconds)`

```
this.refs['vlcplayer'].seek(0.333);
```

`snapshot(path)`

```
this.refs['vlcplayer'].snapshot(path);
```
