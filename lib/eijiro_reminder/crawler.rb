# encoding: UTF-8
require 'open-uri'
require 'nokogiri'
require 'sanitize'
require 'net/http'

module EijiroReminder
  class Crawler
    attr_accessor :base_url, :paths, :id, :password, :cookie, :parser

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
      # --------------------------------------
      # Definition of class instance variables
      # --------------------------------------
      class << self
        attr_accessor :wordbk_table_selector, :word_id_prefix, :tag_id_prefix
      end

      @wordbk_table_selector = 'table[data-resizable-columns-id=table-wordbk]'
      @word_id_prefix = 'word_text_'
      @tag_id_prefix = 'js_bkid_'

      # --------------------------------------
      # Definition of instance variables
      # --------------------------------------
      attr_accessor :html, :doc

      def initialize(html)
        @html = html
        @doc = Nokogiri::HTML(html)
      end

      def parse_word_and_tags()
        word_and_tags = {}
        words_with_ids = _get_words_with_id(@doc)
        tags_with_ids = _get_tags_from_ids(words_with_ids.keys)
        words_with_ids.keys.each do |id|
          word_and_tags[id] = {}
          word_and_tags[id]['word'] = words_with_ids[id]
          word_and_tags[id]['tags'] = tags_with_ids[id]
        end
        return word_and_tags
      end

      private

      def _get_words_with_id(doc)
        wordbk_table = doc.css(Parser.wordbk_table_selector)
        words_with_ids = {}
        wordbk_table.css("a[id^=#{Parser.word_id_prefix}]").each do |elm|
          id = _pick_id_from_word_text(elm.attr('id'))
          words_with_ids[id] = elm.text
        end
        return words_with_ids
      end

      def _get_tags_from_ids(ids)
        tags_with_ids = {}
        ids.each do |id|
          tags = []
          tag_spans = doc.css("td[id=#{Parser.tag_id_prefix}#{id}] span")
          tag_spans.each do |tag_span|
            tags << Sanitize.clean(tag_span.to_s)
          end
          tags_with_ids[id] = tags
        end
        return tags_with_ids
      end

      def _pick_id_from_word_text(word_text)
        word_text.match(/#{Parser.word_id_prefix}(\d+)/)
        return $1
      end
    end
  end
end
