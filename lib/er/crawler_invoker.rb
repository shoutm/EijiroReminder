# encoding: UTF-8

module Er
  class CrawlerInvoker
    def run_for_all_users
      users = Er::User.all
      users.each do |user|
        crawler = Er::Crawler.new(id: user.email, password: user.password)
        # ucp stands for Er::Crawler::UrlContentsPair
        ucp_array = crawler.fetch_and_parse_all_pages
        ucp_array.each do |ucp|
          crawler.save(ucp.page_url, ucp.parsed_contents)
        end
      end
    end
  end
end
