//
//  NativeHandLandmarks.swift
//  demo_ring2
//
//  Created by Macos on 30/5/25.
//

import Foundation
import MediaPipeTasksVision
import React

@objc(RCTNativeHandLandmarksImpl)
class RCTNativeHandLandmarksImpl: NSObject {
  @objc public static var shared = RCTNativeHandLandmarksImpl()
  // a weak reference to the Obj-C emitter
  @objc public weak var eventEmitter: RCTEventEmitter?

  private var resultProcessor: HandLandmarkerResultProcessor?

  override init() {
    super.init()
  }

  @objc
  func getValue() -> String {
    return "hello ios"
  }

  @objc
  func initModel() -> NSNumber {
    guard let eventEmitter = self.eventEmitter else {
      return 0;
    }
    
    do {
      // Initialize the result processor and set it as the delegate
      resultProcessor = HandLandmarkerResultProcessor(eventEmitter: eventEmitter)

      // Initialize the Hand Landmarker
      let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task")

      let options = HandLandmarkerOptions()
      options.baseOptions.modelAssetPath = modelPath ?? "hand_landmarker.task"
      options.runningMode = .liveStream
      options.numHands = 1
      options.handLandmarkerLiveStreamDelegate = resultProcessor

      try HandLandmarkerHolder.shared.initializeHandLandmarker(with: options)

      // Send success event to JS
      print("NativeHandLandmarks initialized")
      return 1
    } catch {
      print("Error initializing NativeHandLandmarks: \(error.localizedDescription)")
    }
    return 0
  }

  private func sendErrorEvent(_ error: String) {
    let errorParams: [String: Any] = ["error": error]
    self.eventEmitter?.sendEvent(withName: "onNativeHandLandmarksError", body: errorParams)
  }
}

class HandLandmarkerResultProcessor: NSObject, HandLandmarkerLiveStreamDelegate {

  weak var eventEmitter: RCTEventEmitter?

  init(eventEmitter: RCTEventEmitter) {
    self.eventEmitter = eventEmitter
  }

  func handLandmarker(
    _ handLandmarker: HandLandmarker,
    didFinishDetection result: HandLandmarkerResult?,
    timestampInMilliseconds: Int,
    error: Error?
  ) {

    if let error = error {
      print("Error: \(error.localizedDescription)")
      eventEmitter?.sendEvent(
        withName: "onHandLandmarksError", body: ["error": error.localizedDescription])
      return
    }

    guard let result = result else {
      print("No result received.")
      return
    }

    // Prepare the data to be sent back to JavaScript
    let landmarksArray = NSMutableArray()

    for handLandmarks in result.landmarks {
      let handArray = NSMutableArray()
      for (index, handmark) in handLandmarks.enumerated() {
        let landmarkMap = NSMutableDictionary()
        landmarkMap["keypoint"] = index
        landmarkMap["x"] = 1.0 - handmark.y
        landmarkMap["y"] = handmark.x
        landmarkMap["z"] = handmark.z
        landmarkMap["cameraWidth"] = HandLandmarkerHolder.shared.frameWidth
        landmarkMap["cameraHeight"] = HandLandmarkerHolder.shared.frameHeight
        handArray.add(landmarkMap)
      }
      landmarksArray.add(handArray)
    }

    var handName = ""
    for hand in result.handedness {
      for (_, handProps) in hand.enumerated() {
        handName = handProps.categoryName ?? "Unknown"
      }
    }
    
    if (!handName.isEmpty) {
      let params: [String: Any] = ["landmarks": landmarksArray, "hand": handName]
      eventEmitter?.sendEvent(withName: "onHandLandmarksDetected", body: params)
    }
  }
}
