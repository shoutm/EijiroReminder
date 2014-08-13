def initialize_variables
    @config_path = Rails.root.join('spec/config/crawler_config.yaml')
    @sampledata_path = File.join(__dir__, 'sample_data/sample_data.yaml')
    @config = YAML.load_file @config_path
    @sample_data = YAML.load_file @sampledata_path
    @login_url = @config['paths']['login']['proto'] + File.join( \
      @config['base_url'], @config['paths']['login']['path'])
    @wordbook_ej_url = @config['paths']['wordbook_ej']['proto'] + File.join( \
      @config['base_url'], @config['paths']['wordbook_ej']['path'])
    FakeWeb.allow_net_connect = !@config['fakeweb_enable']
end

def set_fakeweb
  FakeWeb.clean_registry
  FakeWeb.register_uri :post, @login_url,
    :'Set-Cookie' => @sample_data['cookie']
  @sample_data['wordbook_pages'].keys.each do |page_num_str|
    dummy_file_path = File.join(__dir__,
      @sample_data['wordbook_pages'][page_num_str]['file_path'])
    dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
    url = wordbook_url_with_page_index(page_num_str)
    FakeWeb.register_uri :get, url, body: dummy_html
    # Default page registration
    if page_num_str == '1'
      url = @wordbook_ej_url
      FakeWeb.register_uri :get, url, body: dummy_html
    end
  end
end

def wordbook_url_with_page_index(index_str)
  @wordbook_ej_url + '?page=' + index_str
end

def initialize_database
  reset_db

  create(:default_user)
  @default_user = Er::User.find_by_name('Default User')
end

def reset_db
  # Clear DB and populate seeds.
  # TODO There are some ways to clear db elegantly
  Er::ItemsUsersTag.delete_all
  Er::ItemsUser.delete_all
  Er::User.delete_all
  Er::Item.delete_all
  Er::Tag.delete_all

  load "#{Rails.root}/db/seeds.rb"
end
