require 'open-uri'
require 'timeout'

class DashboardController < ApplicationController

	def main
		swizzleHashArray = [
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

		toBeRemovedArray = [
			'<p>',
			'</p>',
			'branch:',
			'date:',
			'deployed:',
			'deployed by:'
		]

		toBeConvertedHashArray = [
			{:original => 'release revision: ', :new => 'Last Commit: '},
			{:original => 'release timestamp: ', :new  => 'Commit Timestamp: '}
		]

		@swizzleHTTPHashArray = []

		swizzleHashArray.each { |swizzle|
			data = []
			branch = 'unknown'
			open(swizzle[:url]) { | response |
				response.each_line {| line |
					if !(line.strip.empty? or line.include? "application:" or line.include? "branch:")
						if (line.include? 'deployed by:')
							formatHTML(line, toBeRemovedArray, toBeConvertedHashArray)
							if line.length == 0
								line = "TripCase Deployer"
								data.push line
							else
								data.push line.titleize
							end
						else
							formatHTML(line, toBeRemovedArray, toBeConvertedHashArray)
							if line.length != 0
								data.push line
							end
						end
					elsif line.include? "branch: "
						formatHTML(line, toBeRemovedArray, toBeConvertedHashArray)
						branch = line
					elsif !(line.strip.empty?)
						if line.include? 'tripcase-rails'
							swizzle[:title] += ':Rails'
						elsif line.include? 'tripcase-touch2'
							swizzle[:title] += ':Touch2'
						else
							swizzle[:title] += ':Unknown'
						end
					end
				}
			}
			@swizzleHTTPHashArray.push({:title => swizzle[:title], :branch => branch, :data => data, :link => swizzle[:link]})
		}
	end

	def formatHTML (line, removeArray, convertArray)
		if line.include? 'deployed by:'
			removeArray.each do |item|
				line.slice! item
			end
			line.strip!
		else
			removeArray.each do |item|
				line.slice! item
			end
			convertArray.each do |convert|
				if line.include? convert[:original]
					line[convert[:original]] = convert[:new]
				end
			end
			line.strip!
			line.split(' ').each{|w| w.capitalize}.join(' ')
		end

		return line
	end
end