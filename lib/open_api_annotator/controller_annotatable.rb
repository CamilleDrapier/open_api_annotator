module OpenApiAnnotator
  module ControllerAnnotatable
    def endpoint_hash
      @endpoint_hash ||= {}
    end

    def validate_open_api_type!(type)
      @open_api_type_validator ||= TypeValidator.new
      @open_api_type_validator.validate!(type)
    end

    def endpoint(type)
      validate_open_api_type!(type)
      @last_endpoint = Endpoint.new(type)

    rescue ValidationError => e
      raise TypeError, <<~EOL
      #{e.message}

      Examples:
        - `[Project]`: means collection of Project
        - `Project`: means single resouce Project

      In your controller:

        endpoint [Project]
        def index
          # ... some code
        end
      EOL
    end

    def method_added(name)
      super
      return unless @last_endpoint

      endpoint = @last_endpoint
      @last_endpoint = nil

      return if private_method_defined?(name)

      endpoint_hash[name] = endpoint
    end
  end
end
