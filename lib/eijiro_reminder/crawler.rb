require 'open-uri'
require 'nokogiri'

module EijiroReminder
  class Crawler
    attr_accessor :base_url, :paths, :id, :password, :cookie

    def initialize(config_path: nil, base_url: nil, paths: nil,
                   id: nil, password: nil)
      if config_path
        config = YAML.load_file config_path
        base_url = config['base_url']
        paths = config['paths']
        id = config['id']
        password = config['password']
      end

      @base_url = base_url
      @paths = paths  
      @id = id
      @password = password
    end

    def login
    end

    def fetch_allpages
    end

    def fetch_page(page_url)
      open(page_url).read
    rescue 
      # TODO add Logging mechanism
      nil
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /(.*)_url$/
        path_keyword = $1
        return File.join(@base_url, @paths[path_keyword])
      end

      super
    end

    class Parser
    end
  end
end
