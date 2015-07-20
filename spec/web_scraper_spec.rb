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
    it "finds the right number of MP pages" do
      allow(subject).to receive(:scrape_mp_page).exactly(89).times
      records = subject.scrape
    end

    it 'scrapes all the details', focus: true do
      records = subject.scrape
    end
  end

  describe "#scrape_mp_page", :vcr do
    it "scrapes MP data" do
      path = '/members/current/list/MemberDetails?ID=1051370424'
      subject.scrape_mp_page(path)
    end
  end
end
