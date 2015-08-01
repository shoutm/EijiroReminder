namespace :er do
  desc 'Crawling Eijiro for all registered users'
  task :crawl => :environment do
    Er::CrawlerInvoker.new.run_for_all_users
  end

  desc 'Reminding English words to all registered users'
  task :remind => :environment do
    Er::Reminder.new.run
  end

  desc 'Run all tasks(Crawling and Reminding)'
  task :run_all => [:crawl, :remind]

  desc '[DryRun] Pick items to be reminded for a specified user id: ' \
       'e.g., rake er:test_pick_items user_id=1'
  task :test_pick_items => :environment do
    items_users = Er::Reminder.new.send("_pick_items_from_db", ENV['user_id'])
    items_users.each do |items_user|
      puts items_user.item.name
      puts "  " + items_user.wordbook_url
    end
  end


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
