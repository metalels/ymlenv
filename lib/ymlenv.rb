require "ymlenv/version"

module Ymlenv
  @options = {debug: false, json: false, symborize: true, overwrite: false}

  class << self
    def options
      @options
    end

    def convert_body
      @options[:body] = File.read(@options[:file]) if define_file?
      ENV.each_pair do |ek, ev|
        @options[:body] = @options[:body].gsub(/\$[{]?#{ek}[}]?/, ev)
      end
    end

    def load_yaml
      require "yaml"
      symbolize_all_keys YAML.load(@options[:body])
    end

    def symbolize_all_keys(obj)
      return obj unless enable_symborize
      case obj.class.to_s
      when 'Hash'
        obj.keys.each do |key|
          obj[(key.to_sym rescue key) || key] = symbolize_all_keys(obj.delete(key))
        end
        obj
      when 'Array'
        obj.map! do |elem|
          symbolize_all_keys elem
        end
        obj
      else
        obj
      end
    end

    def exec_with_format
      convert_body

      if @options[:json]
        require 'json'
        load_yaml.to_json
      else
        if write_to_file?
          File.write @options[:file], @options[:body]
          "You yaml file #{@options[:file]} has been overwritten."
        else
          @options[:body]
        end
      end
    end

    def define_file?
      !@options[:file].nil?
    end

    def write_to_file?
      define_file? && @options[:overwrite]
    end

    def enable_symborize
      @options[:symborize]
    end

    def debug
      @options[:debug]
    end
  end
end
