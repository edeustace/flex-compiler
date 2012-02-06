# Introduction
A simple gem for building flex applications and libraries. It generates compc and mxmlc commands, based on sensible defaults and by inspecting the project structure for others. The goal is that the build command you need to pass in needs only one argument - the path to the flex sdk. All the other params are generated or can be overridden.

# Installation
    gem install flex-compiler
# Usage
    FlexCompiler.compc #will look for a file flex-compiler-config.yml
    FlexCompiler.compc "my-config.yml" #will load my-config.yml
    FlexCompiler.compc {:flex_home => "/path/to/flex/sdk" } #you can pass in a hash too

## Options
* flex_home
* src_dir (default: src)
* output_dir (default: bin)
* output_name (default: the name of the folder that contains the project)

