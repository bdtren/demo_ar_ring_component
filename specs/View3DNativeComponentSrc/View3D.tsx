import React, {useMemo} from 'react';
import View3DNativeComponent, {
  NativeView3DProps,
} from '../View3DNativeComponent';
import {Dimensions, Image, ImageSourcePropType, Platform} from 'react-native';
const {width: screenWidth, height: screenHeight} = Dimensions.get('window');

export interface View3DProps
  extends Omit<
    NativeView3DProps,
    'source'| 'x' | 'y' | 'z' | 'angleDeg' | 'contentWidth' | 'contentHeight' | 'reactWidth' | 'reactHeight'
  > {
  source: ImageSourcePropType;
  renderProps?: {
    x?: number;
    y?: number;
    z?: number;
    angleDeg?: number;
    width?: number;
    height?: number;
  };
}
export const View3D: React.FC<View3DProps> = props => {
const sourceUri = useMemo(() => {
    let { uri } = Image.resolveAssetSource(props.source as ImageSourcePropType);
    return uri;
  }, [props.source]);

  return (
    <View3DNativeComponent
      {...props}
      source={sourceUri}
      x={props.renderProps?.x ?? 0}
      y={props.renderProps?.y ?? 0}
      z={props.renderProps?.z ?? 0}
      angleDeg={props.renderProps?.angleDeg ?? 0}
      contentWidth={props.renderProps?.width ?? 0}
      contentHeight={props.renderProps?.height ?? 0}
      reactWidth={screenWidth}
      reactHeight={screenHeight}
    />
  );
};

export default View3D;
