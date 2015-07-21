require 'scraperwiki'
require './logging'

require_relative 'web_scraper'
require_relative 'xls_scraper'

class ScraperMain < Logging

  def initialize
    super
    @logger = Logger.new($stdout)
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
  end

  def main
    @logger.info 'Scraping XLS'
    xls = XlsScraper.new.scrape
    @logger.info 'Scraping web'
    web = WebScraper.new.scrape
    records = merge(xls, web)
    records.each do |electorate, record|
      @logger.info("### Saving #{record[:first_name]} #{record[:last_name]}")
      puts("### Saving #{record[:first_name]} #{record[:last_name]}")
      ScraperWiki::save(['electorate'], record.merge( 'electorate' => electorate ))
    end
  end

  def merge(xls, web)
    xls.merge(web) {|key, xls_val, web_val| xls_val.merge(web_val)}
  end
end
