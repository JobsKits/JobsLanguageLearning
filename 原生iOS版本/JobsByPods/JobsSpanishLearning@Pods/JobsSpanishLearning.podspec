require_relative 'JobsPodspecKit'

Pod::Spec.new do |spec|
  support_context = JobsPodspecKitForJobsSpanishLearning.build_support_context(podspec_dir: __dir__, support_dir: 'Support', support_dependencies: [])
  spec.name = 'JobsSpanishLearning'
  spec.version = '1.0.0'
  spec.summary = 'Spanish syllable combination lesson data for Jobs language learning.'
  spec.description = 'Spanish vowel and consonant letter combinations with spelling notes.'
  spec.homepage = 'https://example.local/JobsSpanishLearning'
  spec.license = { :type => 'MIT' }
  spec.author = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform = :ios, '18.0'
  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.source = { :path => '.' }
  spec.source_files = 'Core/**/*.swift'
  spec.frameworks = ['Foundation']
  spec.dependency 'JobsLanguageCore'
  JobsPodspecKitForJobsSpanishLearning.add_support_subspec(spec, support_context)
  JobsPodspecKitForJobsSpanishLearning.apply_standard_exclude_files(spec)
  JobsPodspecKitForJobsSpanishLearning.apply_standard_xcconfig(spec)
end
