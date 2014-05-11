# encoding: UTF-8
require 'spec_helper'
require 'yaml'

describe 'EijiroReminder::Crawler' do
  before :each do
    @config_path = File.join(__dir__, 'crawler_config.yaml')
    @config = YAML.load_file @config_path
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
    expect(@crawler.login_url).to eq \
      File.join(@config['base_url'], @config['paths']['login'])
  end

  it 'return the word(ej) url' do
    expect(@crawler.wordbook_ej_url).to eq \
      File.join(@config['base_url'], @config['paths']['wordbook_ej'])
  end

  it 'logs in successfully' do

  end

  it 'fetches a page' do
    dummy_file_path = File.join(__dir__, 'data/eowp_sample.html')
    dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
    url = @config['base_url']
    FakeWeb.register_uri :get, url, body: dummy_html

    html = @crawler.fetch_page(url)
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
