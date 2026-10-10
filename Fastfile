# Fastlane configuration for iFunSchool v2 (iOS, tvOS, macOS)
# Used exclusively for generating App Store screenshots via Fastlane Snapshot & UI Automation

ENV["DEVELOPER_DIR"] = "/Applications/Xcode.app/Contents/Developer"

default_platform :ios

desc "Generate iOS App Store screenshots"
lane :ios_screenshots do
  snapshot(scheme: "iFunSchool v2UITests")
end

desc "Generate tvOS App Store screenshots"
lane :tvos_screenshots do
  snapshot(
    scheme: "iFunSchool v2 tvOSUITests",
    devices: ["Apple TV 4K (3rd generation)"],
    sdk: "appletvsimulator",
    output_directory: "./fastlane/screenshots/tvos"
  )
end

desc "Generate macOS App Store screenshots"
lane :mac_screenshots do
  sh("cd .. && xcodebuild -project iFunSchool.xcodeproj -scheme 'iFunSchool v2 macOSUITests' -destination 'platform=macOS' test")
end

desc "Generate screenshots across all platforms (iOS, tvOS, macOS)"
lane :all_screenshots do
  ios_screenshots
  tvos_screenshots
  mac_screenshots
end
