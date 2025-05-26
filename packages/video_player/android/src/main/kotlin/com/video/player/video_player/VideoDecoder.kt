package com.video.player.video_player

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import kotlin.math.max

class VideoDecoder(val mediaExtractor: MediaExtractor, val track: Int, val videoPlayer: VideoPlayer) : MediaCodec.Callback() {
    var firstStampTime: Long? = null

    fun reset() {
        firstStampTime = null
    }

    var inputCount = 0


    override fun onInputBufferAvailable(codec: MediaCodec, index: Int) {
            Log.d("onInput thread", "${Thread.currentThread().name}")

            mediaExtractor.selectTrack(track)

            val sampleSize = mediaExtractor.readSampleData(codec.getInputBuffer(index)!!, 0)
            if (sampleSize > 0) {
                Log.d("VideoOutputBuffer count", "video input count${++inputCount}")
                codec.queueInputBuffer(
                    index,
                    0,
                    sampleSize,
                    mediaExtractor.sampleTime,
                    if (mediaExtractor.advance()) 0 else MediaCodec.BUFFER_FLAG_END_OF_STREAM
                )
            }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onOutputBufferAvailable(codec: MediaCodec, index: Int, info: MediaCodec.BufferInfo) {
        Log.d("output thread", "${Thread.currentThread().name}")

        val currentTimestamp = System.currentTimeMillis()
        if (firstStampTime == null) {
            firstStampTime = currentTimestamp - (info.presentationTimeUs / 1000L)
            codec.releaseOutputBuffer(index, true)
        } else {
            val delayMills = max(0, firstStampTime!! + (info.presentationTimeUs / 1000L) - currentTimestamp)
            CompletableFuture.supplyAsync(
                {
                    codec.releaseOutputBuffer(index, true)
                },
                CompletableFuture.delayedExecutor(delayMills, TimeUnit.MILLISECONDS)
            )
        }
    }

    override fun onError(p0: MediaCodec, p1: MediaCodec.CodecException) {}

    override fun onOutputFormatChanged(p0: MediaCodec, p1: MediaFormat) {}
}