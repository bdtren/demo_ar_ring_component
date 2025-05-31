//
//  RCTView3D.m
//  demo_ring2
//
//  Created by Macos on 31/5/25.
//

#import "RCTView3D.h"

#import <react/renderer/components/NativeDemoRingSpec/ComponentDescriptors.h>
#import <react/renderer/components/NativeDemoRingSpec/EventEmitters.h>
#import <react/renderer/components/NativeDemoRingSpec/Props.h>
#import <react/renderer/components/NativeDemoRingSpec/RCTComponentViewHelpers.h>
#import "UICustomSceneView.h"

using namespace facebook::react;

@interface RCTView3D() <RCTView3DViewProtocol>
@end

@implementation RCTView3D {
  UICustomSceneView *_scene;
  NSString * _lastFileName;
  
}

- (instancetype)init {
  if (self = [super init]) {
    [self setupScene];
  }
  return self;
}

-(void)setupScene {
  _scene = [[UICustomSceneView alloc] initWithFrame:self.bounds];
  if (_scene) {
    _scene.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_scene];
    [NSLayoutConstraint activateConstraints:@[
      [_scene.topAnchor constraintEqualToAnchor:self.topAnchor],
      [_scene.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
      [_scene.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
      [_scene.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
  }
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
  const auto &currProps = *std::static_pointer_cast<const View3DProps>(_props);
  const auto &newProps = *std::static_pointer_cast<const View3DProps>(props);
  
  // Handle source prop
  if (!newProps.source.empty() && newProps.source != currProps.source) {
    NSString *urlString = [NSString stringWithCString:newProps.source.c_str()
                                             encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *fileNameWithExtension = url.lastPathComponent;
    NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
    if (_lastFileName != fileName) {
      [_scene loadModel:fileName];
      _lastFileName = fileName;
    }
  }
  
  if (newProps.x != currProps.x ||
      newProps.y != currProps.y ||
      newProps.z != currProps.z ||
      newProps.angleDeg != currProps.angleDeg ||
      newProps.contentWidth != currProps.contentWidth ||
      newProps.contentHeight != currProps.contentHeight
      ) {
    // Optional: log/handle other props
    float x = static_cast<float>(newProps.x);
    float y = static_cast<float>(newProps.y);
    float z = static_cast<float>(newProps.z);
    float angle = static_cast<float>(newProps.angleDeg);
    float contentWidth  = static_cast<float>(newProps.contentWidth);
    float contentHeight = static_cast<float>(newProps.contentHeight);
    float reactWidth    = static_cast<float>(newProps.reactWidth);
    float reactHeight   = static_cast<float>(newProps.reactHeight);
    
    [_scene updatePoseWithX:x
                          y:y
                          z:z
                   angleDeg:angle
                      width:contentWidth
                     height:contentHeight];
  }
  
  
  [super updateProps:props oldProps:oldProps];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  //  _scene.frame = self.bounds;
}

// Required for Fabric component registration
+ (facebook::react::ComponentDescriptorProvider)componentDescriptorProvider {
  return facebook::react::concreteComponentDescriptorProvider<View3DComponentDescriptor>();
}
@end
