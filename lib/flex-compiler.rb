require "flex-compiler/version"
require "flex-compiler/compc_options"
require "yaml"

module FlexCompiler
 
  # generates a compc command and execute it.
  # 
  # The options argument can be a hash or a yaml file
  # containing the following values: 
  #  required
  #   - flex_home: the folder that contains the flex sdk
  #  optional
  #   - output_folder: (default: "bin")
  #   - output_name: (default: the name of the folder that contains the project)
  #   - src_dir: (default: "src")
  #   - locale_dir: (default: "locale")
  #   - libs: (no default TODO: add default)
  #
  # * *Args*    :
  #   - +options+ -> either a hash or a string pointing to a yml file. 
  # * *Returns* :
  #   - the output from compc 
  # * *Raises* :
  #   - +ArgumentError+ -> if any value is nil or negative
  #
  def self.compc( options  = nil)

    puts "options: #{options} #{options.class}"

    if( options.nil? )
      options = "flex-compiler-config.yml"
    end


    if( options.class == "Hash")
      puts "hash"
      opts = options
    elsif( options.class.to_s == "String" )
      puts "loading yaml config.."
      yml = YAML.load_file( options )
      opts = Hash.new
      opts[:flex_home] = yml["flex_home"] unless yml["flex_home"].nil?
      opts[:src_dir] = yml["src_dir"] unless yml["src_dir"].nil?
      opts[:locale_dir] = yml["locale_dir"] unless yml["locale_dir"].nil?
      opts[:output_name] = yml["output_name"] unless yml["output_name"].nil?
      opts[:output_folder] = yml["output_folder"] unless yml["output_folder"].nil?
      opts[:libs] = yml["libs"] unless yml["libs"].nil?
      opts[:test_mode] = yml["test_mode"] unless yml["test_mode"].nil?
    end
   
    compc = Compc.new( CompcOptions.new opts )
    compc.build
  end



  class Compc


    def initialize(options)
        @options = options
    end

    def build
      compc = "#{@options.flex_home}\\bin\\compc.exe"
      puts "compc path: #{compc}"
      sources = "-source-path #{src_dir}"
      puts "locale_dir: #{locale_dir}"
      if( File.exists? locale_dir )
        locale_string = "-locale #{discover_locale}"
        include_bundles = "-include-resource-bundles #{discover_rb}"
        sources += " #{add_locale_to_source_path}"
      end

      args = [locale_string,
              include_bundles,
              include_assets,
              include_stylesheets,
              framework_library_paths,
              lib_paths,
              sources,
              classes,
              output
              ]
      command = "\"#{compc}\" #{args.join(' ')}"
      
      puts "final command "
      puts "#{command}"
      puts "--"

      if( @options.test_mode )
        return command
      end
      result = `#{command}`
      
      puts result
    end

    private

    def output
       "-output=\"#{output_folder}/#{output_name}.swc\""
    end

    def output_folder
      @options.output_folder
    end

    def output_name 
      @options.output_name
    end

    def src_dir
      @options.src_dir
    end
    
    def locale_dir
      @options.locale_dir
    end

    def libs; @options.libs; end


    def classes
      files = Dir["#{src_dir}/**/*.{as,mxml}"]

      if files.nil? || files.empty?
        return ""
      end

      out = "-include-classes "

      files.map! { |f|
        f.gsub!("src/", "")
        f.gsub!("/", ".")
        f.gsub!(".as", "")
        f.gsub!(".mxml", "")
        f
      }

      "#{out} #{files.join ' '}"
    end

    # create the locale argument by inspecting the contents of the locale folder.
    # @return a locale string - eg: "en_US,de_DE"
    def discover_locale
      puts "locale option : #{locale_dir}"
      locales = Dir["#{locale_dir}/*"]
      puts "locales: #{locales}"
      locales.map! { |e| File.basename(e) }
      locales.join(" ")
    end

    def discover_rb
      locales = Dir["#{locale_dir}/*"]
      raise "can't find locales folders" if locales.nil? || locales.length == 0
      props = Dir["#{locales[0]}/*.properties"]
      props.map! { |e| File.basename(e, ".*")}
      props.join(' ')
    end

    def add_locale_to_source_path
      locales = Dir["#{locale_dir}/*"]
      locales.join(" ")
    end

    def include_stylesheets
      name_paths = get_name_paths "css", "-include-file"
      if( name_paths.empty? )
        return ""
      end
      name_paths
    end
    
    def include_assets
      name_paths = get_name_paths "jpg,jpeg,png,gif", "-include-file"
      if( name_paths.empty? )
        return ""
      end
      name_paths
    end

    def get_name_paths( types, directive )

      assets = Dir["#{src_dir}/**/*.{#{types}}"]

      if assets.nil? || assets.empty?
        return ""
      end

      name_paths = assets.map{ |e| NamePath.new(e)}

      output = ""
      name_paths.each{ |np| output << "#{directive} #{np.name_path} " }
      output
    end

    def framework_library_paths
      home = @options.flex_home.gsub("\\", "/")
      puts "home: #{home}"
      frameworks_swcs = Dir["#{home}/frameworks/libs/**/*.swc"]

      if frameworks_swcs.nil? || frameworks_swcs.empty?
        raise "Error: can't find framework swcs"
      end

      directive = "-external-library-path+="
      output = ""
      frameworks_swcs.each{ |swc| output << "#{directive}\"#{swc}\" "}
      output
    end

    def lib_paths

      if( libs.nil? || libs.empty? )
        return ""
      end

      
      output = ""
      libs.each{ |l| 
        puts "l: #{l}"
        if( l.end_with? "swc")
          #its a swc add it directly
          output << "-external-library-path+=#{l} "
        else
          puts "inspecting libs folder"
          #its a folder add all the swcs in the folder
          swcs = Dir["#{l}/**/*.swc"]
          swcs.each{ |swc|
            output << "-external-library-path+=#{swc} "
          }
        end
      }
      output
    end
  end

  class NamePath

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def name 
      File.basename(@path)
    end

    def name_path
      "#{name} #{path}"
    end
  end

  
   
  
end
