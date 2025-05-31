//
//  UICustomSceneView.m
//  demo_ring2
//
//  Created by Macos on 31/5/25.
//

#import "UICustomSceneView.h"

@interface UICustomSceneView ()

@property (nonatomic, strong) SCNView  *sceneView;
@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNNode  *ringNode;

@end

@implementation UICustomSceneView

+ (Class)layerClass {
    // Matches `override class var layerClass: AnyClass { return CALayer.self }`
    return [CALayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScene];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupScene];
    }
    return self;
}

- (void)setupScene {
    // — Create SCNView as a subview, match autoresizing to fill this view —
    self.sceneView = [[SCNView alloc] initWithFrame:self.bounds];
    self.sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sceneView.backgroundColor = [UIColor clearColor];
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.allowsCameraControl = NO;
    [self addSubview:self.sceneView];

    // — Create empty SCNScene and assign it —
    self.scene = [SCNScene scene];
    self.sceneView.scene = self.scene;

    // — Set up camera node at (0, 0, 2) with zNear=0.1, zFar=100 —
    SCNCamera *camera = [SCNCamera camera];
    camera.zNear = 0.1;
    camera.zFar  = 100.0;

    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera  = camera;
    cameraNode.position = SCNVector3Make(0.0f, 0.0f, 2.0f);
    [self.scene.rootNode addChildNode:cameraNode];

    // — Load the ring model immediately —
  [self loadModel:@"dot"];
}

- (void)loadModel:(NSString *)name {
  NSLog(@"Attempting to load %@.obj...", name);
    NSArray<NSString *> *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"obj" inDirectory:nil];
    NSLog(@"Bundle paths: %@", paths);

    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
    if (!path) {
        NSLog(@"ERROR: Could not find %@.obj file", name);
        return;
    }
    NSLog(@"Found %@.obj at path: %@", name, path);

    NSError *loadError = nil;
    SCNScene *ringScene = [SCNScene sceneWithURL:[NSURL fileURLWithPath:path]
                                        options:nil
                                          error:&loadError];
    if (loadError) {
        NSLog(@"ERROR loading dot.obj file: %@", loadError);
        return;
    }

    // In Swift you did `ringNode = ringScene.rootNode.childNodes.first`
    self.ringNode = ringScene.rootNode.childNodes.firstObject;
    if (self.ringNode) {
        // Scale the ring down (0.01, 0.01, 0.01)
        float initialScale = 0.01f;
        self.ringNode.scale = SCNVector3Make(initialScale, initialScale, initialScale);

        // Position at origin
        self.ringNode.position = SCNVector3Make(0.0f, 0.0f, 0.0f);

        // Attach to main scene
        [self.scene.rootNode addChildNode:self.ringNode];
        NSLog(@"Ring model loaded successfully");
    }
}

/// Equivalent to Swift’s:
///     public func updatePose(x:y:z:angleDeg:width:height:)
- (void)updatePoseWithX:(float)x
                      y:(float)y
                      z:(float)z
                angleDeg:(float)angleDeg
                   width:(float)width
                  height:(float)height
{
    if (!self.ringNode) {
        return;
    }

    // Convert screen (pixel) coords to SceneKit coords, same math as Swift:
    CGFloat screenX = ((CGFloat)x / UIScreen.mainScreen.bounds.size.width) - 0.5f;
    CGFloat screenY = 1.15f - (((CGFloat)y / UIScreen.mainScreen.bounds.size.height) * 2.3f);
    self.ringNode.position = SCNVector3Make(screenX, screenY, 0.0f);

    // Update Z‐rotation in radians
    float angleRad = angleDeg * (M_PI / 180.0f);
    SCNVector3 currentEuler = self.ringNode.eulerAngles;
    currentEuler.z = angleRad;
    self.ringNode.eulerAngles = currentEuler;

    // Scale based on `width/15000` (same as Swift)
    float scaleFactor = width / 2300.0f;
    self.ringNode.scale = SCNVector3Make(scaleFactor, scaleFactor, scaleFactor);
}

- (void)dealloc {
    // If using ARC, these will be released automatically.
    // We nil them out for clarity—mirrors Swift‘s setting to nil in `deinit`.
    _sceneView = nil;
    _scene     = nil;
    _ringNode  = nil;
}

@end
