package com.demo_ring2.modules.nativehandlandmarks

import android.util.Log
import com.demo_ring2.modules.NativeHandLandmarksSpec
import android.content.Context
import com.demo_ring2.HandLandmarkerHolder
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.OutputHandler
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.mrousavy.camera.frameprocessors.Frame

class NativeHandLandmarksModule(
    private val reactContext: ReactApplicationContext
): NativeHandLandmarksSpec(reactContext) {

    override fun getName() = NAME
    override fun getValue(): String {
        return "android hello"
    }

    companion object {
        const val NAME = "NativeHandLandmarks"
    }

    private fun sendEvent(eventName: String, params: WritableMap?) {
        reactApplicationContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
    }

    @ReactMethod
    override fun initModel(promise: Promise) {
        // Check if the HandLandmarker has already been initialized
        if (HandLandmarkerHolder.handLandmarker != null) {
            // Model is already initialized, send a status update to JavaScript
            val alreadyInitializedParams = Arguments.createMap()
            alreadyInitializedParams.putString("status", "Model already initialized")
            sendEvent("onHandLandmarksStatus", alreadyInitializedParams)
            promise.resolve(true)
            return
        }


        // Define the result listener
        val resultListener = OutputHandler.ResultListener { result: HandLandmarkerResult, inputImage: MPImage ->
            Log.d("HandLandmarksFrameProcessor", "Detected ${result.landmarks().size} hands")

            // Prepare the data to be sent back to JavaScript
            val landmarksArray = Arguments.createArray()

            for (handLandmarks in result.landmarks()) {
                val handMap = Arguments.createArray()
                for ((index, handmark) in handLandmarks.withIndex()) {
                    val landmarkMap = Arguments.createMap()
                    landmarkMap.putInt("keypoint", index)
                    // Transform coordinates to match camera orientation
                    landmarkMap.putDouble("x", 1.0 - handmark.y().toDouble())
                    //FIXME: front camera (1 - handmark.x().toDouble()) and back camera (handmark.x().toDouble()) are different in android
                    landmarkMap.putDouble("y", handmark.x().toDouble())
                    landmarkMap.putDouble("z", handmark.z().toDouble())
                    landmarkMap.putDouble("cameraWidth", HandLandmarkerHolder.frameWidth.toDouble())
                    landmarkMap.putDouble("cameraHeight", HandLandmarkerHolder.frameWidth.toDouble())
                    handMap.pushMap(landmarkMap)
                }
                landmarksArray.pushArray(handMap)
            }

            var handName = ""

            for(hand in result.handedness()) {
                for(handProps in hand){
                    handName = handProps.categoryName()
                }
            }

            if (handName.isNotEmpty()) {
                val params = Arguments.createMap()
                params.putArray("landmarks", landmarksArray)
                params.putString("hand", handName)
                // Send the landmarks data back to JavaScript
                sendEvent("onHandLandmarksDetected", params)
            }
        }

        // Initialize the Hand Landmarker
        try {
            val context: Context = reactApplicationContext
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("hand_landmarker.task")
                .build()

            val handLandmarkerOptions = HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setNumHands(1)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setResultListener(resultListener)
                .build()

            HandLandmarkerHolder.handLandmarker = HandLandmarker.createFromOptions(context, handLandmarkerOptions)

            // Send success event to JS
            val successParams = Arguments.createMap()
            successParams.putString("status", "Model initialized successfully")
            sendEvent("onHandLandmarksStatus", successParams)
            promise.resolve(true)

        } catch (e: Exception) {
            Log.e("HandLandmarksFrameProcessor", "Error initializing HandLandmarker", e)

            // Send error event to JS
            val errorParams = Arguments.createMap()
            errorParams.putString("error", e.message)
            sendEvent("onHandLandmarksError", errorParams)
        }
        promise.resolve(false)
    }

    override fun addListener(eventName: String?) { }

    override fun removeListeners(count: Double) { }
}