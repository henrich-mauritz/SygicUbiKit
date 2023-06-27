rm -R "/Users/henrichmauritz/Documents/Sygic/Packages/Output/SygicUbiKit.xcframework"

xcodebuild archive \
            -project SygicUbiKit.xcodeproj \
            -scheme SygicUbiKit \
            -destination "generic/platform=iOS Simulator" \
            -archivePath "archives/MyScheme-iOS-sim" \
            -allowProvisioningUpdates \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES


xcodebuild archive \
            -project SygicUbiKit.xcodeproj \
            -scheme SygicUbiKit \
            -destination "generic/platform=iOS" \
            -archivePath "archives/MyScheme-iOS" \
            -allowProvisioningUpdates \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework -framework "/Users/henrichmauritz/Documents/Sygic/Packages/SygicUbiKit/archives/MyScheme-iOS.xcarchive/Products/Library/Frameworks/SygicUbiKit.framework" -debug-symbols "/Users/henrichmauritz/Documents/Sygic/Packages/SygicUbiKit/archives/MyScheme-iOS.xcarchive/dSYMs/SygicUbiKit.framework.dSYM" -framework "/Users/henrichmauritz/Documents/Sygic/Packages/SygicUbiKit/archives/MyScheme-iOS-sim.xcarchive/Products/Library/Frameworks/SygicUbiKit.framework" -debug-symbols "/Users/henrichmauritz/Documents/Sygic/Packages/SygicUbiKit/archives/MyScheme-iOS-sim.xcarchive/dSYMs/SygicUbiKit.framework.dSYM" -output "/Users/henrichmauritz/Documents/Sygic/Packages/Output/SygicUbiKit.xcframework"
