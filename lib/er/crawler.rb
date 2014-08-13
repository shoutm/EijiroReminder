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

    def fetch_pages(page_url_ary)
      page_contents = []
      page_url_ary.each do |page_url|
        page_contents.push fetch_page(page_url)
      end
      return page_contents
    end

    def fetch_page(page_url)
      login unless @cookie;
      open(page_url, 'Cookie' => @cookie).read
    rescue
      # TODO add Logging mechanism
      nil
    end

    def parse_and_save(url_contents_pair_ary)
      url_contents_pair_ary.each do |url_contents_pair|
        user = Er::User.find_by_email(@id)
        parser = Parser.new(url_contents_pair.page_contents)
        word_and_tags = parser.parse_word_and_tags

        _store_parsed_items(user, url_contents_pair.page_url, word_and_tags)
      end
    end

    class UrlContentsPair
      attr_accessor :page_url, :page_contents

      def initialize(page_url, page_contents)
        @page_url = page_url
        @page_contents = page_contents
      end
    end

    private

    def _store_parsed_items(user, page_url, word_and_tags)
      word_and_tags.each_key do |e_id|
        word = word_and_tags[e_id]['word']
        tags = word_and_tags[e_id]['tags']
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
