# encoding: UTF-8
require 'spec_helper'
require 'yaml'
require "#{File.dirname(__FILE__)}/common_spec_helper"

describe 'Unit tests for Er::Reminder' do
  before :all do
    initialize_variables
    set_fakeweb if @config['fakeweb_enable']
    @reminder = Er::Reminder.new
  end

  before :each do
    initialize_database
    # Crawler just needs @default_user which is initialized in
    # "initialize_database"
    @crawler = Er::Crawler.new(
        id: @default_user.email,
        password: @default_user.password)
  end

  describe 'Picking Items from DB' do
    describe 'according to tags' do
      context 'with an item having no tag' do
        it 'pick up the item' do
          # Create a user and an item which doesn't have any tags.
          items_user = create(:er_items_user)
          picked_items = @reminder.pick_items_from_db(items_user.user_id)
          expect(picked_items).to eq [items_user.item_id]
        end
      end

      context 'with an item having a tag' do
        context 'before the interval date which is related to the tag' do
          it "doesn't pick up the item" do
          end
        end

        context 'on the day which is just after the interval days' do
          it "pick up the item" do
          end
        end

        context 'after the interval date which is related to the tag' do
          it "pick up the item" do
          end
        end
      end

      context 'with an item having multiple tags' do
        # It should depend only on the tag which has the biggest "order" value.
        # This assumption described as below is applied in this context:
        #
        # --+-----------+-----------+-----------+-----------> Time
        #   |    (A)    |    (B)    |     (C)   |    (D)
        #   |           |           |           +-> Tag_B's interval days after
        #   |           |           +-> Tag_B's registration date
        #   |           +-> Tag_A's interval days after
        #   +-> Tag_A's registration date
        context 'in a term of (A)' do
          it "doesn't pick up the item" do
          end
        end

        context 'in a term of (B)' do
          it "doesn't pick up the item" do
          end
        end

        context 'in a term of (C)' do
          it "doesn't pick up the item" do
          end
        end

        context 'in a term of (D)' do
          it "pick up the item" do
          end
        end
      end

      context 'with an item having "done" tag' do
        it 'never pick up the item even if 10000 days after' do
        end
      end
    end

    describe 'according to the max number of picking items' do
      context 'if the number of picked items is below the max value' do
        it "doesn't truncate the items" do
        end
      end

      context 'if the number of picked items is over the max value' do
        it 'truncates the items up until the max number' do
        end
      end
    end
  end

  describe 'Sending email to users' do
    it '' do
    end
  end
end
