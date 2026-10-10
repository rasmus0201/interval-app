require "xcodeproj"

project = Xcodeproj::Project.new("Interval.xcodeproj")
project.root_object.attributes["LastSwiftUpdateCheck"] = "2630"
project.root_object.attributes["LastUpgradeCheck"] = "2630"
project.root_object.known_regions = ["en", "da", "Base"]

app_target = project.new_target(:application, "Interval", :ios, "17.0")
test_target = project.new_target(:unit_test_bundle, "IntervalTests", :ios, "17.0")
widget_target = project.new_target(:app_extension, "IntervalWidgets", :ios, "17.0")
test_target.add_dependency(app_target)
app_target.add_dependency(widget_target)

embed_extensions = app_target.new_copy_files_build_phase("Embed App Extensions")
embed_extensions.dst_subfolder_spec = "13"
embed_extensions.add_file_reference(widget_target.product_reference, true)

app_group = project.main_group.new_group("Interval", "Interval")
test_group = project.main_group.new_group("IntervalTests", "IntervalTests")
widget_group = project.main_group.new_group("IntervalWidgets", "IntervalWidgets")

source_paths = Dir.glob("Interval/*.swift").sort
resource_paths = ["Interval/Assets.xcassets", "Interval/Localizable.xcstrings", "Interval/PrivacyInfo.xcprivacy"] + Dir.glob("Interval/Sounds/*.wav").sort
test_paths = Dir.glob("IntervalTests/*.swift").sort
widget_paths = Dir.glob("IntervalWidgets/*.swift").sort

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

widget_paths.each do |path|
  reference = widget_group.new_file(File.basename(path))
  widget_target.source_build_phase.add_file_reference(reference)
end

shared_activity_reference = widget_group.new_file("../Interval/WorkoutActivityAttributes.swift")
widget_target.source_build_phase.add_file_reference(shared_activity_reference)
shared_activity_content_reference = widget_group.new_file("../Interval/WorkoutLiveActivityContent.swift")
widget_target.source_build_phase.add_file_reference(shared_activity_content_reference)
shared_strings_reference = widget_group.new_file("../Interval/Localizable.xcstrings")
widget_target.resources_build_phase.add_file_reference(shared_strings_reference)

project.build_configurations.each do |configuration|
  configuration.build_settings["APP_BUNDLE_ID"] = "com.bundsgaard.kyclaro"
  configuration.build_settings["MARKETING_VERSION"] = "1.0"
  configuration.build_settings["CURRENT_PROJECT_VERSION"] = "1"
end

app_target.build_configurations.each do |configuration|
  configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "$(APP_BUNDLE_ID)"
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
  configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "$(APP_BUNDLE_ID).tests"
  configuration.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  configuration.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  configuration.build_settings["DEVELOPMENT_TEAM"] = ""
  configuration.build_settings["SWIFT_VERSION"] = "5.0"
  configuration.build_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/Interval.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Interval"
  configuration.build_settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
end

widget_target.build_configurations.each do |configuration|
  configuration.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "$(APP_BUNDLE_ID).widgets"
  configuration.build_settings["INFOPLIST_FILE"] = "IntervalWidgets/Info.plist"
  configuration.build_settings["GENERATE_INFOPLIST_FILE"] = "NO"
  configuration.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  configuration.build_settings["DEVELOPMENT_TEAM"] = ""
  configuration.build_settings["SWIFT_VERSION"] = "5.0"
  configuration.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
  configuration.build_settings["APPLICATION_EXTENSION_API_ONLY"] = "YES"
  configuration.build_settings["SKIP_INSTALL"] = "YES"
end

project.save
