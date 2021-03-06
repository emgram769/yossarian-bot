#  -*- coding: utf-8 -*-
#  youtube_search.rb
#  Author: William Woodruff
#  ------------------------
#  A Cinch plugin that provides YouTube interaction for yossarian-bot.
#  ------------------------
#  This code is licensed by William Woodruff under the MIT License.
#  http://opensource.org/licenses/MIT

require 'json'
require 'open-uri'

require_relative 'yossarian_plugin'

class YouTubeSearch < YossarianPlugin
	include Cinch::Plugin

	def usage
		'!yt <search> - Search YouTube. Alias: !youtube.'
	end

	def match?(cmd)
		cmd =~ /^(!)?(youtube)|(yt)$/
	end

	match /yt (.+)/, method: :youtube_search, strip_colors: true
	match /youtube (.+)/, method: :youtube_search, strip_colors: true

	def youtube_search(m, search)
		url = URI.encode("http://gdata.youtube.com/feeds/api/videos?q=#{search}&max-results=1&v=2&prettyprint=false&alt=json")
		hash = JSON.parse(open(url).read)

		if hash['feed']['openSearch$totalResults']['$t'] != 0
			entry = hash['feed']['entry'][0]
			title = entry['title']['$t']
			uploader = entry['author'][0]['name']['$t']
			video_id = entry['media$group']['yt$videoid']['$t']

			m.reply "#{title} [#{uploader}] - https://youtu.be/#{video_id}", true
		else
			m.reply "No results for #{search}.", true
		end
	end
end