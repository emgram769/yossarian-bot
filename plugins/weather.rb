#  weather.rb
#  Author: William Woodruff
#  ------------------------
#  A Cinch plugin that provides Weather Underground interaction for yossarian-bot.
#  ------------------------
#  This code is licensed by William Woodruff under the MIT License.
#  http://opensource.org/licenses/MIT

require 'wunderground'

class Weather
	include Cinch::Plugin

	match /w (.+)/, method: :weather
	match /weather (.+)/, method: :weather

	def weather(m, location)
		if ENV.has_key?('WUNDERGROUND_API_KEY')
			wu = Wunderground.new(ENV['WUNDERGROUND_API_KEY'])
			hash = wu.conditions_for(location)

			unless hash['current_observation'] == nil
				loc = hash['current_observation']['display_location']['full']
				weather = hash['current_observation']['weather']
				temp = hash['current_observation']['temperature_string']
				m.reply "#{m.user.nick}: Current temperature in #{loc} is #{temp} and #{weather}."
			else
				m.reply "#{m.user.nick}: Bad weather query for #{location}."
			end
		else
			m.reply 'Internal error (missing API key).'
		end
	end
end
