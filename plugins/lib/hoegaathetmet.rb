require 'google-search'
require 'nokogiri'

# Scrape linkedin for current occupation
class HoeGaatHetMet
  def initialize(name)
    @query_name = name
    load_profile
  end

  def name
    @name ||= @profile.css('h1.fn').text
  end

  def headline
    @headline ||= @profile.css('div.profile-overview-content').css('p.headline').text
  end

  def load_profile
    company = 'Nxs Internet B.V.'
    query = "site:nl.linkedin.com/pub #{company}"
    results = Google::Search::Web.new(query: "#{query} \"#{@query_name}\"")
    uri = results.first.uri
    if uri =~ %r{nl\.linkedin\.com/pub/dir/}
      profile_list = Nokogiri::HTML(open(uri)).css('ul.content').css('li')
      profile_uri = profile_list.at("li:contains(\"#{company}\")").css('a.public-profile-link').attr('href').value
      @profile = Nokogiri::HTML(open(profile_uri))
    else
      @profile = Nokogiri::HTML(open(uri))
    end
  end
end
