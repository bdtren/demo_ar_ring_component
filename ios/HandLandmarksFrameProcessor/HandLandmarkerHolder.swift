//
//  HandLandmarkerHolder.swift
//  demo_ring2
//
//  Created by Macos on 30/5/25.
//

import MediaPipeTasksVision

class HandLandmarkerHolder {
  static let shared = HandLandmarkerHolder()
  
  private(set) var handLandmarker: HandLandmarker?
  public var frameWidth: Int = 0;
  public var frameHeight: Int = 0;
  
  private init() {} // Private initializer to enforce singleton pattern
  
  func initializeHandLandmarker(with options: HandLandmarkerOptions) throws {
    self.handLandmarker = try HandLandmarker(options: options)
  }
  
  func clearHandLandmarker() {
    self.handLandmarker = nil
  }
  
  func getHandLandmarker() -> HandLandmarker? {
    return self.handLandmarker
  }
}
