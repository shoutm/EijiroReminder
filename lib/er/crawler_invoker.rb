# encoding: UTF-8

module Er
  class CrawlerInvoker
    def run_for_all_users
      users = Er::User.all
      users.each do |user|
        crawler = Er::Crawler.new(id: user.email, password: user.password)
        # ucp stands for Er::Crawler::UrlContentsPair
        ucp_array = crawler.fetch_and_parse_all_pages
        # To store what words are fetched
        fetched_ids = []
        ucp_array.each do |ucp|
          contents = ucp.parsed_contents
          crawler.save(ucp.page_url, contents)
          fetched_ids += contents.keys
        end

        # Delete items in database which are not fetched from page
        _delete_unfetched_items(fetched_ids)
      end
    end

    private

    def _delete_unfetched_items(fetched_ids)
      disabled_items = Er::Item.where(disabled: false)
                               .pluck('e_id').map(&:to_s) - fetched_ids
      disabled_items.each do |item|
        er_item = Er::Item.find_by_e_id(item)
        er_item.disabled = true
        er_item.save!
      end
    end
  end
end
