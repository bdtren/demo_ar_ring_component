#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#if __has_include("demo_ring2/demo_ring2-Swift.h")
#import "demo_ring2/demo_ring2-Swift.h"
#else
#import "demo_ring2-Swift.h"
#endif

VISION_EXPORT_SWIFT_FRAME_PROCESSOR(HandLandmarksFrameProcessorPlugin, HandLandmarks)