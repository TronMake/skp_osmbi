require 'sketchup.rb'
require 'extensions.rb'

module TRONMAKE
  module OSMBI
    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('OSMBI', 'tm_osmbi/main')
      ex.description = 'Open Street Map Building Importer.'
      ex.version     = '1.0.0'
      ex.copyright   = '© TronMake 2017'
      ex.creator     = 'TronMake Team'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  end # module BJTU
end # module APC
