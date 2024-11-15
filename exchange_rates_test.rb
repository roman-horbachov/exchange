require 'minitest/autorun'
require_relative 'exchange_rates'
require 'csv'

class ExchangeRateFetcherTest < Minitest::Test
  def setup
    @base_currency = 'USD'
    @fetcher = ExchangeRateFetcher.new(@base_currency)
    @mock_response = {
      'result' => 'success',
      'conversion_rates' => {
        'EUR' => 0.85,
        'GBP' => 0.75,
        'JPY' => 110.0
      }
    }.to_json
  end

  def test_fetch_rates
    Net::HTTP.stub(:get, @mock_response) do
      rates = @fetcher.fetch_rates
      assert_equal JSON.parse(@mock_response)['conversion_rates'], rates
    end
  end

  def test_parse_response
    rates = @fetcher.parse_response(@mock_response)
    assert_equal JSON.parse(@mock_response)['conversion_rates'], rates
  end

  def test_save_to_csv
    rates = { 'EUR' => 0.85, 'GBP' => 0.75, 'JPY' => 110.0 }
    file_name = 'test_exchange_rates.csv'
    @fetcher.save_to_csv(rates, file_name)

    assert File.exist?(file_name), 'CSV file should be created'

    csv_data = CSV.read(file_name, headers: true)
    assert_equal %w[Валюта Курс], csv_data.headers # Українські заголовки
    assert_equal 'EUR', csv_data[0]['Валюта']
    assert_equal '0.85', csv_data[0]['Курс']
  ensure
    File.delete(file_name) if File.exist?(file_name)
  end
end