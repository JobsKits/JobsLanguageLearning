require_relative 'JobsPodspecKit'

Pod::Spec.new do |spec|
  support_context = JobsPodspecKitForJobsKoreanLearning.build_support_context(podspec_dir: __dir__, support_dir: 'Support', support_dependencies: [])
  spec.name = 'JobsKoreanLearning'
  spec.version = '1.0.0'
  spec.summary = 'Korean syllable block lesson data for Jobs language learning.'
  spec.description = 'Korean initial consonant, medial vowel and optional final consonant composition.'
  spec.homepage = 'https://example.local/JobsKoreanLearning'
  spec.license = { :type => 'MIT' }
  spec.author = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform = :ios, '18.0'
  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.source = { :path => '.' }
  spec.source_files = 'Core/**/*.swift'
  spec.frameworks = ['Foundation']
  spec.dependency 'JobsLanguageCore'
  JobsPodspecKitForJobsKoreanLearning.add_support_subspec(spec, support_context)
  JobsPodspecKitForJobsKoreanLearning.apply_standard_exclude_files(spec)
  JobsPodspecKitForJobsKoreanLearning.apply_standard_xcconfig(spec)
end
