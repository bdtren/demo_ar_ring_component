import React, {useEffect} from 'react';
import {Platform, StyleSheet, Text, View, Dimensions} from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCameraFormat,
  useCameraPermission,
  useFrameProcessor,
} from 'react-native-vision-camera';
import {
  useDerivedValue,
  useSharedValue,
  withRepeat,
  withTiming,
  runOnJS,
  useAnimatedReaction,
} from 'react-native-reanimated';
import {handLandmarks} from '../../specs/NativeHandLandmarksSrc/HandLandmarks';
import NativeHandLandmarks, {
  handLandmarksEmitter,
} from '../../specs/NativeHandLandmarks';
import {
  IHandDetectedResult,
  IHandLandmark,
} from '../../specs/NativeHandLandmarksSrc/NativeHandLandmarks.types';
import {Canvas, Line, Circle} from '@shopify/react-native-skia';
import View3D from '../../specs/View3DNativeComponentSrc/View3D';
const {width: screenWidth, height: screenHeight} = Dimensions.get('window');

console.log('NativeHandLandmarks', NativeHandLandmarks.getValue());

const CameraView = () => {
  const landmarks = useSharedValue<IHandLandmark[][] | undefined>(undefined);
  const device = useCameraDevice('back');
  const format = useCameraFormat(device, [
    {videoResolution: {width: screenWidth, height: screenHeight}},
    {videoAspectRatio: screenHeight / screenWidth},
  ]);
  const {hasPermission, requestPermission} = useCameraPermission();

  const [ringPos, setRingPos] = React.useState({
    x: 0,
    y: 0,
    z: 0,
    angleDeg: 0,
    width: 80,
    height: 100,
  });

  // Create derived values for each point's coordinates
  const point13x = useDerivedValue(() => {
    const data = landmarks.value?.[0]?.[13];
    return (data?.x ?? -1) * screenWidth;
  }, [landmarks]);
  const point13y = useDerivedValue(() => {
    return (landmarks.value?.[0]?.[13]?.y ?? -1) * screenHeight;
  }, [landmarks]);
  const point14x = useDerivedValue(() => {
    const data = landmarks.value?.[0]?.[14];
    return (data?.x ?? -1) * screenWidth;
  }, [landmarks]);
  const point14y = useDerivedValue(() => {
    return (landmarks.value?.[0]?.[14]?.y ?? -1) * screenHeight;
  }, [landmarks]);

  useEffect(() => {
    NativeHandLandmarks.initModel();
    // setTimeout(() => {
    //   setXData(39);
    //   console.log('Model updateddd');
    // }, 5000);

    // Set up the event listener to listen for hand landmarks detection results
    const subscription = handLandmarksEmitter.addListener(
      'onHandLandmarksDetected',
      (event: IHandDetectedResult) => {
        // Update the landmarks shared value to paint them on the screen
        landmarks.value = event.landmarks;
        if (landmarks.value?.length) {
          const indexMCP = landmarks.value[0][5]; // Index finger MCP
          const pinkyMCP = landmarks.value[0][17]; // Pinky finger MCP
          // Draw perpendicular line at 60% of the distance between ring finger MCP and PIP
          const mcp = landmarks.value[0][13]; // Ring finger MCP
          const pip = landmarks.value[0][14]; // Ring finger PIP
          if (mcp && pip) {
            const indexX = (indexMCP.x ?? 0) * screenWidth;
            const indexY = (indexMCP.y ?? 0) * screenHeight;
            const pinkyX = (pinkyMCP.x ?? 0) * screenWidth;
            const pinkyY = (pinkyMCP.y ?? 0) * screenHeight;

            // Calculate hand width
            const handWidth =
              Math.sqrt(
                (pinkyX - indexX) * (pinkyX - indexX) +
                  (pinkyY - indexY) * (pinkyY - indexY),
              ) * 0.9;

            // Calculate base points
            const x1 = (mcp.x ?? 0) * screenWidth;
            const y1 = (mcp.y ?? 0) * screenHeight;
            const x2 = (pip.x ?? 0) * screenWidth;
            const y2 = (pip.y ?? 0) * screenHeight;

            // Calculate 60% point
            const x60 = x1 + (x2 - x1) * 0.65;
            const y60 = y1 + (y2 - y1) * 0.65;

            // Calculate perpendicular vector
            const dx = x2 - x1;
            const dy = y2 - y1;
            const length = Math.sqrt(dx * dx + dy * dy);
            const perpX = -dy / length;
            const perpY = dx / length;

            // Use hand width to scale the perpendicular line length
            const perpLength = handWidth * 0.2; // 20% of hand width

            // Calculate end points of perpendicular line
            const perpX1 = x60 - perpX * perpLength;
            const perpY1 = y60 - perpY * perpLength;
            const perpX2 = x60 + perpX * perpLength;
            const perpY2 = y60 + perpY * perpLength;

            // Calculate line angle in degrees
            const lineAngleRad = Math.atan2(perpY2 - perpY1, perpX2 - perpX1);

            // Pass screen coordinates directly
            const x = x60; // Screen x coordinate
            const y = y60; // Screen y coordinate
            const z = -3.0; // Keep the same depth
            setRingPos({
              x: x,
              y: y,
              z: z,
              angleDeg: -(lineAngleRad * 180) / Math.PI, // Convert radians to degrees
              width: perpLength, // 20% of hand width
              height: perpLength, // 20% of hand width
            });
          }
        }
      },
    );

    // Clean up the event listener when the component is unmounted
    return () => {
      subscription?.remove();
    };
  }, []);

  useEffect(() => {
    // Request camera permission on component mount
    requestPermission().catch(error => console.log(error));
  }, [requestPermission]);

  const frameProcessor = useFrameProcessor(frame => {
    'worklet';
    // Process the frame using the 'handLandmarks' function
    const data = handLandmarks(frame);
  }, []);

  const renderLandmarks = () => {
    return (
      <Canvas
        style={[StyleSheet.absoluteFill, {backgroundColor: 'transparent'}]}>
        <Circle key={`point-0`} cx={point13x} cy={point13y} r={8} color="transparent" />
        <Circle key={`point-1`} cx={point14x} cy={point14y} r={8} color="transparent" />
      </Canvas>
    );
  };

  if (!hasPermission) {
    // Display message if camera permission is not granted
    return <Text>No permission</Text>;
  }

  if (device == null) {
    // Display message if no camera device is available
    return <Text>No device</Text>;
  }

  return (
    <View style={StyleSheet.absoluteFill}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        // resizeMode='contain'
        isActive={true}
        outputOrientation="device"
        frameProcessor={frameProcessor}
        format={format}
        // fps={30}
        // video={false}
        // audio={false}
        // pixelFormat={Platform.OS === 'ios' ? 'rgb' : 'yuv'}
      />
      {renderLandmarks()}
      <View3D
        source={require('../assets/models/ring_3d.obj')}
        renderProps={{
          x: ringPos.x,
          y: ringPos.y,
          z: ringPos.z,
          angleDeg: ringPos.angleDeg,
          width: ringPos.width,
          height: ringPos.height,
        }}
        style={[StyleSheet.absoluteFill, {backgroundColor: 'transparent'}]}
      />
    </View>
  );
};

export default CameraView;
