class Transcription < ApplicationRecord
  has_one_attached :audio_blob
  validates :status, inclusion: { in: %w[pending processing completed failed], allow_nil: true }
  def full_text
    [live_client_text, server_transcript].reject(&:blank?).join("\n")
  end
end
