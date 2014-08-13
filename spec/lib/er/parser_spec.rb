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

  describe 'Parser' do
    before :each do
      html = @crawler.fetch_page(@wordbook_ej_url)
      @parser = Er::Parser.new(html)
      @expected_words_and_tags =
        @sample_data['wordbook_pages']['1']['words_and_tags']
    end

    it 'parses and returns words and tags related to the words' do
      words_and_tags = @parser.parse_word_and_tags
      if @config['fakeweb_enable']
        expect(words_and_tags).to eq @expected_words_and_tags
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
