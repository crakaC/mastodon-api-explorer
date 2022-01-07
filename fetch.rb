require './api.rb'
require 'fileutils'

if ARGV.count != 2
    puts "fetch <host> <username>"
    exit 1
end

host = ARGV[0]
username = ARGV[1].gsub('@', '')

api = Api.new(host)

# ユーザーID引っ張ってくるためにとりあえず検索
accounts = api.search(username)
if accounts.empty?
    puts "#{username} is not found"
    exit
elsif accounts.count == 1
    account = accounts.first
else
    puts "\"#{username}\" hits some accounts"""
    accounts.each_with_index { |a, i|
        puts "#{i+1}: #{a["acct"]}"
    }
    input = ""
    while true
        input = STDIN.gets
        unless input =~ /\A[0-9]+\Z/
            next
        end
        i = input.to_i - 1
        if 0 <= i && i < accounts.count
            break
        end
    end
    account = accounts[input.to_i - 1]
end
puts "@#{account["username"]} (id:#{account["id"]})"

json_dir = "statuses/#{host}/#{username}"
FileUtils.mkdir_p(json_dir) unless File.exists?(json_dir)

user_id = account["id"]
max_id = 9223372036854775807 # bigintの最大値
while true
    statuses = api.get_statuses(user_id, max_id)
    break if statuses.empty?
    puts "fetched:#{statuses.first['id']}"
    filename = "#{json_dir}/#{statuses.first['id']}.json"
    File.open(filename, 'w'){|f|f.write(JSON.dump(statuses))}
    max_id = statuses.last['id']
    sleep 3
end