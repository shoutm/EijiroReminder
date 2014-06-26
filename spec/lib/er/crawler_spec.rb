# encoding: UTF-8
require 'spec_helper'
require 'yaml'
require "#{File.dirname(__FILE__)}/crawler_spec_helper"

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
    html = @crawler.fetch_page(@wordbook_ej_url)

    # The wordbook(ej) includes:
    # - <div> which id is 'tabenja' and in which doesn't include any link
    # - <div> which id is 'tabjaen' and in which includes a link to
    #   the wordbook (je)
    doc = Nokogiri::HTML(html)
    tabenja = doc.css('div#tabenja')
    expect(tabenja.css('a[href="/wordbook/ej"]').empty?).to be true
    tabjaen = doc.css('div#tabjaen')
    expect(tabjaen.css('a[href="/wordbook/je"]').empty?).to be false
  end

  it 'timeouts when a URL cannot be acccessed' do
  end

  it 'fetches all wordbook(ej) pages' do
  end

  describe 'Parser' do
    before :each do
      html = @crawler.fetch_page(@wordbook_ej_url)
      @parser = Er::Crawler::Parser.new(html)
    end

    it 'parses and returns words and tags related to the words' do
      words_and_tags = @parser.parse_word_and_tags
      if @config['fakeweb_enable']
        expect(words_and_tags).to eq @sample_data['words_and_tags']
      else
        words_and_tags.keys.each do |id|
          expect(words_and_tags[id]['word'].class).to eq String
          expect(words_and_tags[id]['tags'].class).to eq Array
        end
      end
    end

    it 'returns an error when a parse failed' do
    end
  end

end

describe 'Integration tests for Er::Crawler' do
  before :all do
    initialize_variables
    initialize_database
    set_fakeweb if @config['fakeweb_enable']
    @crawler = Er::Crawler.new(config_path: @config_path)
  end

  describe 'fetching a page, parsing and updating database' do
    context 'with no correspondent entries in DB' do
      before(:all) do
        # No db entries before scraping
#        @crawler.scrape_and_save(@wordbook_ej_url)
      end

      it 'stores new entries in er_items table' do
        @sample_data['words_and_tags'].each_key do |e_id|
          name = @sample_data['words_and_tags'][e_id]
#          expect(Er::Item.where(e_id: e_id, name: name).size).to eq(1)
        end
      end

      it 'stores new entries in er_items_users table' do
      end

      it 'stores new entries in er_items_users_tags table' do
      end
    end

    context 'with an existing entry in DB' do
      it 'updates entries in DB' do
        # No db entries before scraping
#        @crawler.scrape_and_save(@wordbook_ej_url)
      end
    end
  end
end
