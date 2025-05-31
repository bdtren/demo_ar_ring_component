//
//  RCTNativeHandLandmarks.m
//  demo_ring2
//
//  Created by Macos on 30/5/25.
//

#import "RCTNativeHandLandmarks.h"

#if __has_include("demo_ring2/demo_ring2-Swift.h")
#import "demo_ring2/demo_ring2-Swift.h"
#else
#import "demo_ring2-Swift.h"
#endif

@implementation RCTNativeHandLandmarks

- (instancetype)init {
  if (self = [super init]) {
    // Pass self (the RCTEventEmitter) into Swift
    [RCTNativeHandLandmarksImpl.shared setEventEmitter:self];
  }
  return self;
}

+ (NSString *)moduleName { 
  return @"NativeHandLandmarks";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeHandLandmarksSpecJSI>(params);
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
    @"onHandLandmarksDetected",
    @"onHandLandmarksStatus",
    @"onHandLandmarksError"
  ];
}

// Indicate that this module does not require main thread setup
+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (nonnull NSString *)getValue {
  
  return [[RCTNativeHandLandmarksImpl shared] getValue];
}

- (void)initModel:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  
  NSNumber *num = [[RCTNativeHandLandmarksImpl shared] initModel];
  resolve(@(num != 0));
}

@end
