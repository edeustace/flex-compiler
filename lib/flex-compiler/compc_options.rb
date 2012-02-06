  class CompcOptions
    # provides a set of defaults
    # a hash of options
    def initialize( options )
      @options = options
    end

    def output_folder
      @options[:output_folder] || "bin"
    end

    def output_name 
      @options[:output_name] || File.basename(Dir.pwd)
    end

    def src_dir
      @options[:src_dir] || "src"
    end
    
    def locale_dir
      @options[:locale_dir] || "locale"
    end

    def flex_home
      @options[:flex_home]
    end

    def test_mode
      @options[:test_mode] || false
    end
    
    def libs
      @options[:libs] || "libs"  
    end


  end