require 'xcodeproj'
require 'pathname'

root = Pathname.new(__dir__).parent
project_path = root.join('JobsLanguageLearning.xcodeproj')
abort '工程已存在，请直接维护现有工程。' if project_path.exist?
project = Xcodeproj::Project.new(project_path.to_s)
target = project.new_target(:application, 'JobsLanguageLearning', :ios, '18.0')
group = project.main_group.new_group('JobsLanguageLearning', 'JobsLanguageLearning')
Dir.glob(root.join('JobsLanguageLearning/**/*.swift').to_s).sort.each do |file|
  ref = group.new_file(Pathname.new(file).relative_path_from(root.join('JobsLanguageLearning')).to_s)
  target.source_build_phase.add_file_reference(ref)
end
resources = group.new_group('Resource', 'Resource')
Dir.glob(root.join('JobsLanguageLearning/Resource/*').to_s).sort.each do |file|
  next if File.basename(file) == 'Info.plist'
  target.resources_build_phase.add_file_reference(resources.new_file(File.basename(file)))
end
resources.new_file('Info.plist')
# 手动依赖入口只展示文件，不参与 target 或自动构建流程。
pod_script_name = '【MacOS@Xcode】🫘打开终端运行Pod Install.command'
pod_scripts = project.main_group.new_group('ScriptsByPods', 'ScriptsByPods')
pod_package = pod_scripts.new_group(pod_script_name, pod_script_name)
pod_script = pod_package.new_file(pod_script_name)
pod_script.last_known_file_type = 'text.script.sh'
pod_package.new_file('README.md')
# 自动 IPA 脚本包只展示文件，实际执行由主 App 最后构建阶段负责。
ipa_script_name = 'save_device_ipa_after_build.command'
dev_scripts = project.main_group.new_group('ScriptsByDevTools', 'ScriptsByDevTools')
ipa_package = dev_scripts.new_group(ipa_script_name, ipa_script_name)
ipa_script = ipa_package.new_file(ipa_script_name)
ipa_script.last_known_file_type = 'text.script.sh'
ipa_package.new_file('README.md')
# 主 App 自动保存本次真机 / 模拟器 IPA，build/ 专用于一次性产物。
ipa_phase = target.new_shell_script_build_phase('Save Build IPA')
ipa_phase.shell_path = '/bin/zsh'
ipa_phase.shell_script = '/bin/zsh "${SRCROOT}/ScriptsByDevTools/save_device_ipa_after_build.command/save_device_ipa_after_build.command"' + "\n"
ipa_phase.input_paths = ['$(SRCROOT)/ScriptsByDevTools/save_device_ipa_after_build.command/save_device_ipa_after_build.command']
ipa_phase.output_paths = ['$(SRCROOT)/build']
ipa_phase.always_out_of_date = '1'
ipa_phase.show_env_vars_in_log = '0'
target.build_configurations.each do |config|
  config.build_settings.merge!({
    'PRODUCT_BUNDLE_IDENTIFIER' => 'com.jobs.JobsLanguageLearning',
    'INFOPLIST_FILE' => 'JobsLanguageLearning/Resource/Info.plist',
    'SWIFT_VERSION' => '5.0',
    'TARGETED_DEVICE_FAMILY' => '1,2',
    'MARKETING_VERSION' => '1.0.0',
    'CURRENT_PROJECT_VERSION' => '1',
    'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO',
    'CODE_SIGN_STYLE' => 'Automatic',
    'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  })
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.set_launch_target(target)
scheme.save_as(project_path.to_s, 'JobsLanguageLearning', true)
[['JobsLanguageLearningTests', :unit_test_bundle, 'Tests'],
 ['JobsLanguageLearningUITests', :ui_test_bundle, 'UITests']].each do |name, type, folder|
  test_target = project.new_target(type, name, :ios, '18.0')
  test_target.add_dependency(target)
  test_group = project.main_group.new_group(folder, folder)
  Dir.glob(root.join(folder, '*.swift').to_s).sort.each do |file|
    test_target.source_build_phase.add_file_reference(test_group.new_file(File.basename(file)))
  end
  test_target.build_configurations.each do |config|
    config.build_settings.merge!({
      'PRODUCT_BUNDLE_IDENTIFIER' => "com.jobs.#{name}",
      'GENERATE_INFOPLIST_FILE' => 'YES',
      'SWIFT_VERSION' => '5.0',
      'TARGETED_DEVICE_FAMILY' => '1,2',
      'CODE_SIGN_STYLE' => 'Automatic'
    })
    if type == :unit_test_bundle
      config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/JobsLanguageLearning.app/JobsLanguageLearning'
      config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
    else
      config.build_settings['TEST_TARGET_NAME'] = 'JobsLanguageLearning'
    end
  end
  test_scheme = Xcodeproj::XCScheme.new
  test_scheme.add_build_target(target)
  test_scheme.add_build_target(test_target)
  test_scheme.set_launch_target(target)
  test_scheme.add_test_target(test_target)
  test_scheme.save_as(project_path.to_s, name, true)
end
project.save
puts project_path
