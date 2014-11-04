class Predictor

  PROJECT = ENV['GOOGLE_PROJECT_ID']

  attr_reader :client, :prediction

  def initialize
    @client = Google::APIClient.new(
      application_name: 'Futures Forecaster',
      application_version: '1.0.0'
    )
    @prediction = client.discovered_api('prediction', 'v1.6')
  end

  def authorize_client!
    key_file = Dir[Dir.pwd + '/keys/Futures\ Forecaster-ec79eb6b3492.p12'].first
    key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, 'notasecret')
    client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope => ['https://www.googleapis.com/auth/prediction', 'https://www.googleapis.com/auth/devstorage.full_control'],
      :issuer => '451187726599-99d76er4amj2q9op59mlbdkblv836hf9@developer.gserviceaccount.com',
      :signing_key => key)
    client.authorization.fetch_access_token!
  end

  def train(options)
    location = options[:location]
    code = options[:code]
    month = options[:month]
    year = options[:year].to_s
    raise 'Invalid Options' unless location && code && month && year
    id = [location, code + month + year].join('_').gsub(' ', '_')
    file = id + '.csv'

    training = prediction.trainedmodels.insert.request_schema.new
    training.id = id
    training.storage_data_location = "heating_oil/#{code + month + year}/#{file}"
    authorize_client!
    client.execute(
      api_method:  prediction.trainedmodels.insert,
      headers: {'Content-Type' => 'application/json'},
      body_object: training,
      parameters: {'project' => PROJECT}
    )
  end

  def check_status(options)
  end

end
