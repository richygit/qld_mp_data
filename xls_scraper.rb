require 'spreadsheet'
require 'open-uri'
require 'titleize'
require './logging'

class XlsScraper < Logging

  XLS_HOST = 'www.parliament.qld.gov.au'
  XLS_PATH = '/documents/Members/mailingLists/MEMMERGEEXCEL.xls'
  XLS_URL = "https://#{XLS_HOST}#{XLS_PATH}"

  def scrape
    book = Spreadsheet.open(open(XLS_URL))
    sheet = book.worksheet(0)
    records = {}
    sheet.each_with_index do |row, index|
      next if index == 0
      mp = {}
      mp[:last_name] = row[2].gsub(' MP','')
      office = parse_office_address(row)
      mp[:office_address] = office[0].strip
      mp[:office_suburb] = office[1].strip
      mp[:office_state] = office[2].strip
      mp[:office_postcode] = office[3].strip
      mp[:party] = row[9]
      electorate = row[3].gsub('Member for ', '')
      records[electorate] = mp
    end
    records
  end

  def parse_office_address(row)
    if row[7] && row[7].strip.length > 0
      street_address = "#{row[5]} #{row[6]}"
      res = row[7].scan(/(.+)\s(.+)\s(\d{4})/).flatten.map(&:strip)
    else
      street_address = row[5]
      res = row[6].scan(/(.+)\s(.+)\s(\d{4})/).flatten.map(&:strip)
    end

    street_address.squeeze!(' ')
    res[0].titleize!
    [street_address, res].flatten
  end
end
