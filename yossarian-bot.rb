#!/usr/bin/env ruby

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
require_relative 'yossarian-helpers'

BOT_VERSION = 0.7

options = {:links => true}

OptionParser.new do |opts|
	opts.banner = "Usage: $0 <irc server> <channels> [options]"

	opts.on('-n', '--no-link-titles', 'Do not title links.') do |n|
		options[:links] = false
	end
end.parse!

bot = Cinch::Bot.new do
	configure do |c|
		c.nick = "yossarian-bot"
		c.realname = "yossarian-bot"
		c.max_messages = 1
		c.server = ARGV[0]
		c.channels = ARGV[1].split(',')
	end

	on :message, /^[.!:]help$/ do |m|
		User(m.user.nick).send(list_help, true)
	end

	on :message, /^[.!:]help (.+)/ do |m, cmd|
		User(m.user.nick).send(cmd_help(cmd), true)
	end

	on :message, /^[.!:]bots/ do |m|
		m.reply "Reporting in! [Ruby] Use !help for commands."
	end

	on :message, "!author" do |m|
		m.reply "Author: cpt_yossarian (woodruffw)"
	end

	on :message, "!botver" do |m|
		m.reply "yossarian-bot version #{BOT_VERSION}"
	end

	on :message, /^!s(?:ou)?rc/ do |m|
		m.reply "https://github.com/woodruffw/yossarian-bot"
	end

	on :message, "!c22" do |m|
		m.reply random_quote
	end

	on :message, "!fortune" do |m|
		m.reply unix_fortune
	end

	on :message, /^!say (.+)/ do |m, msg|
		m.reply msg
	end

	on :message, /^!pmsg (.+?) (.+)/ do |m, user, msg|
		User(user).send "#{user}: #{msg} (#{m.user.nick})"
	end

	on :message, /^!ud (.+)/ do |m, word|
		m.reply "#{m.user.nick}: #{urban_dict(word)}"
	end

	on :message, /^!wa (.+)/ do |m, query|
		m.reply "#{m.user.nick}: #{wolfram_alpha(query)}"
	end

	on :message, /^!w(?:eather)? (.+)/ do |m, location|
		m.reply "#{m.user.nick}: #{weather(location)}"
	end

	on :message, /^!g(?:oogle)? (.+)/ do |m, search|
		m.reply "#{m.user.nick}: #{google(search)}"
	end

	on :message, /^!rot13 (.+)/ do |m, msg|
		m.reply "#{m.user.nick}: #{rot13(msg)}"
	end

	on :message, /^!8ball [A-Za-z0-9\-_ ]+\?$/ do |m|
		m.reply "#{m.user.nick}: #{random_8ball}"
	end

	on :message, /^!define ([a-zA-Z]+)/ do |m, word|
		m.reply "#{m.user.nick}: #{define_word(word)}"
	end

	on :message, /^!cb (.+)/ do |m, query|
		m.reply "#{m.user.nick}: #{cleverbot(query)}"
	end
	
	if options[:links]
		on :message, /(http(s)?:\/\/[^ \t]*)/ do |m, link|
			title = link_title(link)
			unless title.empty?
				m.reply "Title: \"#{title}\""
			end
		end
	end

	on :ctcp, "VERSION" do |m|
		m.reply "yossarian-bot version #{BOT_VERSION}"
	end
end

bot.start
