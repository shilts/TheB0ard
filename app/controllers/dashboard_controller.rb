require 'open-uri'
# require 'date'

class DashboardController < ApplicationController

	def main
		swizzleURLHashArray = [
			{:title => 'S2', :url => 'http://swizzle2.tripcase.com/status', :link => 'http://swizzle2.tripcase.com/login'},
			{:title => 'S2', :url => 'http://swizzle2.tripcase.com/touch2/status', :link => 'http://swizzle2.tripcase.com/tdot'},
			{:title => 'S3', :url => 'http://ctovm2417.dev.sabre.com/status', :link => 'http://ctovm2417.dev.sabre.com/login'},
			{:title => 'S3', :url => 'http://ctovm2417.dev.sabre.com/touch2/status', :link => 'http://ctovm2417.dev.sabre.com/tdot'},
			{:title => 'S4', :url => 'http://ctovm2418.dev.sabre.com/status', :link => 'http://ctovm2418.dev.sabre.com/login'},
			{:title => 'S4', :url => 'http://ctovm2418.dev.sabre.com/touch2/status', :link => 'http://ctovm2418.dev.sabre.com/tdot'},
			{:title => 'S5', :url => 'http://swizzle5.tripcase.com/status', :link => 'http://swizzle5.tripcase.com/login'},
			{:title => 'S5', :url => 'http://swizzle5.tripcase.com/touch2/status', :link => 'http://swizzle5.tripcase.com/tdot'},
			{:title => 'S6', :url => 'ltxl0208.sgdcelab.sabre.com/status', :link => 'ltxl0208.sgdcelab.sabre.com/login'},
			{:title => 'S6', :url => 'ltxl0208.sgdcelab.sabre.com/touch2/status', :link => 'ltxl0208.sgdcelab.sabre.com/tdot'}
		]

		#hash contents: {:type, :title, :branch, :date, :deployer, :commitCode, :lastCommitTime, :link, :isDown}
		@swizzleHTMLHashArray = []

		fetch_swizzle_data(swizzleURLHashArray, @swizzleHTMLHashArray)

		respond_to do |format|
			format.html
			format.json {
				@swizzleHTMLHashArray = []
				fetch_swizzle_data(swizzleURLHashArray, @swizzleHTMLHashArray)
				render :json => @swizzleHTMLHashArray
			}
		end
	end

	def fetch_swizzle_data(swizzleURLArray, swizzleDataArray)
		swizzleURLArray.each { |swizzle|
			swizzleHash = {}
			begin
				open(swizzle[:url]) { | response |
					response.each_line {| line |
						if !(line.strip.empty?)
							formatHTMLIntoHash(swizzle, line, swizzleHash)
						end
					}
				}
				swizzleHash.merge! :link => swizzle[:link]
				swizzleHash.merge! :isDown => 0
				swizzleDataArray.push(swizzleHash)
			rescue => e
				case e
				when OpenURI::HTTPError
					puts e.message
					puts "Your network appears to be down! LOL"
					puts "Wait...how are you reading this...?"
				when SocketError
					if swizzle[:url].include? 'touch2'
						errorTitle = swizzle[:title] + ':Touch2 is down'
						errorPlatform = 'touch2'
					else
						errorTitle = swizzle[:title] + ':Rails is down'
						errorPlatform = 'rails'
					end
					@swizzleHTMLHashArray.push({:type =>errorPlatform, :title => errorTitle, :link => swizzle[:link], :isDown => 1})
				when Errno::ENOENT
					if swizzle[:url].include? 'touch2'
						errorTitle = swizzle[:title] + ":Touch2 status page unavailable"
						errorPlatform = 'touch2'
					else
						errorTitle = swizzle[:title] + ":Rails status page unavailable"
						errorPlatform = 'rails'
					end
					@swizzleHTMLHashArray.push({:type => errorPlatform, :title => errorTitle, :link => swizzle[:link], :isDown => 1})
				else
					raise e
				end
			end
		}
		return swizzleDataArray
	end

	def formatHTMLIntoHash (swizzle, line, hash)
		line.slice! '<p>'
		line.slice! '</p>'
		if line.include? 'application:' #done
			if line.include? 'tripcase-rails'
				line = (swizzle[:title] + ':Rails')
				hash.merge! :type => 'rails'
			elsif line.include? 'tripcase-touch2'
				line = (swizzle[:title] + ':Touch2')
				hash.merge! :type => 'touch2'
			else
				line = (swizzle[:title] + ':Unknown')
				hash.merge! :type => '?'
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
		# elsif line.include? 'release timestamp:' #done
		# 	line.slice! 'release timestamp:'
		# 	line.strip!
		# 	date = convertTimestampToDateFormat(line)
		# 	hash.merge! :lastCommitTime => date
		end
	end
end

# --- Just in case anyone decides the timestamps are useful ---
# def convertTimestampToDateFormat (timeStamp)
# 	year = timeStamp[0...4]
# 	month = timeStamp[5...6]
# 	day = timeStamp[6...8]
# 	hour = ((timeStamp[8...10]).to_i - 5).to_s
# 	minute = timeStamp[10...12]
# 	second = timeStamp[12...14]

# 	month = Date::ABBR_MONTHNAMES[month.to_i]

# 	newTimeStamp = (month + " " + day + ", " + year + " @ " + hour + ":" + minute + ":" + second + " CDT")

# 	return newTimeStamp
# end
