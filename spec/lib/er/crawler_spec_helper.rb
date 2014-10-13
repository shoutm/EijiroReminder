module Er
  module CrawlerSpecHelper
    def create_test_tags
      # Create Er::Tag entries
      create(:test_tag1)
      create(:test_tag2)
      create(:test_tagdone)
    end

    def check_er_items(expected_words_and_tags)
      expect {
        expected_words_and_tags.each_key do |e_id|
          word = expected_words_and_tags[e_id]['word']
          expect(Er::Item.where(e_id: e_id, name: word).size).to eq(1)
        end
      }.not_to raise_error
    end

    def check_er_items_users(user, page_url, expected_words_and_tags)
      expect {
        expected_words_and_tags.each_key do |e_id|
          item = Er::Item.find_by_e_id(e_id)
          expect(Er::ItemsUser.where(user_id: user.id,
            item_id: item.id,
            wordbook_url: page_url).size).to eq(1)
        end
      }.not_to raise_error
    end

    def check_er_items_users_tags(user, page_url, expected_words_and_tags,
                                  scraping_time)
      expect {
        expected_words_and_tags.each_key do |e_id|
          tags = expected_words_and_tags[e_id]['tags']
          item = Er::Item.find_by_e_id(e_id)
          items_user = Er::ItemsUser.find_by(user_id: user.id,
                                             item_id: item.id,
                                             wordbook_url: page_url)
          tags.each do |tag_name|
            tag = Er::Tag.find_by_tag(tag_name)
            if tag
              # u_item_tag stands for user's item's tag.
              u_item_tag_ary = Er::ItemsUsersTag.where(
                items_user_id: items_user.id, tag_id: tag.id)
              expect(u_item_tag_ary.size).to eq(1)

              if u_item_tag_ary.size == 1
                # NOTE: The reason why I use 'round' here is due to the
                # difference of 'number of significant figures' between
                # ruby and postgres.
                # - It of Ruby 2.1.1p76 is 9. (nano sec order)
                # - It of Postgres 9.3.5 is 6. (micro sec order)
                expect(u_item_tag_ary.first.registration_date.utc.round).to \
                  eq(scraping_time.utc.round)
              end
            end
          end
        end
      }.not_to raise_error
    end
  end
end
