//
//  ViewController.swift
//  gkBlind
//
//  Created by CG-3 on 23/01/17.
//  Copyright © 2017 CG-3. All rights reserved.
//

import UIKit
import CoreData
import Speech
import AVFoundation

class ViewController: UIViewController, SFSpeechRecognizerDelegate{
    var option = [NSManagedObject]()
    let speakTalk = AVSpeechSynthesizer()
    var speak:String = " "
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    func WelcomeSpeach()
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsPath)
        
        var speakText = AVSpeechUtterance(string: "Hello . . . .............. Welcome to Blind Quiz")
        speakText.rate = 0.4 
        speakText.preUtteranceDelay = 1
        speakText.pitchMultiplier = 1.72
        speakTalk.speak(speakText)
        
        speakText = AVSpeechUtterance(string: "say start to start the quiz . . . . . say rules to listen rules . . . . say exit to exit the application. . . . . . please provide input after beep")
        
        speakTalk.speak(speakText)
        
        
            AudioServicesPlaySystemSound(1054);
            startRecording()
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        WelcomeSpeach()
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
        }
        
        
   }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        speakTalk.stopSpeaking(at:AVSpeechBoundary.immediate)
    }
    
    
//=================================================================================================================\\
    func startRecording() {
        print ("recording view didload")
        
        print ("nil view didload")
        /*let audioSession = AVAudioSession.sharedInstance()  //2
         do {
         try audioSession.setCategory(AVAudioSessionCategoryRecord)
         try audioSession.setMode(AVAudioSessionModeMeasurement)
         try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
         } catch {
         print("audioSession properties weren't set because of an error.")
         }*/
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
            inputNode.removeTap(onBus: 0)
        }
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                var selftext = (result?.bestTranscription.formattedString)!
                print("\(selftext)" )//9
                isFinal = (result?.isFinal)!
                self.speak = "\(selftext)"
                
                self.selectActionViaVoice(inputStr: selftext)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 1, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
            
        }
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    //=================================================================================================================\\
    func stopRecording()
    {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
    }
    
    //=================================================================================================================\\
    
    
//=================================================================================================================\\
    func selectActionViaVoice(inputStr: String)
    {
        var containString = inputStr.lowercased()
        var tag : Int = 0
        if containString.contains("rules") || containString.contains("rule")
        {
            tag = 101
            let btnsendtag : UIButton = self.view.viewWithTag(tag) as! UIButton
            btnsendtag.sendActions(for: .touchUpInside)
            
        }
        
        if containString.contains("start") || containString.contains("Start")
        {
            tag = 201
            let btnsendtag : UIButton = self.view.viewWithTag(tag) as! UIButton
            btnsendtag.sendActions(for: .touchUpInside)
        }
        
        if containString.contains("exit") || containString.contains("exist")
        {
            exit(0)
        }
    }
//=================================================================================================================\\

}
