class Predictor

  PROJECT = ENV['GOOGLE_PROJECT_ID']

  attr_reader :client, :prediction, :location, :code, :month, :year, :id

  def initialize(options)
    @client = Google::APIClient.new(
      application_name: 'Futures Forecaster',
      application_version: '1.0.0'
    )
    @prediction = client.discovered_api('prediction', 'v1.6')
    @location = options[:location]
    @code = options[:code].upcase
    @month = MONTH_CODES[options[:month].to_s]
    @year = options[:year].to_s
    raise 'Invalid Options' unless location && code && month && year
    @id = [location, code].join('_').gsub(' ', '_')
  end

  def train
    file = id + '.csv'

    training = prediction.trainedmodels.insert.request_schema.new
    training.id = id
    training.storage_data_location = "#{FUTURES[code]}/#{file}"
    authorize_client!
    client.execute(
      api_method:  prediction.trainedmodels.insert,
      headers: {'Content-Type' => 'application/json'},
      body_object: training,
      parameters: {'project' => PROJECT}
    )
  end

  def check_status
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.get,
      parameters: {'id' => id, 'project' => PROJECT}
    )
  end

  def predict(options)
    date = options[:date] || Date.today + 1
    raise 'Invalid day of the week, must be Mon-Fri' if date.cwday > 5
    input = prediction.trainedmodels.predict.request_schema.new
    input.input = {}
    builder = PredictionBuilder.new(location: location, code: code, month: month, year: year)
    input.input.csv_instance = builder.build_prediction_for(date)
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.predict,
      parameters: {'id' => id, 'project' => PROJECT},
      headers: {'Content-Type' => 'application/json'},
      body_object: input
    )
  end

  def update
    unless Date.today.cwday > 5
      input = prediction.trainedmodels.predict.request_schema.new
      input.input = {}
      builder = PredictionBuilder.new(location: location, code: code, month: month, year: year)
      input.input.csv_instance = builder.build_todays_update
      authorize_client!
      client.execute(
        api_method: prediction.trainedmodels.update,
        parameters: {'id' => id, 'project' => PROJECT},
        headers: {'Content-Type' => 'application/json'},
        body_object: input
      )
    end
  end

  def analyze
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.analyze,
      parameters: {'id' => id, 'project' => PROJECT},
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def list
    authorize_client!
    client.execute(
      api_method: prediction.trainedmodels.list,
      parameters: {'project' => PROJECT},
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def delete(options={})
    ids = options[:ids] || id
    ids.each do |model_id|
      authorize_client!
      client.execute(
        api_method: prediction.trainedmodels.delete,
        parameters: {'id' => model_id, 'project' => PROJECT },
        headers: {'Content-Type' => 'application/json'},
      )
    end
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
