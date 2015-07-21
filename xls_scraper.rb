require 'spreadsheet'
require 'open-uri'
require 'titleize'
require './logging'

class XlsScraper < Logging

  def scrape
    book = Spreadsheet.open(open('https://www.parliament.qld.gov.au/documents/Members/mailingLists/MEMMERGEEXCEL.xls'))
    sheet = book.worksheet(0)
    mps = []
    sheet.each_with_index do |row, index|
      next if index == 0
      mp = {}
      mp[:last_name] = row[2].gsub(' MP','')
      mp[:electorate] = row[3].gsub('Member for ', '')
      office = parse_office_address(row)
      mp[:office_address] = office[0].strip
      mp[:office_suburb] = office[1].strip
      mp[:office_state] = office[2].strip
      mp[:office_postcode] = office[3].strip
      mp[:party] = row[9]
      mps << mp
    end
    mps
  end

  def parse_office_address(row)
    if row[7].strip.length > 0
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
