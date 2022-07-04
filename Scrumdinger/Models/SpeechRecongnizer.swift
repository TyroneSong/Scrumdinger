//
//  SpeechRecongnizer.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/3.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

/// 演讲识别器
/// 可观察对象
class SpeechRecognizer: ObservableObject {
    
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognier
        case notPermittedToRecord
        case recogizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initilaize speech Recoginzer"
            case .notAuthorizedToRecognier: return "Not authorized to recognier speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recogizerIsUnavailable: return "Recogizer is unavailable"
            }
        }
    }
    
    
    /// 翻译文字
    var transcript: String = ""
    
    /// 音频引擎
    private var audioEngine: AVAudioEngine?
    /// 音频 buffer 识别请求
    private var request: SFSpeechAudioBufferRecognitionRequest?
    /// 音频识别任务
    private var task: SFSpeechRecognitionTask?
    /// 语音识别
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        recognizer = SFSpeechRecognizer()
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognier
                }
                
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    /// 翻译
    func transcribe() {
        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recogizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
            } catch  {
                self.reset()
                self.speakError(error)
            }
        }
    }
    
    func stopTranscribing() {
        reset()
    }
    
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    // MARK: ------------ Private Methods
    
    /// 准备引擎
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    /// 识别回调
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }
        
        if let result = result {
            speak(result.bestTranscription.formattedString)
        }
    }
    
    /// 描述内容
    private func speak(_ message: String) {
        transcript = message
    }
    
    /// 描述错误
    private func speakError(_ message: Error) {
        var errorMessage = ""
        if let error = message as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage = message.localizedDescription
        }
        
        transcript = "<< \(errorMessage) >>"
    }
    
}

extension SFSpeechRecognizer {
    /// 是否授权 可以识别
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    /// 是否允许记录
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
