import VisionCamera
import MediaPipeTasksVision

@objc(HandLandmarksFrameProcessorPlugin)
public class HandLandmarksFrameProcessorPlugin: FrameProcessorPlugin {
  public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable: Any]! = [:]) {
    super.init(proxy: proxy, options: options)
  }
  
  public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
    //    let srcBuffer = frame.buffer
    //    let orientation = frame.orientation
    
    // 1) Extract the CVPixelBuffer from the CMSampleBuffer:
    guard let sampleBuffer = frame.buffer as? CMSampleBuffer,
          let srcBuffer    = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("🔴 Could not get CVPixelBuffer from frame.buffer")
      return nil
    }
    
    // 2) Conversion helper YUV → BGRA
    func makeBGRA(_ src: CVPixelBuffer) -> CVPixelBuffer? {
      let width  = CVPixelBufferGetWidth(src)
      let height = CVPixelBufferGetHeight(src)
      var dst: CVPixelBuffer?
      let attrs: CFDictionary = [
        kCVPixelBufferPixelFormatTypeKey:   kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey:             width,
        kCVPixelBufferHeightKey:            height
      ] as CFDictionary
      
      let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width, height,
        kCVPixelFormatType_32BGRA,
        attrs,
        &dst
      )
      guard status == kCVReturnSuccess, let dstBuffer = dst else {
        print("▶️ Failed to create BGRA buffer: \(status)")
        return nil
      }
      
      let ciImage   = CIImage(cvPixelBuffer: src)
      let ciContext = CIContext()
      ciContext.render(ciImage, to: dstBuffer)
      return dstBuffer
    }
    
    // 3) Grab or convert to BGRA
    let bufferForDetection: CVPixelBuffer
    let pixFormat = CVPixelBufferGetPixelFormatType(srcBuffer)
    if pixFormat == kCVPixelFormatType_32BGRA {
      bufferForDetection = srcBuffer
    } else if let converted = makeBGRA(srcBuffer) {
      bufferForDetection = converted
    } else {
      print("🔴 Could not convert pixel buffer to BGRA.")
      return nil
    }
    
    // 4) Perform the detection
    guard let handLandmarker = HandLandmarkerHolder.shared.getHandLandmarker() else {
      print("HandLandmarker is not initialized.")
      return nil
    }
    
    
    do {
      HandLandmarkerHolder.shared.frameWidth = frame.width;
      HandLandmarkerHolder.shared.frameHeight = frame.height;
      let mpImage = try MPImage(pixelBuffer: bufferForDetection,
                                orientation: frame.orientation)
      try handLandmarker.detectAsync(
        image: mpImage,
        timestampInMilliseconds: Int(frame.timestamp)
      )
      return "Frame processed successfully"
    } catch {
      print("handLandmarker detect error: \(error.localizedDescription)")
      return nil
    }
  }
}
