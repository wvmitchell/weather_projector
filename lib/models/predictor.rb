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
    location = options[:location]
    code = options[:code]
    month = options[:month]
    year = options[:year].to_s
    raise 'Invalid Options' unless location && code && month && year
    id = [location, code + month + year].join('_').gsub(' ', '_')
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.get,
      parameters: {'id' => id, 'project' => PROJECT}
    )
  end

  def predict(options)
    location = options[:location]
    code = options[:code]
    month = options[:month]
    year = options[:year].to_s
    raise 'Invalid Options' unless location && code && month && year
    id = [location, code + month + year].join('_').gsub(' ', '_')
    input = prediction.trainedmodels.predict.request_schema.new
    input.input = {}
    input.input.csv_instance = [2014,11,4,2,12.21,13.64,18.405,16.37,15.585,12.465,4.97,-1.365,10.08,6.44,7.835,6.22,8.43,10.935,5.42,9.6,10.525,2.185,1.07,2.74,-5.51,-6.75,2.05,8.155,8.665,4.85,2.24,-2.91,-1.795,3.68,12.02]
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.predict,
      parameters: {'id' => id, 'project' => PROJECT},
      headers: {'Content-Type' => 'application/json'},
      body_object: input
    )
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

end
