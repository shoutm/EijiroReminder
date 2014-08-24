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
          expect(picked_items).to eq [items_user.item]
        end
      end

      context 'with an item having a tag' do
        before :each do
          @tag_info = create(:er_items_users_tag)
          @tag  = @tag_info.tag
          @user = @tag_info.items_user.user
          @item = @tag_info.items_user.item
        end

        context 'before the interval date which is related to the tag' do
          it "doesn't pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
                                 v_current_time: @tag_info.registration_date)
          end
        end

        context 'on the day which is just after the interval days' do
          it "pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info.registration_date + @tag.interval,
              expected_items: [@item])
          end
        end

        context 'after the interval date which is related to the tag' do
          it "pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info.registration_date + @tag.interval\
                              + 1.day,
              expected_items: [@item])
          end
        end
      end

      context 'with an item having multiple tags' do
        before :each do
          @tag_info1 = create(:er_items_users_tag)
          test_tag2  = create(:test_tag2)
          @tag_info2 = create(:er_items_users_tag,
                              items_user: @tag_info1.items_user,
                              tag: test_tag2)
          @tag1 = @tag_info1.tag
          @tag2 = @tag_info2.tag
          @user = @tag_info2.items_user.user
          @item = @tag_info2.items_user.item
        end

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
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info1.registration_date,
              expected_items: [])
          end
        end

        context 'in a term of (B)' do
          it "doesn't pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info1.registration_date + @tag1.interval,
              expected_items: [])
          end
        end

        context 'in a term of (C)' do
          it "doesn't pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info2.registration_date,
              expected_items: [])
          end
        end

        context 'in a term of (D)' do
          it "pick up the item" do
            _could_pick_up_items?(reminder: @reminder, user: @user,
              v_current_time: @tag_info2.registration_date + @tag2.interval,
              expected_items: [@item])
          end
        end
      end

      context 'with an item having "done" tag' do
        it 'never pick up the item even if 10000 days after' do
          test_tagdone = create(:test_tagdone)
          tag_info = create(:er_items_users_tag, tag: test_tagdone)
          user = tag_info.items_user.user

          _could_pick_up_items?(reminder: @reminder, user: user,
            v_current_time: tag_info.registration_date + 10000.days,
            expected_items: [])
        end
      end
    end

    describe 'according to the max number of picking items' do
      before :each do
        @user = create(:sample_user)
      end

      context 'if the number of picked items is below the max value' do
        it "doesn't truncate the items" do
          _create_items_and_check(@user,
                                  Er::Reminder.MAX_PICKUP_ITEMS_NUM,
                                  Er::Reminder.MAX_PICKUP_ITEMS_NUM)
        end
      end

      context 'if the number of picked items is over the max value' do
        it 'truncates the items up until the max number' do
          _create_items_and_check(@user,
                                  Er::Reminder.MAX_PICKUP_ITEMS_NUM + 1,
                                  Er::Reminder.MAX_PICKUP_ITEMS_NUM)
        end
      end

    end
  end

  describe 'Sending email to users' do
    it '' do
    end
  end

  private

  def _could_pick_up_items?(reminder: nil, user: nil, v_current_time: Time.now,
                           expected_items: [])
    Timecop.travel(v_current_time) do
      Timecop.freeze
      items = reminder.pick_items_from_db(user.id)
      expect(items).to eq expected_items
    end
  end

  def _create_items_and_check(user, items_num_to_create, expected_items_num)
    _create_items(user, items_num_to_create)
    got_items = @reminder.pick_items_from_db(user.id)
    expect(got_items.size).to eq expected_items_num
  end

  def _create_items(user, items_num)
    items_num.times do
      item = create(:er_item)
      create(:er_items_user, user: user, item: item)
    end
  end
end
