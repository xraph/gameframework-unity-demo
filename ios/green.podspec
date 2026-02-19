Pod::Spec.new do |s|
  s.name             = 'green'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter game package powered by Game Framework'
  s.description      = <<-DESC
A Flutter plugin package that wraps gameframework for game engine integration.
                       DESC
  s.homepage         = 'https://github.com/yourusername/green'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
  
  # Unity Framework - built from Unity project and synced via 'game sync unity --platform ios'
  # This framework is specific to this game and must be included for publishing
  s.ios.vendored_frameworks = 'UnityFramework.framework'
  
  # Preserve Unity Data folder structure (critical for IL2CPP runtime)
  s.preserve_paths = 'UnityFramework.framework/Data'
  
  # Ensure framework is properly linked
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
