package com.ghondar.vlcplayer;


import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

import javax.annotation.Nullable;

public class ReactPlayerViewManager extends SimpleViewManager<ReactPlayerView> {

    public static final String REACT_CLASS = "RCTPlayer";

    public static final String PROP_PATH = "path";
    public static final String PROP_AUTO_PLAY = "auto_play";
    public static final String PROP_SEEK = "seek";
    public static final String PROP_PAUSED = "paused";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected ReactPlayerView createViewInstance(ThemedReactContext reactContext) {
        return new ReactPlayerView(reactContext);
    }

    @Override
    public void onDropViewInstance(ReactPlayerView view) {
        super.onDropViewInstance(view);
        view.onDropViewInstance();
    }

    @Nullable
    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder builder = MapBuilder.builder();
        for (ReactPlayerView.Events event : ReactPlayerView.Events.values()) {
            builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
        }
        return builder.build();
    }

    @ReactProp(name = PROP_PATH)
    public void setPath(final ReactPlayerView playerView, String path) {
        playerView.setFilePath(path);
    }

    @ReactProp(name = PROP_AUTO_PLAY)
    public void setAutoPlay(final ReactPlayerView playerView, boolean autoPlay) {
        playerView.setAutoPlay(autoPlay);
    }

    @ReactProp(name = PROP_SEEK)
    public void setSeek(final ReactPlayerView playerView, float seek) {
        playerView.seekTo(Math.round(seek * 1000.0f));
    }

    @ReactProp(name = PROP_PAUSED)
    public void setPaused(final ReactPlayerView playerView, boolean paused) {
        playerView.setPaused(paused);
    }
}
