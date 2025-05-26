package com.video.player.video_player

import android.media.*
import android.media.MediaCodecList.ALL_CODECS
import android.os.Build
import android.util.Log
import android.view.Surface
import androidx.annotation.RequiresApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.nio.ByteBuffer
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit
import kotlin.math.max


class VideoPlayer(private val surface: Surface) {
    private lateinit var videoDecoder: MediaCodec
    private lateinit var audioDecoder: MediaCodec
    private var extractor: MediaExtractor = MediaExtractor()
    private lateinit var audioTrack: AudioTrack

    fun setDataSource(url: String) {
//        extractor.setDataSource(url)
    }

    val videoPlayer = this

    @RequiresApi(Build.VERSION_CODES.S)
    suspend fun prepare(): MediaFormat {
        val res = withContext(Dispatchers.IO) {
            extractor.setDataSource("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")
            val format = extractor.getTrackFormat(0)
            Log.d("prepare thread", "${Thread.currentThread().name}")

            CoroutineScope(Dispatchers.Main).launch {
                start()
            }

            return@withContext format
        }


        return res
    }


    fun updateSurface(surface: Surface) {
        val format = extractor.getTrackFormat(0)
        videoDecoder.configure(format, surface, null, 0)
    }

    data class SampleData(val buffer: ByteBuffer, val size: Int, val sampleTime: Long)

    val videoDeque = ArrayDeque<SampleData>()
    val audioDeque = ArrayDeque<SampleData>()

    @RequiresApi(Build.VERSION_CODES.P)
    fun readSampleData(sampleData: SampleData) {
        extractor.selectTrack(0)
        extractor.selectTrack(1)
        while (true) {

            if (extractor.sampleTrackIndex == 0) {

                val buffer = ByteBuffer.allocate(extractor.sampleSize.toInt());
                val nbuffer = ByteBuffer.allocate(extractor.sampleSize.toInt());
                nbuffer.put(buffer)
            }

            if (!extractor.advance()) {
                return
            }
        }
    }


    @RequiresApi(Build.VERSION_CODES.S)
    suspend fun start() = withContext(Dispatchers.IO) {
        for (index in 0 until extractor.trackCount) {
            val format: MediaFormat = extractor.getTrackFormat(index)
            Log.d("media format", format.toString())
            val mime = format.getString(MediaFormat.KEY_MIME)
            val codecName = MediaCodecList(ALL_CODECS).findDecoderForFormat(format)
            if (mime?.startsWith("video/") == true) {
                videoDecoder = MediaCodec.createByCodecName(codecName)
                videoDecoder.configure(format, surface, null, 0)
            } else {
                audioDecoder = MediaCodec.createByCodecName(codecName)
                audioDecoder.configure(format, null, null, 0)
            }
        }

        videoDecoder.start()
        audioDecoder.start()

        val format = extractor.getTrackFormat(1)
        val rate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)

        val bufferSize = AudioTrack.getMinBufferSize(
            rate,
            AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        audioTrack = AudioTrack(
            AudioManager.STREAM_MUSIC,
            rate, AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT, bufferSize,
            AudioTrack.MODE_STREAM
        )
        audioTrack.play()

        val newBufferInfo = MediaCodec.BufferInfo()
        extractor.selectTrack(0)
        extractor.selectTrack(1)

        var prev = System.currentTimeMillis()
        var firstStampTime: Long? = null
        var c: CompletableFuture<Void>? = null


        while (true) {
            if (extractor.sampleTrackIndex == 0) {
                var readCost: Long = 0
                videoDecoder.dequeueInputBuffer(1000L).let { index ->
                    if (index >= 0) {
                        val inputBuffer = videoDecoder.getInputBuffer(index)
                        if (inputBuffer != null) {
                            val start = System.currentTimeMillis();
                            val sampleSize = extractor.readSampleData(inputBuffer, 0)
                            readCost = System.currentTimeMillis() - start;
                            if (sampleSize > 0) {
                                videoDecoder.queueInputBuffer(index, 0, sampleSize, extractor.sampleTime, 0)
                            }
                        }
                    }
                }
                videoDecoder.dequeueOutputBuffer(newBufferInfo, 100000L).let { index ->
                    if (index >= 0) {
                        val currentTimestamp = System.currentTimeMillis()
                        if (firstStampTime == null) {
                            firstStampTime = currentTimestamp - (newBufferInfo.presentationTimeUs / 1000L)
                        }
                        val delayMills = max(0, firstStampTime!! + (newBufferInfo.presentationTimeUs / 1000L) - currentTimestamp)

                        CompletableFuture.supplyAsync(
                            {
                                videoDecoder.releaseOutputBuffer(index, true)
                            },
                            CompletableFuture.delayedExecutor(delayMills, TimeUnit.MILLISECONDS)
                        )
                    }
                }
                val current = System.currentTimeMillis()

                Log.d("current track", "frame cost ${current - prev} ms read cost : $readCost")
                prev = current

            }

            if (extractor.sampleTrackIndex == 1) {
                audioDecoder.dequeueInputBuffer(1000L).let { index ->
                    if (index >= 0) {
                        val inputBuffer = audioDecoder.getInputBuffer(index)
                        if (inputBuffer != null) {
                            val sampleSize = extractor.readSampleData(inputBuffer, 0)
                            if (sampleSize > 0) {
                                audioDecoder.queueInputBuffer(index, 0, sampleSize, extractor.sampleTime, 0)
                            }
                        }
                    }
                }

                audioDecoder.dequeueOutputBuffer(newBufferInfo, 100000L).let { index ->
                    if (index >= 0) {
                        Log.d(
                            "audio info",
                            "offset: ${newBufferInfo.offset}, ${newBufferInfo.size}， time: ${newBufferInfo.presentationTimeUs} "
                        )
                        val buffer: ByteBuffer? = audioDecoder.getOutputBuffer(index)
                        val chunk = ByteArray(newBufferInfo.size)
                        buffer?.get(chunk)
                        audioDecoder.releaseOutputBuffer(index, false)

                        if (c == null) {
                            c = CompletableFuture.supplyAsync(
                                {
                                    audioTrack.write(
                                        chunk, newBufferInfo.offset, newBufferInfo.offset
                                                + newBufferInfo.size
                                    )
                                    return@supplyAsync null
                                }
                            )
                        }else{
                            c = c!!.thenApplyAsync {
                                audioTrack.write(
                                    chunk, newBufferInfo.offset, newBufferInfo.offset
                                            + newBufferInfo.size
                                )
                                return@thenApplyAsync  null
                            }
                        }
                    }
                }
            }
            if (!extractor.advance()) {
                extractor.seekTo(0, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
                extractor.advance()
                firstStampTime = null;
                Log.d("dequeue", "breaker")
//                break
            }
        }
    }
}

class AudioDecoderCallBack(val mediaExtractor: MediaExtractor, val track: Int, val videoPlayer: VideoPlayer) :
    MediaCodec.Callback() {

    var inputCount = 0

    init {

    }

    override fun onInputBufferAvailable(codec: MediaCodec, index: Int) {
        mediaExtractor.selectTrack(track)
        val sampleSize = mediaExtractor.readSampleData(codec.getInputBuffer(index)!!, 0)
        if (sampleSize > 0) {
            Log.d("VideoOutputBuffer count", "audio input count${++inputCount}")
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
//        val buffer: ByteBuffer? = codec.getOutputBuffer(index)
//        val chunk = ByteArray(info.size)
//        buffer?.get(chunk)
//        audioTrack.write(
//            chunk, info.offset, info.offset
//                    + info.size
//        )
        codec.releaseOutputBuffer(index, false)

    }

    override fun onError(p0: MediaCodec, p1: MediaCodec.CodecException) {
    }

    override fun onOutputFormatChanged(p0: MediaCodec, p1: MediaFormat) {
    }
}