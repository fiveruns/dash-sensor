module SensorPlugin
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    attr_accessor :instance

    def register(name, url, &block)
      Fiveruns::Dash.recipe(name, url, &block)
      Dash::Sensor::Engine.registered(name, url, self)
    end
  end
  
end