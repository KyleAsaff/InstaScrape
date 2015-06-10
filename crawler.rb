require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'

BASE_URL = 'https://instagram.com/'
HANDLE_LIST = ["KyleAsaff", "NBA"];


HANDLE_LIST.each do |handle|
  doc = Nokogiri.HTML(open(BASE_URL+handle))
  raw = doc.css('script')[5].text
  trim = raw.match(/window._sharedData = ((.*));/)[1]
  data = JSON.parse(trim)
  data = data["entry_data"]["ProfilePage"][0]["user"];

  user = {
	  :username => data["username"],
	  :biography => data["biography"],
	  :follows => data["follows"]["count"],
	  :followed_by => data["followed_by"]["count"],
	  :external_url => data["external_url"]
  }
  puts user
end