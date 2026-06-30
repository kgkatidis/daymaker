// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import AVFoundation
import Combine

final class VoiceService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = VoiceService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice()
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.05
        utterance.volume = 1.0
        utterance.postUtteranceDelay = 0.1

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)

        isSpeaking = true
        synthesizer.speak(utterance)
        HapticService.impact(.medium)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .word)
    }

    private func bestVoice() -> AVSpeechSynthesisVoice? {
        let preferredLanguages = ["el-GR", "en-US"]
        for lang in preferredLanguages {
            if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: {
                $0.language == lang && $0.quality == .enhanced
            }) { return voice }
            if let voice = AVSpeechSynthesisVoice(language: lang) { return voice }
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
