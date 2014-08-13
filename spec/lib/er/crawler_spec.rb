# encoding: UTF-8
require 'spec_helper'
require 'yaml'
require "#{File.dirname(__FILE__)}/common_spec_helper"

describe 'Unit tests for Er::Crawler' do
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
      expect(crawler.base_url).to eq expected['base_url']
      expect(crawler.paths).to eq expected['paths']
      expect(crawler.id).to eq @default_user.email
      expect(crawler.password).to eq @default_user.password
    end
  end

  it 'return the login url' do
    expect(@crawler.login_url).to eq @login_url
  end

  it 'return the word(ej) url' do
    expect(@crawler.wordbook_ej_url).to eq @wordbook_ej_url
  end

  describe 'login' do
    context 'with valid id and password' do
      it 'logs in successfully and store a cookie' do
        @crawler.login
        expect(@crawler.cookie).to match /eowpuser=/
        expect(@crawler.cookie).not_to match /domain=/
        expect(@crawler.cookie).not_to match /path=/
      end
    end

    context 'with invalid id and password' do
      it 'cannot log in and set nil as the cookie parameter' do
        FakeWeb.register_uri :post, @login_url, \
          :'Set-Cookie' => nil if @config['fakeweb_enable']
        @crawler.password += '_edit'
        @crawler.login
        expect(@crawler.cookie).to be_nil
      end
    end
  end

  it 'fetches a wordbook(ej) page' do
    url_contents_pair = @crawler.fetch_page(@wordbook_ej_url)

    # The wordbook(ej) includes:
    # - <div> which id is 'tabenja' and in which doesn't include any link
    # - <div> which id is 'tabjaen' and in which includes a link to
    #   the wordbook (je)
    doc = Nokogiri::HTML(url_contents_pair.page_contents)
    _fetch_successful?(doc)
  end

  it 'timeouts when a URL cannot be acccessed' do
  end

  it 'fetches all wordbook(ej) pages' do
    urls = []
    expected_contents = []
    @sample_data['wordbook_pages'].keys.each do |page_num|
      urls.push wordbook_url_with_page_index(page_num)
      expected_contents.push \
        @sample_data['wordbook_pages'][page_num]['words_and_tags']
    end
    page_contents_pair_ary = @crawler.fetch_pages(urls)
    page_contents_pair_ary.each do |url_contents_pair|
      _fetch_successful?(Nokogiri::HTML(url_contents_pair.page_contents))
    end
  end

  private

  def _fetch_successful?(nokogiri_html)
    tabenja = nokogiri_html.css('div#tabenja')
    expect(tabenja.css('a[href="/wordbook/ej"]').empty?).to be true
    tabjaen = nokogiri_html.css('div#tabjaen')
    expect(tabjaen.css('a[href="/wordbook/je"]').empty?).to be false
  end
end

describe 'Integration tests for Er::Crawler and Er::Parser' do
  before :all do
    initialize_variables
    initialize_database
    set_fakeweb if @config['fakeweb_enable']
    @crawler = Er::Crawler.new(
        id: @default_user.email,
        password: @default_user.password)
    set_testdata
  end

  def set_testdata
    if @config['fakeweb_enable']
      @expected_words_and_tags =
        @sample_data['wordbook_pages']['1']['words_and_tags']
    else
      user = Er::User.find_by_email(@default_user.email)
      url_contents_pair = @crawler.fetch_page(@wordbook_ej_url)
      parser = Er::Parser.new(url_contents_pair.page_contents)
      @expected_words_and_tags = parser.parse_word_and_tags
    end
  end

  describe 'fetching a page, parsing and updating database' do
    context 'with no correspondent entries in DB' do
      before(:all) do
        # No db entries before scraping
        url_contents_pair = @crawler.fetch_page(@wordbook_ej_url)
        @crawler.parse_and_save([url_contents_pair])
      end

      it 'stores new entries in er_items table' do
        check_er_items
      end

      it 'stores new entries in er_items_users table' do
        check_er_items_users
      end

      it 'stores new entries in er_items_users_tags table' do
        check_er_items_users_tags
      end
    end

    context 'with an existing entry in DB' do
      before(:all) do
        create(:default_items_users_tag)
        Timecop.freeze
        @scraping_time = Time.now
        url_contents_pair = @crawler.fetch_page(@wordbook_ej_url)
        @crawler.parse_and_save([url_contents_pair])
        Timecop.return
      end

      it 'keeps having an existing entry in er_items table' do
        check_er_items
      end

      it 'keeps having an existing entry in er_items_users table' do
        check_er_items_users
      end

      it 'keeps having an existing entry in er_items_users_tags table' do
        check_er_items_users_tags
      end
    end
  end

  private

  def check_er_items
    expect {
      @expected_words_and_tags.each_key do |e_id|
        word = @expected_words_and_tags[e_id]['word']
        expect(Er::Item.where(e_id: e_id, name: word).size).to eq(1)
      end
    }.not_to raise_error
  end

  def check_er_items_users
    expect {
      @expected_words_and_tags.each_key do |e_id|
        item = Er::Item.find_by_e_id(e_id)
        expect(Er::ItemsUser.where(user_id: @default_user.id,
          item_id: item.id,
          wordbook_url: @wordbook_ej_url).size).to eq(1)
      end
    }.not_to raise_error
  end

  def check_er_items_users_tags
    expect {
      @expected_words_and_tags.each_key do |e_id|
        tags = @expected_words_and_tags[e_id]['tags']
        item = Er::Item.find_by_e_id(e_id)
        items_user = Er::ItemsUser.find_by(user_id: @default_user.id,
                                           item_id: item.id,
                                           wordbook_url: @wordbook_ej_url)
        tags.each do |tag_name|
          tag = Er::Tag.find_by_tag(tag_name)
          if tag
            expect(Er::ItemsUsersTag.where(items_user_id: items_user.id,
              tag_id: tag.id,
              registration_date: @scraping_time).size).to eq(1)
          end
        end
      end
    }.not_to raise_error
  end
end
