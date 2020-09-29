module.exports = {
  dependency: {
    platforms: {
      android: {
        packageInstance: "new OrientationPackage()",
      },
      ios: {
        project: "iOS/RCTOrientation.xcodeproj",
      },
    },
  },
};
