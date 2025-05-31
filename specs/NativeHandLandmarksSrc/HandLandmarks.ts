import { NativeEventEmitter, NativeModules } from 'react-native'
import { VisionCameraProxy, Frame } from 'react-native-vision-camera'

// const {HandLandmarks} = NativeModules;

// export const handLandmarksEmitter = new NativeEventEmitter(HandLandmarks);

// Initialize the frame processor plugin 'handLandmarks'
const handLandMarkPlugin = VisionCameraProxy.initFrameProcessorPlugin(
  'HandLandmarks',
  {},
);

// Create a worklet function 'handLandmarks' that will call the plugin function
export function handLandmarks(frame: Frame) {
  'worklet';
  if (handLandMarkPlugin == null) {
    // throw new Error('Failed to load Frame Processor Plugin!');
    console.error('Failed to load Frame Processor Plugin! Make sure you have linked the native module correctly.',)
    return;
  }
  return handLandMarkPlugin.call(frame);
}