require_relative 'JobsPodspecKit'

Pod::Spec.new do |spec|
  support_context = JobsPodspecKitForJobsEnglishLearning.build_support_context(podspec_dir: __dir__, support_dir: 'Support', support_dependencies: [])
  spec.name = 'JobsEnglishLearning'
  spec.version = '1.0.0'
  spec.summary = 'Jobs language learning module.'
  spec.description = 'Independent Swift language learning with Jobs chainable UIKit APIs.'
  spec.homepage = 'https://example.local/JobsEnglishLearning'
  spec.license = { :type => 'MIT' }
  spec.author = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform = :ios, '18.0'
  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.source = { :path => '.' }
  spec.source_files = 'Core/**/*.swift'
  spec.resource_bundles = { 'JobsEnglishLearningResources' => ['Resource/**/*'] }
  spec.frameworks = ['UIKit', 'AVFoundation', 'Foundation', 'Translation', 'SwiftUI', 'SafariServices']
  spec.libraries = 'sqlite3'
  spec.dependency 'JobsLanguageCore'
  spec.dependency 'JobsByUIKit'
  spec.dependency 'JobsSwiftDSL'
  spec.dependency 'JobsSwiftBaseDefines'
  spec.dependency 'SnapKit'
  spec.dependency 'GKNavigationBarSwift'
  JobsPodspecKitForJobsEnglishLearning.add_support_subspec(spec, support_context)
  JobsPodspecKitForJobsEnglishLearning.apply_standard_exclude_files(spec)
  JobsPodspecKitForJobsEnglishLearning.apply_standard_xcconfig(spec)
end
