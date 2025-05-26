package com.video.player.video_player

import android.media.MediaFormat
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.TextureRegistry.SurfaceProducer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking


const val TAG = "VideoPlayerController"

abstract class VideoPlayerController(binding: FlutterPlugin.FlutterPluginBinding) :  SurfaceProducer.Callback {

//        MediaPlayer.create(
//        binding.applicationContext,
//        "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4".toUri()
//    )
    private val handle: SurfaceProducer = binding.textureRegistry.createSurfaceProducer()
    private val player: VideoPlayer = VideoPlayer(handle.surface)
    val id: Long = handle.id()
    protected open var state: PlayerControllerState = PlayerControllerState(id)

    init {
        handle.setCallback(this)
    }

    override fun onSurfaceAvailable() {
        player.updateSurface(handle.surface)
        super.onSurfaceAvailable()
    }

    protected fun setDataSource(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url != null) {
            player.setDataSource(url)
            result.success(true)
            return
        }

        result.error("404", "Invalid URL", null)
    }

    @OptIn(DelicateCoroutinesApi::class)
    protected suspend fun initialize(result: MethodChannel.Result) {
        val format = player.prepare()
        val aspectRatio = format.getInteger(MediaFormat.KEY_WIDTH)/format.getInteger(MediaFormat.KEY_HEIGHT).toFloat();
        state = state.copy(initialized = true, aspectRatio = aspectRatio)
        result.success(true)
    }

    protected fun setAutoPlay(call: MethodCall, result: MethodChannel.Result) {
//        player.start()
        result.success(true)
    }

    protected fun start(result: MethodChannel.Result) {
//        player.start()
        result.success(true)
    }

    protected fun pause(result: MethodChannel.Result) {
//        player.pause()
        result.success(true)

    }

    protected fun stop(result: MethodChannel.Result) {
//        player.stop()
        result.success(true)
    }

    protected fun dispose(result: MethodChannel.Result) {
//        player.release()
        result.success(true)
    }

    protected fun setSpeed(call: MethodCall, result: MethodChannel.Result) {
//        player.speed = call.argument<Float>("speed")!!
//        state = state.copy(speed = player.speed)

        result.success(true)
    }

    protected fun seekTo(call: MethodCall, result: MethodChannel.Result) {
//        player.seekTo(call.argument<Int>("position")!!)
//        state = state.copy(seeking = true)
//        player.setOnSeekCompleteListener {
//            state = state.copy(seeking = false)
//        }
        result.success(true)

    }

    data class PlayerControllerState(
        val id: Long,
        val initialized: Boolean = false,
        val playing: Boolean = false,
        val loading: Boolean = false,
        val seeking: Boolean = false,
        val speed: Float = 1.0f,
        val aspectRatio: Float? = null,
        val duration: Long? = null,
        val position: Long? = null,
    )
}

class VideoPlayerControllerHandler(binding: FlutterPlugin.FlutterPluginBinding) :
    VideoPlayerController(binding), MethodCallHandler,
    EventChannel.StreamHandler {


    init {
        MethodChannel(binding.binaryMessenger, "method${TAG}#${id}").setMethodCallHandler(this)
        EventChannel(binding.binaryMessenger, "event${TAG}#${id}", JSONMethodCodec.INSTANCE).setStreamHandler(this)
    }

    override var state: PlayerControllerState
        get() = super.state
        set(value) {
            super.state = value
            Log.d("event:", "eventSink： ${eventSink != null}, event value:$value")
            eventSink?.success(
                mapOf(
                    "id" to value.id,
                    "initialized" to value.initialized,
                    "playing" to value.playing,
                    "loading" to value.loading,
                    "seeking" to value.seeking,
                    "speed" to value.speed.toDouble(),
                    "duration" to value.duration,
                    "position" to value.position,
                    "aspectRatio" to value.aspectRatio,
                )
            )

        }

    var eventSink: EventSink? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        CoroutineScope(Dispatchers.Main).launch {
            when (call.method) {
                "setDataSource" -> setDataSource(call, result)
                "initialize" -> initialize(result)
                "setAutoPlay" -> setAutoPlay(call, result)
                "start" -> start(result)
                "pause" -> pause(result)
                "stop" -> stop(result)
                "seekTo" -> seekTo(call, result)
                "setSpeed" -> setSpeed(call, result)
                "dispose" -> dispose(result)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}