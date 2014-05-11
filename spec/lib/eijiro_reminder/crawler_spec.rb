# encoding: UTF-8
require 'spec_helper'
require 'yaml'

describe 'EijiroReminder::Crawler' do
  before :all do
    @config_path = File.join(__dir__, 'crawler_config.yaml')
    @sampledata_path = File.join(__dir__, 'sample_data/sample_data.yaml')
    @config = YAML.load_file @config_path
    @sample_data = YAML.load_file @sampledata_path
    @login_url = File.join(@config['base_url'], @config['paths']['login'])
    @wordbook_ej_url =
      File.join(@config['base_url'], @config['paths']['wordbook_ej'])
    FakeWeb.allow_net_connect = !@config['fakeweb_enable']
  end

  before :each do
    FakeWeb.clean_registry if @config['fakeweb_enable']
    @crawler = EijiroReminder::Crawler.new(config_path: @config_path)
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
        FakeWeb.register_uri :post, @login_url, \
          :'Set-Cookie' => @sample_data['cookie'] if @config['fakeweb_enable']
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

  it 'fetches a page' do
    dummy_file_path = File.join(__dir__, 'sample_data/eowp_sample.html')
    dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
    FakeWeb.register_uri :get, @wordbook_ej_url, body: dummy_html \
      if @config['fakeweb_enable']

    html = @crawler.fetch_page(@wordbook_ej_url)
    expect(html).not_to be_nil
  end

  it 'timeouts when a URL cannot be acccessed' do
  end

  describe 'Parser' do
    it 'parses and returns a word' do
    end

    it 'parses and returns tags related to a word' do
    end

    it 'parses and returns a URL' do
    end

    it 'returns an error when a parse failed' do
    end
  end

end
