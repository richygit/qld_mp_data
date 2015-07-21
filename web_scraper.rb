require 'mechanize'
require 'fileutils'
require './logging'

#get social media contact details of MPs
class WebScraper < Logging

  SEARCH_HOST = 'www.parliament.qld.gov.au'
  INDEX_PATH = '/members/current/list'
  INDEX_URL = "http://#{SEARCH_HOST}#{INDEX_PATH}"

  def scrape
    records = {}
    agent = Mechanize.new
    p "Scraping: #{INDEX_URL}"
    page = agent.get INDEX_URL
    
    records = {}
    page.search('.members-list .right-thumbnail a').each do |member_link|
      electorate, mp = scrape_mp_page(member_link.attr(:href))
      records[electorate] = mp
    end
    records
  end

  def scrape_mp_page(path)
    agent = Mechanize.new
    url = "http://#{SEARCH_HOST}#{path}"
    p "Scraping: #{url}"
    page = agent.get url

    mp = {}
    name = page.search('.member-heading h1').first.inner_text.split
    mp[:first_name] = parse_first_name(name)
    contact = page.search('.member-bio > p')[1]
    mp[:parliament_phone] = contact.children[1].inner_text.strip
    mp[:parliament_fax] = contact.children[3].inner_text.strip
    mp[:email] = contact.children[6].inner_text
    electorate = page.search('.member-bio div.left p')[0].inner_text.scan(/^\s*Electorate\s*(.+)\s-/).flatten[0]
    [electorate, mp]
  end

  def parse_first_name(name)
    if name[0] =~ /Hon|Mr|Miss|Mrs|Ms|Dr/
      name[1] 
    else
      name[0]
    end
  end

  #`office_fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,

end
