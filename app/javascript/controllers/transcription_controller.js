// app/javascript/controllers/transcription_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["live", "startBtn", "stopBtn", "status"]

    connect() {
        console.log("✅ Transcription controller connected!");
        this.speechRecognition = null;
        this.isRecording = false;
        this.finalTranscript = ""; // ✅ store all confirmed results
    }

    start() {
        this.startBtnTarget.disabled = true;
        this.stopBtnTarget.disabled = false;
        this.statusTarget.textContent = "Requesting microphone...";
        this.finalTranscript = ""; // ✅ reset when starting

        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRecognition) {
            this.liveTarget.textContent = "Your browser does not support live transcription.";
            this.statusTarget.textContent = "Unsupported browser";
            this.startBtnTarget.disabled = false;
            this.stopBtnTarget.disabled = true;
            return;
        }

        this.speechRecognition = new SpeechRecognition();
        this.speechRecognition.interimResults = true;
        this.speechRecognition.continuous = true;
        this.speechRecognition.lang = "en-US";

        this.speechRecognition.onresult = (event) => {
            let interim = "";
            for (let i = event.resultIndex; i < event.results.length; ++i) {
                const transcript = event.results[i][0].transcript;
                if (event.results[i].isFinal) {
                    this.finalTranscript += transcript + " "; // ✅ accumulate final results
                } else {
                    interim += transcript;
                }
            }
            this.liveTarget.textContent = (this.finalTranscript + interim).trim();
        };

        this.speechRecognition.onstart = () => {
            this.statusTarget.textContent = "Listening…";
        };

        this.speechRecognition.start();
        this.isRecording = true;
    }

    async stop() {
        this.startBtnTarget.disabled = false;
        this.stopBtnTarget.disabled = true;
        this.statusTarget.textContent = "Stopping…";

        if (this.speechRecognition && this.isRecording) {
            this.speechRecognition.stop();
        }

        const finalText = this.finalTranscript.trim(); // ✅ use accumulated transcript
        console.log("Stopped recording. Final transcript:", finalText);

        if (!finalText) {
            this.statusTarget.textContent = "No speech captured.";
            return;
        }

        this.statusTarget.textContent = "Saving transcription…";

        const form = new FormData();
        form.append("live_text", finalText);

        const token = document.querySelector('meta[name="csrf-token"]').content;
        const res = await fetch("/transcriptions", {
            method: "POST",
            headers: { "X-CSRF-Token": token },
            body: form
        });

        if (res.redirected) {
            window.location.href = res.url;
        } else {
            const data = await res.json();
            this.statusTarget.textContent = data.error || "Failed to save transcription.";
        }

        this.isRecording = false;
    }
}
