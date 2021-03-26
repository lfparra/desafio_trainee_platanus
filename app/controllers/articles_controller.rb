require 'json'
require 'rest-client'

class ArticlesController < ApplicationController

  def index

    url_markets = 'https://www.buda.com/api/v2/markets'

    # Request mercados BUDA
    
    response_request_markets = RestClient::Request.execute(method: :get, url: url_markets)
    result_request_markets = JSON.parse response_request_markets.to_str
    markets = result_request_markets['markets']
    
    # Loop para identificar id/nombre del mercado
    
    markets_names = []
    markets.each do |markets|
        markets_names.push(markets['id'])
    end
    #puts markets_name
    
    dict_markets_status = []
    count = 0
    # Loop para generar url para get status de cada mercado
    markets_names.each do |market_name|
      response_request_market_status = RestClient::Request.execute(method: :get, url: "https://www.buda.com/api/v2/markets/#{market_name}/ticker")
      
      #puts response_request_market_status.code
      
      result_request_market_status = JSON.parse response_request_market_status.to_str
      
      # Acceso a mejores oferta de compra y venta para cada mercado
      max_bid_market = result_request_market_status['ticker']['max_bid']
      min_ask_market = result_request_market_status['ticker']['min_ask']
      
      # Diccionario con mercado y mejores ofertas últimas 24 horas
      
      dict_markets_status[count] = {'id' => count, 
          'market_name' => market_name, 
          'max_bid' => {'amount' => ActiveSupport::NumberHelper::number_to_currency(max_bid_market[0], delimiter: '.', separator: ',', precision: 2), 
          'currency' => max_bid_market[1]}, 
          'min_ask' => {'amount' => ActiveSupport::NumberHelper::number_to_currency(min_ask_market[0], delimiter: '.', separator: ',', precision: 2), 
          'currency' => min_ask_market[1]}
        }
      #puts dict_markets_status[count]['max_bid']['amount']
       
      count = count + 1
    end



    puts ActiveSupport::NumberHelper::number_to_delimited(dict_markets_status[1]['max_bid']['amount'], delimiter: '.', separator: ',' )

    @markets = dict_markets_status
    @time = Time.now
  
  end
end
