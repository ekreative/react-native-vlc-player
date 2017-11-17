import React from 'react'
import ReactNative from 'react-native'
import PropTypes from 'prop-types'

const {
  Component
} = React

const {
  StyleSheet,
  requireNativeComponent,
  View
} = ReactNative

export default class VLCPlayer extends Component {
  constructor (props, context) {
    super(props, context)
    this.seek = this.seek.bind(this)
    this.snapshot = this.snapshot.bind(this)
    this._assignRoot = this._assignRoot.bind(this)
    this._onError = this._onError.bind(this)
    this._onProgress = this._onProgress.bind(this)
    this._onEnded = this._onEnded.bind(this)
    this._onPlaying = this._onPlaying.bind(this)
    this._onStopped = this._onStopped.bind(this)
    this._onPaused = this._onPaused.bind(this)
    this._onBuffering = this._onBuffering.bind(this)
  }

  setNativeProps (nativeProps) {
    this._root.setNativeProps(nativeProps)
  }

  seek (pos) {
    this.setNativeProps({ seek: pos })
  }

  snapshot (path) {
    this.setNativeProps({ snapshotPath: path })
  }

  _assignRoot (component) {
    this._root = component
  }

  _onBuffering (event) {
    if (this.props.onBuffering) {
      this.props.onBuffering(event.nativeEvent)
    }
  }

  _onError (event) {
    if (this.props.onError) {
      this.props.onError(event.nativeEvent)
    }
  }

  _onProgress (event) {
    if (this.props.onProgress) {
      this.props.onProgress(event.nativeEvent)
    }
  }

  _onEnded (event) {
    if (this.props.onEnded) {
      this.props.onEnded(event.nativeEvent)
    }
  }

  _onStopped (event) {
    this.setNativeProps({ paused: true })
    if (this.props.onStopped) {
      this.props.onStopped(event.nativeEvent)
    }
  }

  _onPaused (event) {
    if (this.props.onPaused) {
      this.props.onPaused(event.nativeEvent)
    }
  }

  _onPlaying (event) {
    if (this.props.onPlaying) {
      this.props.onPlaying(event.nativeEvent)
    }
  }

  render () {
    const {
      source
    } = this.props
    source.initOptions = source.initOptions || []
    // repeat the input media
    const nativeProps = Object.assign({}, this.props)
    Object.assign(nativeProps, {
      style: [styles.base, nativeProps.style],
      source: source,
      onError: this._onError,
      onProgress: this._onProgress,
      onEnded: this._onEnded,
      onPlaying: this._onPlaying,
      onPaused: this._onPaused,
      onStopped: this._onStopped,
      onBuffering: this._onBuffering
    })

    return (
      <RCTVLCPlayer ref={this._assignRoot} {...nativeProps} />
    )
  }
}

VLCPlayer.propTypes = {
  /* Wrapper component */
  source: PropTypes.object,

  /* Native only */
  paused: PropTypes.bool,
  seek: PropTypes.number,
  rate: PropTypes.number,
  snapshotPath: PropTypes.string,

  onPaused: PropTypes.func,
  onStopped: PropTypes.func,
  onBuffering: PropTypes.func,
  onPlaying: PropTypes.func,
  onEnded: PropTypes.func,
  onError: PropTypes.func,
  onProgress: PropTypes.func,

  /* Required by react-native */
  scaleX: PropTypes.number,
  scaleY: PropTypes.number,
  translateX: PropTypes.number,
  translateY: PropTypes.number,
  rotation: PropTypes.number,
  ...View.propTypes
}

const styles = StyleSheet.create({
  base: {
    overflow: 'hidden'
  }
})
const RCTVLCPlayer = requireNativeComponent('RCTVLCPlayer', VLCPlayer)
