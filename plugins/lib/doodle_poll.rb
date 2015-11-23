require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

# This class parses doodle polls and is able to output
# statistical information about them
class DoodlePoll
  attr_accessor :url

  def initialize(url)
    @url = url
    parse_doodle_html
    construct_datehash
  end

  def dates
    date_string = '%a %F'
    @date_objects.map { |date| date.strftime(date_string) } * ', '
  end

  def dates_counts
    @date_hash.map { |k, v| "#{k.strftime('%F')} [#{v.count}]" } * ', '
  end

  def least_voted_dates(date_hash)
    date_hash.select { |_, v| v == date_hash.values.min }
  end

  def most_voted_dates(date_hash)
    date_hash.select { |_, v| v == date_hash.values.max }
  end

  def winner
    dates = most_voted_dates(@date_hash).keys
    dates.map! { |k| k.strftime('%a %F') }
    (dates.count > 1 ? 'It\'s a tie for: ' : 'The winner is: ') + dates * ', '
  end
  alias_method :winners, :winner

  def loser
    dates = least_voted_dates(@date_hash).keys
    dates.map! { |k| k.strftime('%a %F') }
    (dates.count > 1 ? 'It\'s a tie for: ' : 'The loser is: ') + dates * ', '
  end
  alias_method :losers, :loser

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
  alias_method :participants, :people

  private

  # Parse the doodle html's javascript
  # sets variables:
  # * @people : array of all participants
  # * @raw_dates : array of dates in US format
  # * @date_objects : array of strptime parsed Date objects
  def parse_doodle_html
    doc = Nokogiri::HTML(open(@url))
    scriptdata = doc.xpath('//script')[9]

    @people = JSON.parse(/"participants":(\[{.+?}\])/.match(scriptdata)[1])
    @raw_dates = JSON.parse(/"optionsText":(\[.+?\])/.match(scriptdata)[1])
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
