const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

  const {
    resolver: { assetExts }
  } = getDefaultConfig();
/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
    resolver: {
        assetExts: [...assetExts, 'obj'],
    }
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
