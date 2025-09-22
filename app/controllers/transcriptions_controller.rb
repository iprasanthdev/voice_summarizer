class TranscriptionsController < ApplicationController
  protect_from_forgery with: :exception

  def new
    # renders app/views/transcriptions/new.html.erb
  end

  def create
    transcription = Transcription.create!(
      live_client_text: params[:live_text],
      status: "processing"
    )
    transcription.audio_blob.attach(params[:audio]) if params[:audio].present?

    begin
      summary = SummarizationService.new(transcription.full_text).generate!
      transcription.update!(summary: summary, status: "completed")

      # Redirect to summary page instead of returning JSON
      redirect_to summary_transcription_path(transcription)
    rescue => e
      transcription.update!(status: "failed")
      flash[:alert] = "Failed to summarize: #{e.message}"
      redirect_to new_transcription_path
    end
  end

  def summary
    @transcription = Transcription.find(params[:id])

    if @transcription.summary.blank?
      @transcription.update!(summary: SummarizationService.new(@transcription.full_text).generate!)
    end

    render :summary
  end
end
