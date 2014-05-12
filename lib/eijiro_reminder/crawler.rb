# encoding: UTF-8
require 'open-uri'
require 'nokogiri'
require 'net/http'

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
      params = {MAIL_ADDRESS: @id, PASSWORD: @password, login: 'ログインする'}
      resp = Net::HTTP.post_form(URI.parse(login_url), params)
      begin
        @cookie = resp['Set-Cookie'].split(';').grep(/eowpuser=/)[0] || nil
      rescue
        @cookie = nil
      end
    end

    def fetch_allpages
    end

    def fetch_page(page_url)
      login unless @cookie;
      open(page_url, 'Cookie' => @cookie).read
    rescue
      # TODO add Logging mechanism
      nil
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /(.*)_url$/
        path_keyword = $1
        return @paths[path_keyword]['proto'] + \
          File.join(@base_url, @paths[path_keyword]['path'])
      end

      super
    end

    class Parser
    end
  end
end
