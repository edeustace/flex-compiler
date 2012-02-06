require 'flex-compiler'
describe FlexCompiler do
  it "takes flex_home" do

=begin	
    FlexCompiler.compc({
    :test_mode => true,
    :flex_home => "C:\\Program Files (x86)\\Adobe\\Adobe Flash Builder 4.5\\sdks\\3.4.1.l.c",
    :src_dir => "test/simple-lib/src",
    :output_name => "simple-lib",
    :locale_dir => "test/simple-lib/locale",
    :libs => "test/simple-lib/libs,utilities-testing-specific.swc"
  })
=end
    FlexCompiler.compc("test/simple-lib/flex-compiler-config.yml")
  end


end