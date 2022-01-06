require 'net/http'
require 'json'

class Api
    def initialize (host)
        @http = Net::HTTP.new(host, 443)
        @http.use_ssl = true
        token = File.read(".token/#{host}")
        @header = {"Authorization" => "Bearer #{token}"}
    
    end

    def search (username)
        response = @http.get("/api/v1/accounts/search/?q=@#{username}", @header)
        JSON.parse(response.body)
    end

    def get_statuses (user_id, max_id = nil)
        params = {limit: 100}
        params[:max_id] = max_id unless max_id.nil?
        query = URI.encode_www_form(params)
        statuses = get("/api/v1/accounts/#{user_id}/statuses?#{query}")
        statuses.filter{|e| e['reblog'].nil? }.map{|s| {'id' => s['id'], 'content' => s['content']}}
    end

    def get_timelines(max_id = nil)
        params = {limit: 100, local: 1}
        params[:max_id] = max_id unless max_id.nil?
        query = URI.encode_www_form(params)
        statuses = get("/api/v1/timelines/public?#{query}")
        statuses.filter{|s| s['reblog'].nil? }.map{|s| {id: s['id'], content: s['content']}}
    end

    def get(endpoint)
        response = @http.get(endpoint, @header)
        JSON.parse(response.body)
    end
end