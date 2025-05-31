package com.demo_ring2.handlandmarksframeprocessor

import android.util.Log
import com.demo_ring2.HandLandmarkerHolder
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy

class HandLandmarksFrameProcessorPlugin(proxy: VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {
  override fun callback(frame: Frame, arguments: Map<String, Any>?): Any {

    if (HandLandmarkerHolder.handLandmarker == null) {
      return "HandLandmarker is not initialized" // Return early if initialization failed
    }

    if (frame.imageProxy == null) {
      return "HandLandmarker No data" // Return early if initialization failed
    }

    try {
      // Convert the frame to an MPImage
      val mpImage: MPImage = BitmapImageBuilder(frame.imageProxy?.toBitmap()).build()
      HandLandmarkerHolder.frameWidth = frame.width.toFloat()
      HandLandmarkerHolder.frameHeight = frame.height.toFloat()

      // Get the timestamp from the frame
      val timestamp = frame.timestamp ?: System.currentTimeMillis()

      // Call detectAsync with MPImage and timestamp
      HandLandmarkerHolder.handLandmarker?.detectAsync(mpImage, timestamp)

      return "Frame processed successfully"
    } catch (e: Exception) {
      e.printStackTrace()
      Log.e("HandLandmarksFrameProcessor", "Error processing frame: ${e.message}")
      return "Error processing frame: ${e.message}"
    }

  }
}