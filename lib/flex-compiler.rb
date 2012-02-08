require "flex-compiler/version"
require "flex-compiler/compiler_options"
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
  def self.compile(options = nil)


    if( options.nil? )
      options = "flex-compiler-config.yml"
    end

    if( options.class == "Hash")
      opts = options
    elsif( options.class.to_s == "String" )
      yml = YAML.load_file( options )
      opts = Hash.new
      opts[:flex_home] = yml["flex_home"] unless yml["flex_home"].nil?
      opts[:src_dir] = yml["src_dir"] unless yml["src_dir"].nil?
      opts[:locale_dir] = yml["locale_dir"] unless yml["locale_dir"].nil?
      opts[:output_name] = yml["output_name"] unless yml["output_name"].nil?
      opts[:output_folder] = yml["output_folder"] unless yml["output_folder"].nil?
      opts[:libs] = yml["libs"] unless yml["libs"].nil?
      opts[:test_mode] = yml["test_mode"] unless yml["test_mode"].nil?
      opts[:application] = yml["application"] unless yml["application"].nil?
      opts[:ignore_files] = yml["ignore_files"] unless yml["ignore_files"].nil?
    end
   
    generator = CommandGenerator.new( CompilerOptions.new opts )
    command = generator.command

    puts "-- command --"
    puts command
    puts "-- end command --"

    if( opts[:test_mode] )
      return
    end

    result = `#{command}`
    puts result

    raise "errror executing process" unless $?.to_i == 0

  end



  class CommandGenerator

    PLAYER_GLOBAL = "playerglobal"

    def initialize(options)
        @options = options
    end

    def command

      bin = "#{@options.flex_home}\\bin\\"

      if( application.nil? )
        exe = "#{bin}compc.exe"
      else
        exe = "#{bin}mxmlc.exe"
      end

      sources = "-source-path #{src_dir}"
      if( File.exists? locale_dir )
        locale_string = "-locale #{discover_locale}"
        include_bundles = "-include-resource-bundles #{discover_rb}"
        sources += " #{locale_dir}/{locale}"
      end

      args = [
              source_path_overlap,
              locale_string,
              include_bundles,
              framework_library_paths,
              lib_paths,
              sources,
              dump_config,
              output
              ]
      
      if( compc? )
        #the ordering is important here:
        args = [include_stylesheets, include_assets, classes ] + args
      else
        args << "#{src_dir}/#{application}.mxml"
      end
        
      add_output_folder

      command = "\"#{exe}\" #{args.join(' ')}"
      command
    end

    private

    def add_output_folder
      FileUtils.mkdir_p output_folder unless File.exists? output_folder
    end


    def source_path_overlap
      "-allow-source-path-overlap=true"
    end

    def compc?; application.nil?; end

    def application; @options.application; end

    def output
      type = compc? ? "swc" : "swf"
      "-output=\"#{output_folder}/#{output_name}.#{type}\""
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

    def dump_config
      "-dump-config \"#{output_folder}/#{output_name}-config.xml\""
    end
    
    def classes
      files = Dir["#{src_dir}/**/*.{as,mxml}"]

      if files.nil? || files.empty?
        return ""
      end

      out = "-include-classes "

      class_array = []

      files.each{ |f| 
        if( !is_ignore_file(f) )
          f.gsub!("src/", "")
          f.gsub!("/", ".")
          f.gsub!(".as", "")
          f.gsub!(".mxml", "")
          class_array << f
        end
      }
    
      "#{out} #{class_array.join ' '}"
    end

    def is_ignore_file( file )
      
      ignore_files.each{ |ignore| 
        if( file.include? ignore )
          return true
        end
      }
      false
    end

    def ignore_files; @options.ignore_files; end

    # create the locale argument by inspecting the contents of the locale folder.
    # @return a locale string - eg: "en_US,de_DE"
    def discover_locale
      locales = Dir["#{locale_dir}/*"]
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

      name_paths = assets.map{ |e| NamePath.new(src_dir, e)}

      output = ""
      name_paths.each{ |np| output << "#{directive} #{np.name_path} " }
      output
    end

    def framework_library_paths
      home = @options.flex_home.gsub("\\", "/")
      frameworks_swcs = Dir["#{home}/frameworks/libs/**/*.swc"]

      if frameworks_swcs.nil? || frameworks_swcs.empty?
        raise "Error: can't find framework swcs"
      end

      directive = compc? ? "-external-library-path+=" : "-library-path+="
      output = ""
      frameworks_swcs.each{ |swc| 
        if( swc.include? "#{PLAYER_GLOBAL}.swc")
          output << "-external-library-path+=\"#{swc}\" "
        else
          output << "#{directive}\"#{swc}\" "
        end
      }
      output
    end

    def lib_paths

      if( libs.nil? || libs.empty? )
        return ""
      end

      output = ""
      libs.each{ |l| 
        if( l.end_with? "swc")
          f = File.open(l)

          #its a swc add it directly
          output << "-library-path+=\"#{l}\" "
        else
          #its a folder add all the swcs in the folder
          swcs = Dir["#{l}/**/*.swc"]
          swcs.each{ |swc|
            f = File.open(swc)
            output << "-library-path+=\"#{File.expand_path(f)}\" "
          }
        end
      }
      output
    end
  end

  class NamePath

    attr_reader :path

    def initialize(src_dir, path)
      @path = path
      @src_dir = src_dir
    end

    def name 
      
      src = starts_with?("/", @src_dir) ? @src_dir[1, @src_dir.length] : @src_dir
      out = path.gsub( "#{src}", "")
      puts "NamePath:name: #{out}, #{path}"
      out
    end
    
    def name_path
      "#{name} #{path}"
    end

    private
    def starts_with?(prefix, str)
      prefix = prefix.to_s
      str[0, prefix.length] == prefix
    end
  end

  
   
  
end
