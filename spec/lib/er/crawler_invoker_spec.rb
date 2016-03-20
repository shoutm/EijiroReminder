# encoding: UTF-8
require 'spec_helper'
require "#{File.dirname(__FILE__)}/common_spec_helper"
require "#{File.dirname(__FILE__)}/crawler_spec_helper"

describe 'Er::CrawlerInvoker' do
  include Er::CrawlerSpecHelper

  before :all do
    initialize_variables
    initialize_database
    set_fakeweb if @config['fakeweb_enable']
    #set_testdata
  end

  # This test is for checking appropriate items are saved in db
  # for multiple users.
  describe 'run_for_all_users' do
    before :each do
      # This spec can be done only when fakeweb_enabled is true
      skip unless @config['fakeweb_enable']
      # Create Er::Tag entries
      create_test_tags
      # There is the default user in db so create the second user.
      @sample_user = create(:sample_user)
      # Create an er_item entry which will not be fetched. This entry will be
      # disabled after crawling.
      @disabled_item = create(:er_item)

      Timecop.freeze
      @scraping_time = Time.now
      Er::CrawlerInvoker.new.run_for_all_users
      Timecop.return
    end

    it 'stores new entries in er_items table' do
      # This spec can be done only when fakeweb_enabled is true
      skip unless @config['fakeweb_enable']
      @sample_data['wordbook_pages'].keys.each do |p_index|
        expected = @sample_data['wordbook_pages'][p_index]['words_and_tags']
        check_existence_of_er_items(expected)
      end
    end

    it 'disables the entry which is in db but not fetched from web' do
      skip unless @config['fakeweb_enable']
      expect(Er::Item.find(@disabled_item.id).disabled).to be true
    end

    it 'stores new entries in er_items_users table' do
      # This spec can be done only when fakeweb_enabled is true
      skip unless @config['fakeweb_enable']
      _check_with_block do |user, url, expected|
        check_existence_of_er_items_users(user, url, expected)
      end
    end

    it 'stores new entries in er_items_users_tags table' do
      # This spec can be done only when fakeweb_enabled is true
      skip unless @config['fakeweb_enable']
      _check_with_block do |user, url, expected|
        check_existence_of_er_items_users_tags(user, url, expected,
                                               @scraping_time)
      end
    end

    private

    def _check_with_block
      Er::User.all.each do |user|
        @sample_data['wordbook_pages'].keys.each do |p_index|
          break if @sample_data['wordbook_pages'][p_index]['last_page']
          url = wordbook_url_with_page_index(p_index)
          expected = @sample_data['wordbook_pages'][p_index]['words_and_tags']
          yield user, url, expected
        end
      end
    end
  end
end
