require 'settingslogic'

module Reviewbear
  class Config < Settingslogic
    source File.expand_path('../../config.yml', File.dirname(__FILE__))
  end
end
