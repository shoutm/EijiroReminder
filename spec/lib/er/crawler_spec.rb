# encoding: UTF-8
require 'spec_helper'
require 'yaml'
require "#{File.dirname(__FILE__)}/common_spec_helper"
require "#{File.dirname(__FILE__)}/crawler_spec_helper"

describe 'Unit tests for Er::Crawler' do
  include Er::CrawlerSpecHelper

  before :all do
    initialize_variables
    initialize_database
  end

  before :each do
    set_fakeweb if @config['fakeweb_enable']
    @crawler = Er::Crawler.new(
        id: @default_user.email,
        password: @default_user.password)
  end

  describe 'initialization' do
    it 'is initialized with a valid config file' do
      crawler = Er::Crawler.new(config_path: @config_path,
        id: @default_user.email,
        password: @default_user.password)
      _valid_crawler?(crawler, @config)
    end

    it 'is initialized with default config file' do
      default_conf_path = Rails.root.join('lib/config/er_crawler_config.yaml')
      default_config = YAML.load_file default_conf_path
      crawler = Er::Crawler.new(
        id: @default_user.email,
        password: @default_user.password)
      _valid_crawler?(crawler, default_config)
    end

    def _valid_crawler?(crawler, expected)
      expect(crawler.urls).to eq expected['urls']
      expect(crawler.id).to eq @default_user.email
      expect(crawler.password).to eq @default_user.password
    end
  end

  it 'return the login post url' do
    expect(@crawler.login_post_url).to eq @login_post_url
  end

  it 'return the login get url' do
    expect(@crawler.login_get_url).to eq @login_get_url
  end

  it 'return the word(ej) url' do
    expect(@crawler.wordbook_ej_url).to eq @wordbook_ej_url
  end

  describe 'login' do
    context 'with valid id and password' do
      it 'logs in successfully and store a cookie' do
        @crawler.login
        expect(@crawler.cookie).to match /LtpaToken2=/
        expect(@crawler.cookie).to match /PD-H-SESSION-ID/
        expect(@crawler.cookie).to match /eowpuser=/
        expect(@crawler.cookie).not_to match /domain=/
        expect(@crawler.cookie).not_to match /path=/
      end
    end

    context 'with invalid id and password' do
      it 'cannot log in and set nil as the cookie parameter' do
        if @config['fakeweb_enable']
          FakeWeb.register_uri :post, @login_post_url, :'Set-Cookie' => nil
          FakeWeb.register_uri :post, @login_get_url, :'Set-Cookie' => nil
        end
        @crawler.password += '_edit'
        @crawler.login
        expect(@crawler.cookie).to be_nil
      end
    end
  end

  describe 'Fetching and parsing page' do
    it 'fetches a wordbook(ej) page' do
      url_contents_pair = @crawler.fetch_page(@wordbook_ej_url)

      # The wordbook(ej) includes:
      # - <div> which id is 'tabenja' and in which doesn't include any link
      # - <div> which id is 'tabjaen' and in which includes a link to
      #   the wordbook (je)
      doc = Nokogiri::HTML(url_contents_pair.page_contents)
      _fetch_successful?(doc)
    end

    it 'timeouts when a URL cannot be accessed' do
    end

    it 'parses a page' do
      file_path = File.join(__dir__,
        @sample_data['wordbook_pages']['1']['file_path'])
      html = File.open(file_path, 'r:UTF-8').read
      ucp = Er::Crawler::UrlContentsPair.new(@wordbook_ej_url, html)
      expected_words_and_tags =
        @sample_data['wordbook_pages']['1']['words_and_tags']

      words_and_tags = ucp.parsed_contents
      expect(words_and_tags).to eq expected_words_and_tags
    end

    it 'fetches and parses all wordbook(ej) pages' do
      expected_ucp_array = [] # ucp stands for Er::Crawler::UrlContentsPair
      @sample_data['wordbook_pages'].keys.each do |p_index|
        url = wordbook_url_with_page_index(p_index)
        break if @sample_data['wordbook_pages'][p_index]['last_page']
        file_path = File.join(__dir__,
          @sample_data['wordbook_pages'][p_index]['file_path'])
        html = File.open(file_path, 'r:UTF-8').read
        ucp = Er::Crawler::UrlContentsPair.new(url, html)
        expected_ucp_array.push ucp
      end

      ucp_array = nil
      expect{
        ucp_array = @crawler.fetch_and_parse_all_pages()
      }.not_to raise_error

      expect(ucp_array).to eq expected_ucp_array if @config['fakeweb_enable']
    end

    private

    def _fetch_successful?(nokogiri_html)
      tabenja = nokogiri_html.css('div#tabenja')
      expect(tabenja.css('a[href="/wordbook/ej"]').empty?).to be true
      tabjaen = nokogiri_html.css('div#tabjaen')
      expect(tabjaen.css('a[href="/wordbook/je"]').empty?).to be false
    end
  end

  describe 'Saving contents' do
    before :each do
      create_test_tags
    end

    context 'with no correspondent entries in DB' do
      before :each  do
        # No db entries before saving
        _initialize_variables
        Timecop.freeze
        _save_items
        Timecop.return
      end

      it 'stores new entries in er_items table' do
        check_er_items(@expected_words_and_tags)
      end

      it 'stores new entries in er_items_users table' do
        check_er_items_users(@default_user, @page_url,
                             @expected_words_and_tags)
      end

      it 'stores new entries in er_items_users_tags table' do
        check_er_items_users_tags(@default_user, @page_url,
                                  @expected_words_and_tags, @scraping_time)
      end
    end

    context 'with an existing entry in DB' do
      before :each do
        _initialize_variables
        # Preparation
        _preparation

        Timecop.freeze
        _save_items
        Timecop.return
      end

      it 'keeps having an existing entry in er_items table' do
        check_er_items(@expected_words_and_tags)
      end

      it 'keeps having an existing entry in er_items_users table' do
        check_er_items_users(@default_user, @page_url,
                             @expected_words_and_tags)
      end

      describe 'er_items_users_tags table' do
        it 'keeps having an existing entry' do
          check_er_items_users_tags(@default_user, @page_url,
            @existing_entry, @registration_date)
        end

        it 'removes tag which has been removed in Eijiro page' do
          check_er_items_users_tags(@default_user, @page_url,
            @existing_entry_tag_removed, @registration_date)
          expect {
            Er::ItemsUsersTag.find(@removed_u_item_tag.id)
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    private

    def _initialize_variables
      @page_url = @wordbook_ej_url
      @expected_words_and_tags =
        @sample_data['wordbook_pages']['1']['words_and_tags'].deep_dup
    end

    def _save_items
      @scraping_time = Time.now
      @crawler.save(@page_url, @expected_words_and_tags)
    end

    def _preparation
      @registration_date = Time.now
      _populate_existing_entry_in_db
      _populate_tag_removed_entry
    end

    def _populate_existing_entry_in_db
      # Populating existing entry
      e_id = @expected_words_and_tags.keys.first
      _register_words_and_tags e_id, @registration_date
      existing_wat = @expected_words_and_tags[e_id]
      @existing_entry = {e_id => existing_wat}
    end

    def _populate_tag_removed_entry
      # Populate an existing entry and delete a tag from
      # the expected object
      before_populating = Time.now
      e_id = @expected_words_and_tags.keys.last
      _register_words_and_tags e_id, @registration_date
      existing_wat = @expected_words_and_tags[e_id]
      removed_tag_name = existing_wat['tags'].pop

      # Finding out the removed tag object
      populated_u_item_tags = Er::ItemsUsersTag.where('created_at >= ?',
                                                      before_populating)
      @removed_u_item_tag = populated_u_item_tags.find do |u_item_tag|
        u_item_tag.tag.tag == removed_tag_name
      end

      @existing_entry_tag_removed = {e_id => existing_wat}
    end

    def _register_words_and_tags(e_id, registration_date)
      word = @expected_words_and_tags[e_id]['word']
      tags_ary = @expected_words_and_tags[e_id]['tags']
      item = create(:er_item, e_id: e_id, name: word)
      u_item = create(:er_items_user, user: @default_user, item: item,
                                      wordbook_url: @page_url)
      tags_ary.each do |tag_name|
        tag = Er::Tag.find_by_tag(tag_name)
        create(:er_items_users_tag, items_user: u_item, tag: tag,
               registration_date: registration_date)
      end
    end
  end
end
