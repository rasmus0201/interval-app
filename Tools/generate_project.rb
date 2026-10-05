require "xcodeproj"

project = Xcodeproj::Project.new("Interval.xcodeproj")
project.root_object.attributes["LastSwiftUpdateCheck"] = "2630"
project.root_object.attributes["LastUpgradeCheck"] = "2630"

app_target = project.new_target(:application, "Interval", :ios, "17.0")
test_target = project.new_target(:unit_test_bundle, "IntervalTests", :ios, "17.0")
test_target.add_dependency(app_target)

app_group = project.main_group.new_group("Interval", "Interval")
test_group = project.main_group.new_group("IntervalTests", "IntervalTests")

source_paths = Dir.glob("Interval/*.swift").sort
resource_paths = ["Interval/Assets.xcassets"] + Dir.glob("Interval/Sounds/*.wav").sort
test_paths = Dir.glob("IntervalTests/*.swift").sort

source_paths.each do |path|
  reference = app_group.new_file(File.basename(path))
  app_target.source_build_phase.add_file_reference(reference)
end

resource_paths.each do |path|
  reference = app_group.new_file(path.delete_prefix("Interval/"))
  app_target.resources_build_phase.add_file_reference(reference)
end

test_paths.each do |path|
  reference = test_group.new_file(File.basename(path))
  test_target.source_build_phase.add_file_reference(reference)
end

app_target.build_configurations.each do |configuration|
  configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.bundsgaard.interval"
  configuration.build_settings["INFOPLIST_FILE"] = "Interval/Info.plist"
  configuration.build_settings["GENERATE_INFOPLIST_FILE"] = "NO"
  configuration.build_settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
  configuration.build_settings["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"] = "AccentColor"
  configuration.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  configuration.build_settings["DEVELOPMENT_TEAM"] = ""
  configuration.build_settings["SWIFT_VERSION"] = "5.0"
  configuration.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
end

test_target.build_configurations.each do |configuration|
  configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.bundsgaard.interval.tests"
  configuration.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  configuration.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  configuration.build_settings["DEVELOPMENT_TEAM"] = ""
  configuration.build_settings["SWIFT_VERSION"] = "5.0"
  configuration.build_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/Interval.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Interval"
  configuration.build_settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
end

project.save
