# Introduction
A simple gem for building flex applications and libraries. 
It generates compc and mxmlc commands, based on sensible defaults and by inspecting the project structure for others. 
The goal being that the user only needs to pass in the bare minimum to get a successful compile command. 
For a library that means the only thing you need to pass in is the ````flex_home```` parameter, for an mxmlc you only need to pass in ````flex_home```` and ````application````.



# Installation
    gem install flex-compiler
# Usage
    require 'flex-compiler'
    FlexCompiler.compile #will look for a file flex-compiler-config.yml
    FlexCompiler.compile "my-config.yml" #will load my-config.yml
    FlexCompiler.compile {:flex_home => "/path/to/flex/sdk" } #you can pass in a hash too

## Options

You pass these options in with a Hash or with some yml.

* flex_home - (path to the flex sdk - it will use compc/mxmlc and all the framework libs from this path) (NO DEFAULT - must be provided)
* application - (default: nil - must be provided if you wish to compile with mxmlc)
* src_dir - (default: src)
* output_dir - (default: bin)
* output_name - (default: the name of the folder that contains the project)
* locale_dir - (default: locale)
* ignore_files - a list of files to ignore (default: []) This can be useful if someone is using an ````mx:Script```` or ````include```` directive in the source code
* test_mode - if true will only output the command, if false will output the command and execute it (default: false)

## Example Yaml
    flex_home: C:/Program Files (x86)/Adobe/Adobe Flash Builder 4.5/sdks/3.4.1.
    output_folder: blah
    locale_dir: src/locale
    libs:
      - ../mylib/bin/mylib.swc
      - ../myotherllib/bin/myotherlib.swc
  
## Limitations
There a currently alot of limitations:

* Only executes compc.exe or mxmlc.exe (aka won't run on mac/linux)
* Only allows a small set of parameters - the complete option set for these commands is far greater.
* There is no package management or dependency resolution a la flex-mojos, its just plain old add swc to libs


