require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

# This class parses doodle polls and is able to output
# statistical information about them
class DoodlePoll
  attr_accessor :url
  attr_reader :final_pick
  attr_reader :venue
  attr_reader :address

  def initialize(url)
    @url = url
    parse_doodle_html
    construct_datehash
  end

  def self.help
    filter = [:url=, :least_voted_dates, :most_voted_dates, :debug, :bla, :test]
    (instance_methods(false) - filter).join(', ')
  end

  def dates
    date_string = '%a %F'
    @date_objects.map { |date| date.strftime(date_string) } * ', '
  end

  def dates_counts
    @date_hash.map { |k, v| "#{k.strftime('%F')} [#{v.count}]" } * ', '
  end

  def least_voted_dates(date_hash)
    min_count = date_hash.values.min_by(&:count).count
    date_hash.select { |_, v| v.count == min_count }
  end

  def most_voted_dates(date_hash)
    max_count = date_hash.values.max_by(&:count).count
    date_hash.select { |_, v| v.count == max_count }
  end

  def winner
    dates = most_voted_dates(@date_hash).keys
    dates.map! { |k| k.strftime('%a %F') }
    (dates.count > 1 ? 'It\'s a tie for: ' : 'The winner is: ') + dates * ', '
  end
  alias winners winner

  def loser
    dates = least_voted_dates(@date_hash).keys
    dates.map! { |k| k.strftime('%a %F') }
    (dates.count > 1 ? 'It\'s a tie for: ' : 'The loser is: ') + dates * ', '
  end
  alias losers loser

  def runner_up
    temp_dates = most_voted_dates(@date_hash).keys
    temp_date_hash = @date_hash.reject { |k, _| temp_dates.include? k }
    dates = most_voted_dates(temp_date_hash).keys
    dates.map! { |k| k.strftime('%a %F') }
    (dates.count > 1 ? 'The runner-ups: ' : 'The runner-up: ') + dates * ', '
  end

  def people
    @people.map { |p| p['name'] } * ', '
  end
  alias participants people

  def debug
    JSON.generate(
      [
        @url, @people, @raw_dates, @final_pick,
        @location, @address, @venue, @date_objects
      ]
    )
  end

  private

  # Use regexps to retrieve specific pieces of information from embedded JS
  def parse_doodle_js(scriptdata, regexp, returnval = nil)
    if regexp =~ scriptdata
      JSON.parse(Regexp.last_match(1))
    else
      returnval
    end
  end

  # Parse the doodle html's javascript
  # sets variables:
  # * @people : array of all participants
  # * @raw_dates : array of dates in US format
  # * @date_objects : array of strptime parsed Date objects
  def parse_doodle_html
    doc = Nokogiri::HTML(open(@url))
    scriptdata = doc.xpath('//script').select do |node|
      node.content.include?("\"prettyUrl\":\"#{@url}\"")
    end[0]

    @people = parse_doodle_js(scriptdata, /"participants":(\[{.+?}\])/, [])
    @raw_dates = parse_doodle_js(scriptdata, /"optionsText":(\[.+?\])/, [])
    @final_pick = if /"finalPicksText":"(.+?)"/ =~ scriptdata
                    Regexp.last_match(1)
                  end
    @location = parse_doodle_js(scriptdata, /"location":(\{.+?\})/, {})
    @address = @location['address'] || nil
    @venue = @location['name'] || nil
    date_string = '%a %m/%d/%y'
    @date_objects = @raw_dates.map { |date| Date.strptime(date, date_string) }
  end

  # Construct datehash from participants and dates
  # returns:
  # * datehash : hash of dates with arrays of people who voted yes
  def construct_datehash
    @date_hash = {}

    @date_objects.each_with_index do |date, index|
      @people.each do |person|
        next if person['preferences'][index] == 'n'

        @date_hash[date] ||= []
        @date_hash[date] << person['name']
      end
    end
  end
end
