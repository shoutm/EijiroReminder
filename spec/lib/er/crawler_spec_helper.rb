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
  FakeWeb.register_uri :post, @login_url, \
    :'Set-Cookie' => @sample_data['cookie']
  dummy_file_path = File.join(__dir__, 'sample_data/eowp_sample.html')
  dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
  FakeWeb.register_uri :post, @login_url,
    :'Set-Cookie' => @sample_data['cookie']
  FakeWeb.register_uri :get, @wordbook_ej_url, body: dummy_html
end

def initialize_database
  clean_db

  create(:default_user)
  @default_user = Er::User.find_by_name('Default User')

  create(:'tag-1st')
  create(:'tag-2nd')
  create(:'tag-3rd')
end

def clean_db
  # TODO There are some ways to clear db elegantly
  Er::ItemsUsersTag.delete_all
  Er::ItemsUser.delete_all
  Er::User.delete_all
  Er::Item.delete_all
  Er::Tag.delete_all
end
