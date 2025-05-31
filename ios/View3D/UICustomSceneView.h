//
//  UICustomSceneView.h
//  demo_ring2
//
//  Created by Macos on 31/5/25.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICustomSceneView : UIView

- (void)loadModel:(NSString *)name;

- (void)updatePoseWithX:(float)x
                      y:(float)y
                      z:(float)z
                angleDeg:(float)angleDeg
                   width:(float)width
                  height:(float)height;


@end

NS_ASSUME_NONNULL_END
