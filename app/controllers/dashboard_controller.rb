require 'open-uri'
require 'timeout'
require 'date'

class DashboardController < ApplicationController

	def main
		swizzleURLHashArray = [
			{:title => 'S2', :url => 'http://swizzle2.tripcase.com/status', :link => 'http://swizzle2.tripcase.com/login'},
			{:title => 'S2', :url => 'http://swizzle2.tripcase.com/touch2/status', :link => 'http://swizzle2.tripcase.com/tdot'},
			{:title => 'S3', :url => 'http://ctovm2417.dev.sabre.com/status', :link => 'http://ctovm2417.dev.sabre.com/login'},
			{:title => 'S3', :url => 'http://ctovm2417.dev.sabre.com/touch2/status', :link => 'http://ctovm2417.dev.sabre.com/tdot'},
			{:title => 'S4', :url => 'http://ctovm2418.dev.sabre.com/status', :link => 'http://ctovm2418.dev.sabre.com/login'},
			{:title => 'S4', :url => 'http://ctovm2418.dev.sabre.com/touch2/status', :link => 'http://ctovm2418.dev.sabre.com/tdot'},
			{:title => 'S5', :url => 'http://swizzle5.tripcase.com/status', :link => ''},
			{:title => 'S5', :url => 'http://swizzle5.tripcase.com/touch2/status', :link => ''}
			# {:title => 'S6', :url => 'ltxl0208.sgdcelab.sabre.com', :link => ''}
		]

		#hash contents: {:title, :branch, :date, :deployer, :commitCode, :lastCommitTime, :link}
		@swizzleHTMLHashArray = []

		swizzleURLHashArray.each { |swizzle|
			swizzleHash = {}
			open(swizzle[:url]) { | response |
				response.each_line {| line |
					if !(line.strip.empty?)
						formatHTMLIntoHash(swizzle, line, swizzleHash)
					end
				}
			}
			swizzleHash.merge! :link => swizzle[:link]
			@swizzleHTMLHashArray.push(swizzleHash)
		}
	end

	def formatHTMLIntoHash (swizzle, line, hash)
		line.slice! '<p>'
		line.slice! '</p>'
		if line.include? 'application:' #done
			if line.include? 'tripcase-rails'
				line = (swizzle[:title] += ':Rails')
			elsif line.include? 'tripcase-touch2'
				line = (swizzle[:title] += ':Touch2')
			else
				line = (swizzle[:title] += ':Unknown')
			end
			hash.merge! :title => line
		elsif line.include? 'branch:' #done
			line.slice! 'branch:'
			line.strip!
			hash.merge! :branch => line
		elsif line.include? 'deployed:' #done
			line.slice! 'deployed:'
			line.strip!
			hash.merge! :date => line #done
		elsif line.include? 'deployed by:'
			line.slice! 'deployed by:'
			line.strip!
			if line.split.length == 1
				line.capitalize!
			else
				line.split.each{|i| i.capitalize!}.join(' ')
			end
			if line.length == 0
				line = "TripCase Deployer"
			end
			hash.merge! :deployer => line #done
		elsif line.include? 'release revision:'
			line.slice! 'release revision:'
			line.strip!
			hash.merge! :commitCode => line
		elsif line.include? 'release timestamp:' #done
			line.slice! 'release timestamp:'
			line.strip!
			date = convertTimestampToDateFormat(line)
			hash.merge! :lastCommitTime => date
		end
	end
end

def convertTimestampToDateFormat (timeStamp)
	year = timeStamp[0...4]
	month = timeStamp[5...6]
	day = timeStamp[6...8]
	hour = ((timeStamp[8...10]).to_i - 5).to_s
	minute = timeStamp[10...12]
	second = timeStamp[12...14]

	month = Date::ABBR_MONTHNAMES[month.to_i]

	newTimeStamp = (month + " " + day + ", " + year + " @ " + hour + ":" + minute + ":" + second + " CDT")

	return newTimeStamp
end