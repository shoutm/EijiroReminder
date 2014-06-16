# encoding: UTF-8
require 'spec_helper'
require 'yaml'

describe 'Unit tests for EijiroReminder::Crawler' do
  before :all do
    @config_path = File.join(__dir__, 'crawler_config.yaml')
    @sampledata_path = File.join(__dir__, 'sample_data/sample_data.yaml')
    @config = YAML.load_file @config_path
    @sample_data = YAML.load_file @sampledata_path
    @login_url = @config['paths']['login']['proto'] + File.join( \
      @config['base_url'], @config['paths']['login']['path'])
    @wordbook_ej_url = @config['paths']['wordbook_ej']['proto'] + File.join( \
      @config['base_url'], @config['paths']['wordbook_ej']['path'])
    FakeWeb.allow_net_connect = !@config['fakeweb_enable']
  end

  before :each do
    _set_fakeweb if @config['fakeweb_enable']
    @crawler = EijiroReminder::Crawler.new(config_path: @config_path)
  end

  def _set_fakeweb
    FakeWeb.clean_registry
    FakeWeb.register_uri :post, @login_url, \
      :'Set-Cookie' => @sample_data['cookie']
    dummy_file_path = File.join(__dir__, 'sample_data/eowp_sample.html')
    dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
    FakeWeb.register_uri :post, @login_url,
      :'Set-Cookie' => @sample_data['cookie']
    FakeWeb.register_uri :get, @wordbook_ej_url, body: dummy_html
  end

  describe 'initialization' do
    it 'is initialized with a valid config file' do
      crawler = EijiroReminder::Crawler.new(config_path: @config_path)
      _valid_crawler?(crawler, @config)
    end

    it 'is initialized with valid parameters' do
      crawler = EijiroReminder::Crawler.new( \
        base_url: @config['base_url'], \
        paths: @config['paths'], \
        id: @config['id'], \
        password: @config['password'])
      _valid_crawler?(crawler, @config)
    end

    def _valid_crawler?(crawler, expected)
      expect(crawler.base_url).to eq expected['base_url']
      expect(crawler.paths).to eq expected['paths']
      expect(crawler.id).to eq expected['id']
      expect(crawler.password).to eq expected['password']
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
      @parser = EijiroReminder::Crawler::Parser.new(html)
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

describe 'Integration tests for EijiroReminder::Crawler' do
  describe 'fetching a page, parsing and updating database' do
    context 'with no correspondent entries in DB' do
      it 'stores entries in DB' do
      end
    end

    context 'with an existing entry in DB' do
      it 'updates entries in DB' do
      end
    end
  end
end
