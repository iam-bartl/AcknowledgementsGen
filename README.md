Acknowledgments list generator for third party SPM packages.

Generate a plist from one `Package.resolved` file:

```sh
swift run AcknowledgementsCLI --input path/to/Package.resolved --output path/to/acknowledgements.plist
```

Repeat `--input` to combine packages from several files. A package present in more than one file appears once, in the order of its first occurrence:

```sh
swift run AcknowledgementsCLI --input App/Package.resolved --input Extension/Package.resolved --output acknowledgements.plist
```

The original positional form remains available:

```sh
swift run AcknowledgementsCLI path/to/Package.resolved path/to/acknowledgements.plist
```

**Instalation**

- Add Run Script build phase:

```
# Adjust input file path
INPUT=$PROJECT_DIR/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
# Adjust output file path
OUTPUT=$SRCROOT/$PRODUCT_NAME/acknowledgements.plist

if [[ "${CONFIGURATION}" = "Release" || ! -f $OUTPUT ]]; then
  DIR=${BUILD_DIR%Build/*}/SourcePackages/checkouts/AcknowledgementsGen
  SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
  cd $DIR
  swift run -c release AcknowledgementsCLI $INPUT $OUTPUT
else
  echo "Skipping Acknowledgements"
fi

```

- Add to the inputs the same string as in `INPUT`
- Add to the outputs the same string as in `OUTPUT`
- Set `ENABLE_USER_SCRIPT_SANDBOXING` in project settings to `NO`
