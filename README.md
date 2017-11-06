# react-native-vlc-player

A `<VLCPlayer>` component for react-native

Based on [react-native-vlcplayer](https://github.com/xiongchuan86/react-native-vlcplayer) from [xiongchuan86](https://github.com/xiongchuan86)

### Add it to your project

Run `npm i -S react-native-vlc-player`

#### iOS

- add `pod 'MobileVLCKit-unstable', '3.0.0a43'` in Podfile (stable version of VLCKit not working in iOS 11 yet)
- `pod install` inside ./ios/ folder
- `rnpm link react-native-vlc-player`
- also you must disable bitcode option in target build settings (otherwise it not linked correctly for armv7)
- also you must add `libstdc++.6.0.9.tbd` to `Linked Framework and Libraries`


## Usage

```
<VLCPlayer
    ref='vlcplayer'
    paused={this.state.paused}
    style={styles.vlcplayer}
    source={{uri:this.props.uri,initOptions:['--codec=avcodec']}}
    onProgress={this.onProgress.bind(this)}
    onEnded={this.onEnded.bind(this)}
    onStopped={this.onEnded.bind(this)}
    onPlaying={this.onPlaying.bind(this)}
    onBuffering={this.onBuffering.bind(this)}
    onPaused={this.onPaused.bind(this)}
 />

```

## Static Methods

`seek(seconds)`

```
this.refs['vlcplayer'].seek(0.333);
```

`snapshot(path)`

```
this.refs['vlcplayer'].snapshot(path);
```

## Examples


```
import React, { Component } from 'react';
import {
 AppRegistry,
 View,
 Text
} from 'react-native';
import SimpleVideo  from './SimpleVideo.js';
import Video  from './Video.js';



class vlcplayer extends Component {

  render() {
    const uri = 'http://cdn.goluk.cn/video/t1_2.mp4';
    return (
      <View>
      <SimpleVideo uri={uri} buttonSize={50} />
      <Text>A Simple Player</Text>
      <View style={{marginTop:50}} />
      <Video uri={uri} />
      <Text>A full-featured player</Text>
      </View>
    );
  }
}

AppRegistry.registerComponent('vlcplayer', () => vlcplayer);

```
