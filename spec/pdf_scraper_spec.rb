require 'spec_helper'
require_relative '../pdf_scraper'

RSpec.describe PdfScraper do
  before(:each) do
    ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
    ScraperWiki::sqliteexecute("drop table if exists data")
  end

  describe '#new_mp_line?' do
    it 'should return true when a new MP is detected' do
      expect(subject.send(:new_mp_line?, "                                                                  LEGISLATIVE ASSEMBLY")).to eq(false)
      expect(subject.send(:new_mp_line?, "  BAILEY Honourable Mark Craig BA(UQ)        Yeerongpilly       ALP        3/116 Beaudesert Road, Moorooka Qld 4105                         Ph: 07 3414 2120")).to eq(true)
      expect(subject.send(:new_mp_line?, "O’ROURKE Honourable Coralee Jane [Mrs]       Mundingburra        ALP         Shop 3, 198 Nathan Street, Aitkenvale Qld 4814                     Ph: 07 4766 8100")).to eq(true)
      expect(subject.send(:new_mp_line?, "McEACHAN Matthew John (Matt)                 Redlands           LNP         Tenancy H20, Victoria Point Lakeside, 11-27 Bunker Road,           Ph: 07 3446 0100")).to eq(true)
    end
  end

  describe "#read_names" do
    it 'should return first name and surname' do
      expect(subject.send(:read_names, "  BAILEY Honourable Mark Craig BA(UQ)        Yeerongpilly       ALP        3/116 Beaudesert Road, Moorooka Qld 4105                         Ph: 07 3414 2120")).to eq(['Mark', 'Bailey'])
      expect(subject.send(:new_mp_line?, "O’ROURKE Honourable Coralee Jane [Mrs]       Mundingburra        ALP         Shop 3, 198 Nathan Street, Aitkenvale Qld 4814                     Ph: 07 4766 8100")).to eq(['Coralee', "O'Rourke"])
      expect(subject.send(:new_mp_line?, "McEACHAN Matthew John (Matt)                 Redlands           LNP         Tenancy H20, Victoria Point Lakeside, 11-27 Bunker Road,           Ph: 07 3446 0100")).to eq(['Matthew', 'McEachan'])
    end
  end
end
