# Voice Summarizer

A simple Rails application that records live text (or audio) and generates a summarized version using a text summarization service.

## Features
- Create a transcription with audio input.
- Automatically generate a summary using HuggingFace (or a stub in tests).
- View transcription and summary on a clean UI page.

## Tech Stack
- **Backend:** Ruby on Rails + Postgresql
- **Frontend:** ERB + Tailwind CSS
- **API:** HuggingFace Inference API (configurable via `.env`)

## Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/voice_summarizer.git
   cd voice_summarizer
2. Install dependencies:
    bundle install
    rails db:setup
3. Create a .env file:
    HUGGINGFACE_MODEL=facebook/bart-large-cnn
    HUGGINGFACE_API_KEY=your_api_key_here
4. Start the server:
    rails server (or) rails s
5. Visit 
    http://localhost:3000/transcribe (or) http://localhost:3000 (or) http://localhost:3000/new - creating a transcription with audio input.

    http://localhost:3000/transcribe/:id/summary - to view particular transcription use this path, By default after every successfull creation of trancscriptions it will redirect to summary view page