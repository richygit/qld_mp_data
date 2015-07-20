require './logging'
require 'scraperwiki'
require 'pdf-reader'
require 'open-uri'

class PdfScraper < Logging
  PDF_HOST = 'www.parliament.qld.gov.au'
  PDF_PATH = '/documents/Members/mailingLists/MEMLIST.pdf'
  PDF_URL = "http://#{PDF_HOST}#{PDF_PATH}"

  def main
    #reader = PDF::Reader.new(open(PDF_URL))
    #TODO debug only
    reader = PDF::Reader.new(open('doc/MEMLIST.pdf'))
    lines = []
    reader.pages.each do |page|
      lines << page.text.split("\n")
    end
    mps = read_data(lines.flatten)
  end

private
  ELECTORATE_START_COL = 43
  PARTY_START_COL = 63
  ADDRESS_START_COL = 74
  PHONE_START_COL = 139

  def read_data(lines)
    buffer = []
    mps = {}
    lines.each do |line|
      if !buffer.empty? && new_mp_line?(line)
        mps.merge(process_mp(buffer)) 
        buffer = []
      else
        buffer << line
      end
    end
    process_mp(buffer) if !buffer.empty?
    mps
  end

  def new_mp_line?(line)
    !!(line =~ /^\s{0,2}[A-Zc\-\’]+\s/)
  end

  def process_mp(lines)
    {}
  end

  def read_names(line)
    words = line.split
    surname = normalise_surname(words[0])
    first_name = (words[1] == "Honourable" words[2] : words[1])
    [first_name, surname]
  end

  def normalise_surname(name)
    name.gsub!('’', "'")
    name.capitalize!
    name[2] = name[2].upcase if name.start_with?('Mc') || (name =~ /'/)
    name
  end

  def read_mp_details(lines)
    tel = nil
    surname = nil
    electorate = nil
    lines.reverse.each do |line|
      if matches = line.match(/Tel:\s*(\(\d{2}\)\s*\d{4}\s*\d{4})$/)
        tel = matches[1]
      end
      if surname_match = line.match(/^\**(\w[^,]*),/)
        surname = surname_match[1]
      end

      line = line[MP_ELECTORATE_START_COL..MP_EMAIL_START_COL]
      if line && line.index(',')
        electorate = line.split(',').first.strip.chomp(',')
      end
      return [tel, surname.gsub('*', ''), electorate] if electorate && surname && tel
    end
    @logger.warn("No MP logged for: #{lines}")
    nil
  end
  
end
