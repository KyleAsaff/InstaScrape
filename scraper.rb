require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'

# Base Instagram URL
BASE_URL = 'https://instagram.com/'

# List of usernames to scrape
HANDLE_LIST = ["KyleAsaff", "NBA", "football", "espn", "tsn", "sportsillustrated", "HBO"]

# Keywords to use to match in bio
KEY_PHRASES = ["sports", "hbo"]

# Generate new CSV with correct headers
CSV.open("output.csv", "wb") do |csv|
  csv << ["Brand Handle", "Website", "Follower Count", "Following Count"]
end

# Scrape each username in array
HANDLE_LIST.each do |handle|
  doc = Nokogiri.HTML(open(BASE_URL+handle))
  raw = doc.css('script')[5].text
  trim = raw.match(/window._sharedData = ((.*));/)[1]
  # Parse plain text to JSON
  data = JSON.parse(trim)

  # Skip if nil
  if (data["entry_data"]["ProfilePage"][0]["user"] rescue nil).nil?
    puts "<Error> Skipping "+handle+"..."
    next
  end
  puts "Checking "+handle+"..."

  data = data["entry_data"]["ProfilePage"][0]["user"]

  KEY_PHRASES.each do |phrase|
    # format data for non case-sensitive exact phrase match ignoring punctuation
    phrase = phrase.downcase.gsub(/[^#a-z0-9\s]/i, '')
    phrase = phrase.center(phrase.length+2)
    stripped = data["biography"].downcase.gsub(/[^#a-z0-9\s]/i, '')
    stripped = stripped.center(stripped.length+2)
    # check if bio includes key phrase
    if stripped.include? phrase
      user = [{
                'username' => data["username"],
                'external_url' => data["external_url"],
                'followed_by' => data["followed_by"]["count"],
                'follows' => data["follows"]["count"],
      }]
      # save accounts with a positive match to CSV
      CSV.open("output.csv", "ab") do |csv|
        user.each do |x|
          csv << x.values
        end
      end
      break
    end
  end
end
