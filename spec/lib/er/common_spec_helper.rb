def initialize_variables
    @config_path = Rails.root.join('spec/config/crawler_config.yaml')
    reminder_config_path =
      Rails.root.join('lib/config/er_reminder_config.yaml')
    @sampledata_path = File.join(__dir__, 'sample_data/sample_data.yaml')
    @config = YAML.load_file @config_path
    reminder_config = YAML.load_file reminder_config_path
    @config = @config.merge(reminder_config)
    @sample_data = YAML.load_file @sampledata_path
    @login_post_url  = @config['urls']['login_post_url']
    @login_get_url   = @config['urls']['login_get_url']
    @wordbook_ej_url = @config['urls']['wordbook_ej_url']
    FakeWeb.allow_net_connect = !@config['fakeweb_enable']
end

def set_fakeweb
  FakeWeb.clean_registry

  # login_post_url
  cookie1 = [@sample_data['cookies']['ltpatoken2'],
             @sample_data['cookies']['pd_h_session_id']].join(',')
  cookie2 = [cookie1, @sample_data['cookies']['eowpuser']].join(',')
  FakeWeb.register_uri :post, @login_post_url, :'Set-Cookie' => cookie1
  FakeWeb.register_uri :get, @login_get_url, :'Set-Cookie' => cookie2
  @sample_data['wordbook_pages'].keys.each do |p_index_str|
    _register_wordbook_page_with_page_index(p_index_str)
  end
end

def wordbook_url_with_page_index(index_str)
  @wordbook_ej_url + '?page=' + index_str
end

def initialize_database
  Er::Util::reset_db

  initialize_testdata
end

def initialize_testdata
  # Create default user
  create(:default_user)
  @default_user = Er::User.find_by_name('Default User')
end

private

def _register_wordbook_page_with_page_index(p_index_str, url_index=nil)
  url_index = p_index_str unless url_index
  dummy_file_path = File.join(__dir__,
    @sample_data['wordbook_pages'][p_index_str]['file_path'])
  dummy_html = File.open(dummy_file_path, 'r:UTF-8').read
  url = wordbook_url_with_page_index(url_index)
  FakeWeb.register_uri :get, url, body: dummy_html
  # Default page registration
  if p_index_str == '1'
    FakeWeb.register_uri :get, @wordbook_ej_url, body: dummy_html
  end
end
