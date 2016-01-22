Pod::Spec.new do |s|
s.name         = "MLInputDodger"
s.version      = "1.3.2"
s.summary      = "The best view dodger for inputting."

s.homepage     = 'https://github.com/molon/MLInputDodger'
s.license      = { :type => 'MIT'}
s.author       = { "molon" => "dudl@qq.com" }

s.source       = {
:git => "https://github.com/molon/MLInputDodger.git",
:tag => "#{s.version}"
}

s.platform     = :ios, '7.0'
s.public_header_files = 'Classes/**/*.h'
s.source_files  = 'Classes/**/*.{h,m}'
s.resource = "Classes/**/*.bundle"
s.requires_arc  = true

end
