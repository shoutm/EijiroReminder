module Er
  class Util
    def self.reset_db
      # Clear DB and populate seeds.
      # TODO There are some ways to clear db elegantly
      Er::ItemsUsersTag.delete_all
      Er::ItemsUser.delete_all
      Er::User.delete_all
      Er::Item.delete_all
      Er::Tag.delete_all

      load "#{Rails.root}/db/seeds.rb"
    end
  end
end
