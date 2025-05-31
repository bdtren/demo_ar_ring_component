import type {TurboModule} from 'react-native';
import {NativeEventEmitter, NativeModules, TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  getValue(): string;
  initModel(): Promise<boolean>;
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

const {NativeHandLandmarks} = NativeModules;
export const handLandmarksEmitter = new NativeEventEmitter(NativeHandLandmarks);

export default TurboModuleRegistry.getEnforcing<Spec>(
  'NativeHandLandmarks',
);