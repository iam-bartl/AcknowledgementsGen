Add Run Script build phase:

```
# Adjust input file path
INPUT=$PROJECT_DIR/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
# Adjust output file path
OUTPUT=$SRCROOT/$PRODUCT_NAME/acknowledgements.plist

if [ "${CONFIGURATION}" = "Release" || ! -f $OUTPUT]; then
  DIR=${BUILD_DIR%Build/*}/SourcePackages/checkouts/AcknowledgementsGen
  SDKROOT=(xcrun --sdk macosx --show-sdk-path)
  cd $DIR
  swift run -c release AcknowledgementsCLI $INPUT $OUTPUT
else
  echo "Skipping Acknowledgements"
fi

```
