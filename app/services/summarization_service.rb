require 'faraday'
require 'json'

class SummarizationService
  def initialize(text)
    @text = text.to_s
  end

  def generate!
    return "No text to summarize" if @text.strip.empty?

    model = ENV.fetch("HUGGINGFACE_MODEL", "facebook/bart-large-cnn")
    url = "https://router.huggingface.co/hf-inference/models/#{model}"
    api_key = ENV.fetch("HUGGINGFACE_API_KEY")

    conn = Faraday.new(url: url) do |f|
      f.request :json
      f.response :json
      f.use Faraday::Response::RaiseError # raise exceptions
      f.adapter Faraday.default_adapter
    end

    begin
      response = conn.post do |req|
        req.headers['Authorization'] = "Bearer #{api_key}"
        req.headers['Content-Type']  = 'application/json'
        req.body = {
          inputs: @text,
          parameters: {
            min_length: 20,
            max_length: 120
          }
        }
      end

      data = JSON.parse(response.body) rescue {}

      if data.is_a?(Array) && data.first.is_a?(Hash) && data.first["summary_text"]
        data.first["summary_text"]
      elsif data.is_a?(Hash) && data["error"]
        "Summarization error: #{data['error']}"
      else
        extractive_summary
      end

    rescue Faraday::Error => e
      "HTTP error: #{e.message}"
    end
  end

  private

  def extractive_summary
    sentences = @text.scan(/[^\.!?]+[\.!?]/).map(&:strip)
    sentences.first(3).join(" ")
  end
end
