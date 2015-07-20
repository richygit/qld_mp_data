require 'spreadsheet'
require 'open-uri'
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
    full_address = "#{row[5]} #{row[6]} #{row[7]}"
    full_address.scan(/(.+)\s(.+)\s(.+)\s(\d{4})/).flatten
  end

  #`first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`parliament_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`parliament_fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  
end
