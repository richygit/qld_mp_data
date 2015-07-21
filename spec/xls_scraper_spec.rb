require_relative '../xls_scraper'
require 'open-uri'
require 'spec_helper'

describe XlsScraper do
  it "can download the CSV files" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::MP_CSV_PATH).code).to eq "200" }
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::SENATOR_CSV_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr, focus: true do
    it "scrapes details correctly" do
      records = subject.scrape
      p records
    end
  end

  describe "#parse_office_address" do
    it "scrapes office address" do
      row = ['','','','','','Shops 3 & 4 ', ' 137 Parkwood Drive', 'HEATHWOOD  QLD  4110']
      expect(subject.parse_office_address(row)).to eq(['Shops 3 & 4 137 Parkwood Drive', 'Heathwood', 'QLD', '4110'])
      row = ['','','','','','PO Box 2093', ' BURLEIGH WATERS  QLD  4220', '']
      expect(subject.parse_office_address(row)).to eq(['PO Box 2093', 'Burleigh Waters', 'QLD', '4220'])
    end
  end

end
