package com.demo_ring2

import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker

class HandLandmarkerHolder {
    companion object {
        var handLandmarker: HandLandmarker? = null
        var frameWidth = 0f
        var frameHeight = 0f
    }
}
