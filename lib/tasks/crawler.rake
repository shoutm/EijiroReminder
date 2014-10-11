namespace :er do
  desc 'Crawling Eijiro for all registered users'
  task :crawl => :environment do
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

  desc 'Reminding English words to all registered users'
  task :remind => :environment do
    Er::Reminder.new.run
  end

  desc 'Run all tasks(Crawling and Reminding)'
  task :run_all => [:crawl, :remind]

  desc 'Initialize(reset) database. CAUTION: THIS TASK DELETES ALL DATA IN DB.'
  task :reset_db => :environment do
    puts <<EOS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
CAUTION: This task will delete all data in the database.
Do you really want to continue? (yes/no)
EOS
    input = STDIN.gets
    input.chomp!
    if input != 'yes'
      puts 'Aborted. Nothing were executed.'
      exit
    end

    Er::Util.reset_db
    puts 'Done.'
  end
end
