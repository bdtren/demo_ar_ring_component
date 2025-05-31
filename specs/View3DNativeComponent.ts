import React, { useMemo } from 'react';
import {
  Image,
  type HostComponent,
  type ImageSourcePropType,
  type ViewProps,
} from 'react-native';
import type {
  BubblingEventHandler,
  Float,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

export interface NativeView3DProps extends ViewProps {
  source: string;
  onLoadStart?: BubblingEventHandler<{}>;
  onLoadEnd?: BubblingEventHandler<{}>;
  x?: Float;
  y?: Float;
  z?: Float;
  angleDeg?: Float;
  contentWidth?: Float;
  contentHeight?: Float;
  reactWidth?: Float;
  reactHeight?: Float;
}
export default codegenNativeComponent<NativeView3DProps>(
  'View3D',
) as HostComponent<NativeView3DProps>;
