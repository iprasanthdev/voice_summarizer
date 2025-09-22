require 'rails_helper'

RSpec.describe "Transcriptions", type: :request do
  before do
    # Stub HuggingFace API to return a fixed summary
    stub_request(:post, /router.huggingface.co/).
      to_return(
        status: 200,
        body: [ { "summary_text" => "Stubbed summary." } ].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    stub_const("ENV", ENV.to_hash.merge("HUGGINGFACE_API_KEY" => "testing_key"))
  end

  describe "GET /transcriptions/new" do
    it "renders the new page" do
      get new_transcription_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Record Your Voice")
    end
  end

  describe "POST /transcriptions" do
    it "creates a transcription and redirects to summary page" do
      allow(SummarizationService).to receive(:new).and_wrap_original do |method, *args|
        service = method.call(*args)
        allow(service).to receive(:generate!).and_return("Stubbed summary.")
        service
      end
      post transcriptions_path, params: { live_text: "This is a test transcription" }

      transcription = Transcription.last
      expect(transcription.live_client_text).to eq("This is a test transcription")
      expect(transcription.summary).to eq("Stubbed summary.")
      expect(response).to redirect_to(summary_transcription_path(transcription))
    end
  end

  describe "GET /transcriptions/:id/summary" do
    it "renders the summary page" do
      transcription = Transcription.create!(
        live_client_text: "Hello world",
        status: "completed",
        summary: "Pre-existing summary"
      )

      get summary_transcription_path(transcription)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hello world")
      expect(response.body).to include("Pre-existing summary")
    end
  end
end
