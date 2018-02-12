require 'HTTParty'
require 'Nokogiri'
require 'csv'

def get_player_links
	main_page = Nokogiri::HTML(File.read("players.html"))
	player_links = []
	main_page.css("a").each do |a_element| 
		if /^\/players\//.match?(a_element["href"])
			player_links << [a_element.text, "https://www.pro-football-reference.com" + a_element["href"]]
		end
	end
	player_links
end

def player_meta(player_link)
	player_page = Nokogiri::HTML(HTTParty.get(player_link))
	info_box = player_page.css('div[itemtype="https://schema.org/Person"]')[0].text
	begin 
		throws = /Throws:\W*(?<data>\w*)\W*/.match(info_box)["data"]
	rescue
		throws = nil
	end
	begin
		salary_cap = player_page.css('div[itemtype="https://schema.org/Person"]')[0].css('a[href="/players/salary.htm"]')[0].text
	rescue
		salary_cap = nil
	end
	return throws, salary_cap
end


if __FILE__ == $0

	CSV.open("player_info.csv", "a") do |csv|
		csv << ["player_name", "profile_link", "player_throwing_arm", "player_salary_cap"]
		get_player_links().each do |player_link|
			begin
				csv << player_link + player_meta(player_link[1])
			rescue Exception=>e
				p e
				p player_link
			end
		end
	end
end