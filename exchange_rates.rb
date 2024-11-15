require 'net/http'
require 'json'
require 'csv'

class ExchangeRateFetcher
  API_URL = 'https://v6.exchangerate-api.com/v6/416f1f0acd12a7410b4c9967/latest'

  def initialize(base_currency)
    @base_currency = base_currency
  end

  def fetch_rates
    url = "#{API_URL}/#{@base_currency}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    parse_response(response)
  end

  def parse_response(response)
    data = JSON.parse(response)
    if data['result'] == 'success'
      data['conversion_rates']
    else
      raise "API Error: #{data['error-type']}"
    end
  end

  def save_to_csv(rates, file_name = 'exchange_rates.csv')
    CSV.open(file_name, 'w') do |csv|
      csv << ['Валюта', 'Курс']
      rates.each do |currency, rate|
        csv << [currency, rate]
      end
    end
  end
end

# Example usage
if __FILE__ == $0
  base_currency = 'USD'
  fetcher = ExchangeRateFetcher.new(base_currency)
  rates = fetcher.fetch_rates
  fetcher.save_to_csv(rates)
  puts "Курси валют збережені в exchange_rates.csv"
end
