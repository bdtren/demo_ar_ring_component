//
//  RCTNativeHandLandmarks.h
//  demo_ring2
//
//  Created by Macos on 30/5/25.
//

#import <Foundation/Foundation.h>
#import <NativeDemoRingSpec/NativeDemoRingSpec.h>
#import "RCTDefaultReactNativeFactoryDelegate.h"
#import "RCTAppDelegate.h"
#import <ReactCommon/RCTTurboModuleWithJSIBindings.h>
#import <MediaPipeTasksVision/MediaPipeTasksVision.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTNativeHandLandmarks : RCTEventEmitter <NativeHandLandmarksSpec, RCTTurboModuleWithJSIBindings>

@end

NS_ASSUME_NONNULL_END
