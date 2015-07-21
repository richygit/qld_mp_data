require 'spec_helper'
require_relative '../web_scraper'

RSpec.describe WebScraper do
  it "can download the search page" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(WebScraper::SEARCH_HOST, 80) {|http| expect(http.head(WebScraper::INDEX_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes MP the right number of MPs" do
      allow(subject).to receive(:scrape_mp_page).exactly(89).times
    end

    it "scrapes MP data correctly" do
      records = subject.scrape
      expect(records['Capalaba']).to eq({first_name: 'Donald', parliament_phone: '(07) 3915 0100', parliament_fax: '(07) 3915 0109', email: 'Capalaba@parliament.qld.gov.au'})
      expect(records['Surfers Paradise']).to eq({first_name: 'John-Paul', parliament_phone: '(07) 5600 2100', parliament_fax: '(07) 5600 2109', email: 'Surfers.Paradise@parliament.qld.gov.au'})
    end
  end

  describe "#scrape_mp_page", :vcr do
    it "scrapes MP data" do
      path = '/members/current/list/MemberDetails?ID=1051370424'
      subject.scrape_mp_page(path)
    end
  end
end
