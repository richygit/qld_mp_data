require_relative '../xls_scraper'
require 'open-uri'
require 'spec_helper'

describe XlsScraper do
  it "can download the CSV files" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(XlsScraper::XLS_HOST, 80) {|http| expect(http.head(XlsScraper::XLS_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes details correctly" do
      records = subject.scrape
      expect(records['Springwood']).to eq({last_name: 'de Brenni', office_address: 'Shops 4-6, Springwood Rd Business Centre 71-73 Springwood Road', office_suburb: 'Springwood', office_state: 'QLD', office_postcode: '4127', party: 'ALP'})
      expect(records['Redcliffe']).to eq({last_name: "D'Ath", office_address: 'PO Box 936', office_suburb: 'Redcliffe', office_state: 'QLD', office_postcode: '4020', party: 'ALP'})
      expect(records.count).to eq(89)
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
