require 'spec_helper'
require_relative '../scraper_main'

RSpec.describe ScraperMain do

  describe "#main", :vcr do
    before(:each) do
      ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
      ScraperWiki::sqliteexecute("drop table if exists data")
    end
    
    it "should merge member info" do
        subject.main
        caloundra = ScraperWiki::select('* FROM data WHERE electorate = "Caloundra"')
        expect(caloundra.first).to eq(CALOUNDRA_RECORD)
        expect(ScraperWiki::select('* FROM data').count).to eq(89)
    end
  end

  CALOUNDRA_RECORD = {"last_name"=>"McArdle",
   "office_address"=>"PO Box 3998",
   "office_suburb"=>"Caloundra Dc",
   "office_state"=>"QLD",
   "office_postcode"=>"4551",
   "party"=>"LNP",
   "first_name"=>"Mark",
   "parliament_phone"=>"(07)5329 4100",
   "parliament_fax"=>"(07) 5329 4109",
   "email"=>"Caloundra@parliament.qld.gov.au",
   "electorate"=>"Caloundra"}
end
