#!/usr/bin/env ruby
#  -*- coding: utf-8 -*-
#  yossarian-bot.rb
#  Author: William Woodruff
#  ------------------------
#  A call-and-response IRC bot for entertainment.
#  Allows users to query UrbanDictionary, Wolfram|Alpha, and other sites.
#  Also spits out fortunes, Catch-22 quotes, and more.
#  ------------------------
#  This code is licensed by William Woodruff under the MIT License.
#  http://opensource.org/licenses/MIT

require 'cinch'
require 'optparse'
require 'yaml'

require_relative 'plugins/command_help'
require_relative 'plugins/bot_info'
require_relative 'plugins/bot_admin'
require_relative 'plugins/catch22'
require_relative 'plugins/urban_dictionary'
require_relative 'plugins/wolfram_alpha'
require_relative 'plugins/weather'
require_relative 'plugins/google_search'
require_relative 'plugins/google_translate'
require_relative 'plugins/youtube_search'
require_relative 'plugins/magic8ball'
require_relative 'plugins/merriam_webster'
require_relative 'plugins/cleverbot'
require_relative 'plugins/fortune'
require_relative 'plugins/rot13'
require_relative 'plugins/last_seen'
require_relative 'plugins/tiny_url'
require_relative 'plugins/github_info'
require_relative 'plugins/xkcd_comics'
require_relative 'plugins/isitup'
require_relative 'plugins/hastebin'
require_relative 'plugins/slap'
require_relative 'plugins/zalgo/zalgo'
require_relative 'plugins/user_intros/user_intros'
require_relative 'plugins/user_quotes/user_quotes'
require_relative 'plugins/ctcp_version'
require_relative 'plugins/regex_replace'
require_relative 'plugins/link_titling'

$BOT_VERSION = 1.55
$BOT_STARTTIME = Time.now
$BOT_ADMINS = []
$BOT_PLUGINS = [
	CommandHelp,
	BotInfo,
	BotAdmin,
	Catch22,
	UrbanDictionary,
	WolframAlpha,
	Weather,
	GoogleSearch,
	GoogleTranslate,
	YouTubeSearch,
	Magic8Ball,
	MerriamWebster,
	Cleverbot,
	Fortune,
	Rot13,
	TinyURL,
	GitHubInfo,
	XKCDComics,
	IsItUp,
	Hastebin,
	Slap,
	Zalgo,
	UserIntros,
	UserQuotes,
	CTCPVersion,
	LastSeen,
	LinkTitling,
	RegexReplace
]

config_file = File.expand_path(File.join(File.dirname(__FILE__), 'config.yml'))
config_options = {}

if File.file?(config_file)
	config_options = YAML::load_file(config_file)
else
	abort('Fatal: Could not find a config.yml to load from.')
end

$BOT_ADMINS = config_options['admins'] or []

flags = {
	:links => true,
	:seen => true,
	:regex => true,
	:intros => true,
	:quotes => true
}

OptionParser.new do |opts|
	opts.banner = "Usage: $0 <irc server> <channels> [flags]"

	opts.on('-t', '--no-link-titles', 'Do not title links.') do |t|
		flags[:links] = false
	end

	opts.on('-s', '--no-seen', 'Disable the !seen command.') do |s|
		flags[:seen] = false
	end

	opts.on('-r', '--no-regex-replace', 'Disable sed-like regexes for typos.') do |r|
		flags[:regex] = false
	end

	opts.on('-i', '--no-intros', 'No custom user intros.') do |i|
		flags[:intros] = false
	end

	opts.on('-q', '--no-quotes', 'No !quote collection.') do |q|
		flags[:quotes] = false
	end
end.parse!

bot = Cinch::Bot.new do
	configure do |c|
		c.nick = config_options['nick'] or 'yossarian-bot'
		c.realname = 'yossarian-bot'
		c.user = 'yossarian-bot'
		c.max_messages = 1
		c.server = config_options['server'] or abort('Fatal: Missing \'server\' field in config.yml')
		c.channels = config_options['channels'] or abort('Fatal: Missing \'channels\' field in config.yml')
		c.plugins.prefix = Regexp.new(config_options['prefix']) or /^!/
		c.plugins.plugins = $BOT_PLUGINS.dup

		unless flags[:seen]
			c.plugins.plugins.delete(LastSeen)
		end

		unless flags[:links]
			c.plugins.plugins.delete(LinkTitling)
		end

		unless flags[:regex]
			c.plugins.plugins.delete(RegexReplace)
		end

		unless flags[:intros]
			c.plugins.plugins.delete(UserIntros)
		end

		unless flags[:quotes]
			c.plugins.plugins.delete(UserQuotes)
		end
	end

	on :message, /^[!.:,]bots$/ do |m|
		m.reply 'Reporting in! [Ruby] See !help for commands.'
	end
end

bot.start
