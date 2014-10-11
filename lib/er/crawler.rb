# encoding: UTF-8
require 'open-uri'
require 'net/http'

module Er
  class Crawler
    attr_accessor :base_url, :paths, :id, :password, :cookie, :parser

    def initialize(id: nil, password: nil, config_path: \
                   Rails.root.join('lib/config/er_crawler_config.yaml'))
      config = YAML.load_file config_path
      @base_url = config['base_url']
      @paths = config['paths']
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

    def fetch_and_parse_all_pages
      # returns an array of UrlContentsPair
      # wat stands for words_and_tags
      ucp_array = []
      wat = {}
      prev_wat = current_wat = nil
      p_index = 0
      while p_index += 1
        url = _wordbook_url_with_page_index(p_index)
        ucp = fetch_page(url) # ucp stands for Er::Crawler::UrlContentsPair
        current_wat = ucp.parsed_contents
        break if prev_wat != nil and prev_wat == current_wat
        ucp_array.push ucp
        prev_wat = current_wat
      end

      return ucp_array
    end

    def fetch_page(page_url)
      login unless @cookie
      contents = open(page_url, 'r:UTF-8', 'Cookie' => @cookie).read
      UrlContentsPair.new(page_url, contents)
    rescue
      # TODO add Logging mechanism
      nil
    end

    def save(page_url, words_and_tags)
      user = Er::User.find_by_email(@id)
      _store_parsed_items(user, page_url, words_and_tags)
    end

#    def parse_and_save(url_contents_pair)
#      user = Er::User.find_by_email(@id)
#      parser = Parser.new(url_contents_pair.page_contents)
#      word_and_tags = parser.parse_word_and_tags
#
#      _store_parsed_items(user, url_contents_pair.page_url, word_and_tags)
#    end

    class UrlContentsPair
      attr_accessor :page_url, :page_contents

      def initialize(page_url, page_contents)
        @page_url = page_url
        @page_contents = page_contents
      end

      def parsed_contents
        parser = Parser.new(@page_contents)
        words_and_tags = parser.parse_word_and_tags
        return words_and_tags
      end

      def ==(obj)
        (@page_url == obj.page_url) and (@page_contents == obj.page_contents)
      end
    end

    private

    def _wordbook_url_with_page_index(index_str)
      index_str = index_str.to_s # Just in case
      return wordbook_ej_url + '?page=' + index_str
    end

    def _store_parsed_items(user, page_url, words_and_tags)
      words_and_tags.each_key do |e_id|
        word = words_and_tags[e_id]['word']
        tags = words_and_tags[e_id]['tags']
        item_data = {e_id: e_id, name: word}
        item = Er::Item.find_or_create_by(item_data)
        item.update_attributes(item_data)

        items_user_data = {user_id: user.id, item_id: item.id,
                           wordbook_url: page_url}
        items_user = Er::ItemsUser.find_or_create_by(items_user_data)
        items_user.update_attributes(items_user_data)

        tags.each do |tag_name|
          tag = Er::Tag.find_by_tag(tag_name)
          if tag
            items_users_tag_data = {items_user_id: items_user.id,
                                    tag_id: tag.id,
                                    registration_date: Time.now}
            items_users_tag = Er::ItemsUsersTag.find_or_create_by(
              items_users_tag_data)
            items_users_tag.update_attributes(items_users_tag_data)
          end
        end
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /(.*)_url$/
        path_keyword = $1
        return @paths[path_keyword]['proto'] + \
          File.join(@base_url, @paths[path_keyword]['path'])
      end

      super
    end
  end
end
