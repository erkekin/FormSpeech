//
//  ViewController.swift
//  FormSpeech
//
//  Created by Erk Ekin on 16/11/2016.
//  Copyright © 2016 Erk Ekin. All rights reserved.
//

import UIKit
import Speech

enum Field: String, Iteratable{
    
    case name = "My name is"
    case surname = "my surname is"
    case birthPlace = "I live in"
    case phoneNumber = "my number is"
    
}

class Form{
    
    var name:String!
    var surname:String!
    var birthPlace:String!
    var phoneNumber:String!
    
    init?(text:String) {
        
        if let output = text.parse(){
            
            name = output[Field.name]
            surname = output[Field.surname]
            birthPlace = output[Field.birthPlace]
            phoneNumber = output[Field.phoneNumber]
            
        }else  { return nil}
        
    }
    
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate, ParserDelegate{
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var birthPlace: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet private weak var recordBtn : UIButton!
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let audioEngine = AVAudioEngine()
    private let defaultLocale = Locale(identifier: "en-US")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordBtn.isEnabled = true
                    
                case .denied:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: defaultLocale)!
        speechRecognizer.delegate = self
        
    }
    private func startRecording() throws {
        
        let parser = Parser()
        parser.delegate = self
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                parser.text = result.bestTranscription.formattedString
                
                isFinal = result.isFinal
                if(isFinal == true){
                    self.parseSpeech(speechText: result.bestTranscription.formattedString)
                    
                    
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordBtn.isEnabled = true
                self.recordBtn.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
            recordBtn.setTitle("Start Recording", for: [])
        } else {
            recordBtn.isEnabled = false
            recordBtn.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    // =========================================================================
    // MARK: - Actions
    
    @IBAction func recordBtnTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordBtn.isEnabled = false
            recordBtn.setTitle("Stopping", for: .disabled)
            
        } else {
            try! startRecording()
            recordBtn.setTitle("Stop recording", for: [])
            
            name.text = ""
            surname.text = ""
            birthPlace.text = ""
            phoneNumber.text = ""
        }
    }
    
    func parseSpeech(speechText:String){
        
        guard let form = Form(text: speechText) else {return}
        
        name.text = form.name
        surname.text = form.surname
        birthPlace.text = form.birthPlace
        phoneNumber.text = form.phoneNumber
        
    }
    
    func valueParsed(parser: Parser, forValue: String, andKey: Field) {
        
        switch andKey{
            
        case .name:
            name.text = forValue
            break
            
        case .surname:
            surname.text = forValue
            break
        case .birthPlace:
            birthPlace.text = forValue
            break
        case .phoneNumber:
            phoneNumber.text = forValue
            break
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

