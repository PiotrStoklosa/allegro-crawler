require 'bundler/setup'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'json'
require 'sequel'

DB_lego = Sequel.connect('sqlite://lego.db')

DB_lego.create_table? :product do
  primary_key :id
  String :name
  String :url
end

def get_page(uri)
  url = URI.parse(uri)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == 'https')
  request = Net::HTTP::Get.new(url.request_uri)
  response = http.request(request)
  if response.code.to_i == 200
    Nokogiri::HTML(response.body)
  else
    puts "Error while retrieving the page. Status code: #{response.code}"
    nil
  end
end

def get_specific_details(page)

  availability_span = page.at('span:contains("Dostępność:")')
  if availability_span
    puts 'Availability: ' + availability_span.xpath('following-sibling::strong').text.strip
  end

  shipment_time = page.at('span:contains("Czas wysyłki:")')
  if shipment_time
    puts 'Shipping time: ' + shipment_time.xpath('following-sibling::strong').text.strip
  end

  shipment_cost = page.at('#InfoOpisWysylka')

  if shipment_cost
    shipment_cost = shipment_cost.text.strip
    shipment_cost_match = shipment_cost.match(/od (\d+ zł)/)
    puts 'Shipment cost: ' + shipment_cost_match[0]
  end

  accession_number = page.at('span:contains("Numer katalogowy:")')
  if accession_number
    puts 'Accession number: ' + accession_number.xpath('following-sibling::strong').text.strip
  end

end

def scrape_page(uri)
  page = get_page(uri)
  if page
    script_data = page.xpath('//script[contains(text(),"view_item_list")]').text

    json_data = script_data.match(/"items":\s*(\[[^\]]+\])/)
    if json_data
      items_data = eval(json_data[1])
      items_data = items_data.map { |item| item.transform_keys(&:to_s) }

      items_data.each do |item|
        puts "Name: #{item['name']}"
        puts "Brand: #{item['brand']}"
        puts "Price: #{item['price']}#{item['currency']}"

        link = page.at("h3 a[title='#{item['name']}']")
        href = link['href']
        detailed_page = get_page(href)
        if detailed_page
          puts "---"
          puts "Details"
          get_specific_details(get_page(href))
        end
        DB_lego[:product].insert(name: item['name'], url: href)
        puts "----------------------"
      end
    else
      puts "No products found"
    end
  end
end

uri = 'https://sklepklocki.pl'
search_uri = uri + '/szukaj.html/szukaj='

combined_arguments = ARGV.join('%20').gsub(' ', "%20")
search_uri = search_uri + combined_arguments
scrape_page(search_uri)
