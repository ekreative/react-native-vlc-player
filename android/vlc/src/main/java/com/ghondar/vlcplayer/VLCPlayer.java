package com.ghondar.vlcplayer;

import android.widget.Toast;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

import org.videolan.libvlc.LibVLC;

public class VLCPlayer extends ReactContextBaseJavaModule {

    private ReactApplicationContext context;
    private LibVLC mLibVLC = null;

    public VLCPlayer(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;

        try {
            mLibVLC = new LibVLC();
        } catch(IllegalStateException e) {
            Toast.makeText(reactContext,
                    "Error initializing the libVLC multimedia framework!",
                    Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public String getName() {
        return "VLCPlayer";
    }

//    @ReactMethod
//    public void play(String path) {
//
//    }

}
