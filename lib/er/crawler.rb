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
        tag_name_ary = words_and_tags[e_id]['tags']

        # Storing Er::Item
        item = _store_er_item(e_id, word)

        # Storing Er::ItemsUser
        u_item = _store_er_items_user(user.id, item.id, page_url)
        existing_u_item_tag_id_ary = u_item.tags.collect { |tag| tag.id }

        # Storing/Deleting Er::ItemsUsersTag
        _store_and_delete_er_items_users_tags(u_item.id, tag_name_ary,
                                              existing_u_item_tag_id_ary)
      end
    end

    def _store_er_item(e_id, word)
      item_data = {e_id: e_id, name: word}
      return Er::Item.find_or_create_by(item_data)
    end

    def _store_er_items_user(user_id, item_id, page_url)
      items_user_data = {user_id: user_id, item_id: item_id,
                         wordbook_url: page_url}
      return Er::ItemsUser.find_or_create_by(items_user_data)
    end

    def _store_and_delete_er_items_users_tags(u_item_id, tag_name_ary,
                                              existing_u_item_tag_id_ary)
      tag_name_ary.each do |tag_name|
        tag = Er::Tag.find_by_tag(tag_name)
        next unless tag

        tag_data = {items_user_id: u_item_id, tag_id: tag.id}
        u_item_tag = Er::ItemsUsersTag.find_or_initialize_by(tag_data)
        if u_item_tag.new_record?
          u_item_tag.registration_date = Time.now
          u_item_tag.save!
        else
          existing_u_item_tag_id_ary.delete u_item_tag.id
        end
      end

      # Delete tags which were removed on Eijiro pages
      existing_u_item_tag_id_ary.each do |u_item_tag_id|
        Er::ItemsUsersTag.find(u_item_tag_id).destroy
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
