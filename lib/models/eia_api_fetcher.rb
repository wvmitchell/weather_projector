class EnergyInformationAdminFetcher
  include HTTParty
  base_uri 'http://api.eia.gov/series/'
  default_params api_key: ENV['EIA_API_KEY']

  def northeast_weekly_stocks
    klass.get('/', query: {series_id: 'PET.WCESTP11.W'})
  end

  def klass
    self.class
  end

end
