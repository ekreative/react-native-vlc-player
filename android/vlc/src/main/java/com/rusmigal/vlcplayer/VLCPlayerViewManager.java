package com.rusmigal.vlcplayer;


import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

import javax.annotation.Nullable;

public class VLCPlayerViewManager extends ViewGroupManager<VLCPlayerView> {

    public static final String REACT_CLASS = "RCTVLCPlayer";

    public static final String PROP_SOURCE = "source";
    public static final String PROP_SEEK = "seek";
    public static final String PROP_PAUSED = "paused";
    public static final String PROP_VOLUME = "volume";
    public static final String PROP_RESIZE = "resize";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected VLCPlayerView createViewInstance(ThemedReactContext reactContext) {
        return new VLCPlayerView(reactContext);
    }

    @Override
    public void onDropViewInstance(VLCPlayerView view) {
        super.onDropViewInstance(view);
        view.onDropViewInstance();
    }

    @Nullable
    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder builder = MapBuilder.builder();
        for (VLCPlayerView.Events event : VLCPlayerView.Events.values()) {
            builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
        }
        return builder.build();
    }

    @ReactProp(name = PROP_SOURCE)
    public void setPath(final VLCPlayerView playerView, ReadableMap map) {
        String path = map.getString("uri");
        boolean autoPlay = map.getBoolean("autoplay");
        playerView.setAutoPlay(autoPlay);
        playerView.setFilePath(path);
    }

    @ReactProp(name = PROP_VOLUME)
    public void setVolume(final VLCPlayerView playerView, float volume) {
        playerView.setVolume((int) (300 * volume));
    }

    @ReactProp(name = PROP_SEEK)
    public void setSeek(final VLCPlayerView playerView, float seek) {
        playerView.seek(seek);
    }

    @ReactProp(name = PROP_PAUSED)
    public void setPaused(final VLCPlayerView playerView, boolean paused) {
        playerView.setPaused(paused);
    }

    @ReactProp(name = PROP_RESIZE)
    public void resize(final VLCPlayerView playerView, ReadableMap resize) {
        int width = resize.getInt("width");
        int height = resize.getInt("height");
        playerView.changeSurfaceLayout(width, height);
    }
}
