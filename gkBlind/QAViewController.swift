//
//  QAViewController.swift
//  gkBlind
//
//  Created by CG-3 on 30/01/17.
//  Copyright © 2017 CG-3. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Speech
import AVFoundation

class QAViewController: UIViewController, SFSpeechRecognizerDelegate{
    
    let speakTalk = AVSpeechSynthesizer()
    var IsOption: [Bool] = []
    var IsSelected: [Bool] = []
    var arrayOfOptionButton:[UIButton] = []
    var Points: Int = 0
    var myStringValue:String?
    var QuestionId: Int = 1
    var count:Int = 0
    var option_Count = 0
    
    
    var speak:String = " "
    
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var OptionScroll: UIScrollView!
    @IBOutlet weak var lblScore: UILabel!
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    
    
    
    
    
    func Audio(Input : String)
    {
            let speakText = AVSpeechUtterance(string: "\(Input)")
            speakText.rate = 0.5
            speakText.pitchMultiplier = 1.7
            speakTalk.speak(speakText)
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
        
        
        
        //self.startRecording()
        
        QuestionCount()
        optionCount()
        print ("executed view didload")
        loadQuestion(QuestionId: QuestionId)
        
        
        

        
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    @IBOutlet var untap: UITapGestureRecognizer!
    @IBAction func tap(_ sender: Any) {
        
            print("AG stopped")
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
        AudioServicesPlaySystemSound(1054);
        startRecording()
            
        
        print("gfgfgffg")
        
    }
//=================================================================================================================\\
   
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
            
            
            
            
            
                
            
            self.untap.isEnabled = true
            
            
            /*if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
 
                
            }*/
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
        
        //extView.text = "Say something, I'm listening!"
        

        
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
    func selectActionViaVoice(inputStr: String)
    {
        var containString = inputStr.lowercased()
        var tag : Int = 0
        var btnsendtag : UIButton
        //=========================Option Number Commands====================//

        if containString.contains("one") || containString.contains("1")
        {
            tag = 1
            
            btnsendtag = self.view.viewWithTag(tag) as! UIButton
        }
        if containString.contains("two") || containString.contains("do") || containString.contains("2") || containString.contains("to")
        {
            tag = 2
            btnsendtag = self.view.viewWithTag(tag) as! UIButton

        }
        
        if containString.contains("three") || containString.contains("three") || speak.contains("3")
        {
            tag = 3
            btnsendtag = self.view.viewWithTag(tag) as! UIButton

        }
        if containString.contains("four") || containString.contains("for") || speak.contains("4")
        {
            tag = 4
            btnsendtag = self.view.viewWithTag(tag) as! UIButton

        }
        
        
        
        if(option_Count == 1)
        {
            var btncount = 0
            for btn: UIButton  in arrayOfOptionButton
            {
                btn.backgroundColor = UIColor.red
                IsSelected[btncount] = false
                btncount+=1
            }
            IsSelected[btnsendtag.tag - 1] = true
            btnsendtag.backgroundColor = UIColor.green
        }
        else
        {
            if (IsSelected[btnsendtag.tag - 1] == true)
            {
                IsSelected[btnsendtag.tag - 1] = false
                btnsendtag.backgroundColor = UIColor.red
            }
            else
            {
                IsSelected[btnsendtag.tag - 1] = true
                btnsendtag.backgroundColor = UIColor.green
            }
            
        }

        
        
        
        //=====================Other Action Commands==============//
        if containString.contains("skip") || containString.contains("skeet")
        {
            
            tag = 101
            let btnsendtag : UIButton = self.view.viewWithTag(tag) as! UIButton
            btnsendtag.sendActions(for: .touchUpInside)
            
        }
        
        if containString.contains("submit") || containString.contains("submit")
        {
            
            tag = 201
            let btnsendtag : UIButton = self.view.viewWithTag(tag) as! UIButton
            btnsendtag.sendActions(for: .touchUpInside)
            
            if self.audioEngine.isRunning {
                self.audioEngine.stop()
                
            }
            self.untap.isEnabled = false
        }
        
        if containString.contains("exit") || containString.contains("exist")
        {
            exit(0)
        }
        //
        
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
//=================================================================================================================\\
    
    
    
//=================================================================================================================\\
    func loadQuestion(QuestionId: Int)
    {
        
        speakTalk.stopSpeaking(at:AVSpeechBoundary.immediate)
        
        IsOption = []
        IsSelected  = []
        arrayOfOptionButton  = []
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        var QuestionTag : String?
        let context = DatabaseController.persistentContainer.viewContext
        let question:Question_Master = NSEntityDescription.insertNewObject(forEntityName: "Question_Master", into: context) as! Question_Master
        //let QuestionId: Int = 5
        let fetchRequests:NSFetchRequest<Question_Master> = Question_Master.fetchRequest()
        let predicate = NSPredicate(format: "questionId == \(QuestionId)")
        do {
            let searchResults = try DatabaseController.getContext().fetch(fetchRequests)
            let QuestionsearchResults = (searchResults as NSArray).filtered(using: predicate)
            for mainresult in QuestionsearchResults as! [Question_Master]
            {
                let predicate = NSPredicate(format: "questionId == \(QuestionId)")
                do
                {
                    let Questionresult = try DatabaseController.persistentContainer.viewContext.fetch(fetchRequests)
                    var searchResults = (Questionresult as NSArray).filtered(using: predicate)
                    if let questiontag = (mainresult.questionString)
                    {
                        lblQuestion.text = "\(questiontag)"
                        Audio(Input : "  Question number \(QuestionId) \(questiontag)")                                    //audio func called
                        
                        Audio(Input : "  Your Option are")                                    //audio func called
                    }
                }
                Points = Int(mainresult.points)
            }
            
        }
        catch let errors as NSError
        {
            print(errors)
        }
        
        //=====================
        let fetchRequestsoption:NSFetchRequest<Option_Master> = Option_Master.fetchRequest()
        //  let Optionpredicate = NSPredicate(format: "question_id == \(mainresult.questionId)")
        do {
            let OpsearchResults = try DatabaseController.getContext().fetch(fetchRequestsoption)
            var index: Int = 1
            var Optionindex: Int = 1
            let optionResults = try DatabaseController.persistentContainer.viewContext.fetch(fetchRequestsoption)
            do
            {
                
                
                let Optionpredicate = NSPredicate(format: "question_id ==\(QuestionId)")
                let OptionsearchResults = (optionResults as NSArray).filtered(using: Optionpredicate)
                
                for oresult in OptionsearchResults as! [Option_Master]
                {
                    // print("\(oresult)")
                    optionCount()
                    
                    
                    let frame1 = CGRect(x: 40, y: 0 + (index * 35), width: 200, height: 30 )
                    let button:UIButton = UIButton(frame: frame1)
                    button.tag = Int(oresult.option_id)
                    button.setTitle(oresult.options, for: .normal)
                    
                    button.titleLabel?.text = "\(oresult.options)"
                    Audio(Input : "  Option  \(oresult.option_id)! \(oresult.options!)")                                    //audio func called
                    
                    button.backgroundColor = UIColor.red
                    button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
                    IsSelected.insert(false, at: Int(oresult.option_id - 1 ))
                    
                    //var is_Options: Bool = oresult.is_Option
                    //self.arrayOfOptionButton.append(button)
                    self.arrayOfOptionButton.insert(button , at: Int(oresult.option_id-1 ))
                    self.IsOption.insert(oresult.is_Option, at: Int(oresult.option_id-1 ))
                    
                    //self.arrayOfOptionButton[oresult.option_id-1] = button
                    //self.IsOption[oresult.option_id-1] = oresult.is_Option
                    
                    
                    self.OptionScroll.addSubview(button)
                    
                    index+=1
                }
                
            }
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
        //===============print path of the project database ======\\
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsPath)
        
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    //clear all scrollview (subview) buttons to load next question option button
    func onLoadClearItems()
    {
        arrayOfOptionButton.removeAll()
        IsOption.removeAll()
        IsSelected.removeAll()
        let subviews = self.OptionScroll.subviews
        for subview in subviews{
            subview.removeFromSuperview()
        }
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    //pop alert after every submit with audio speech
    func showAlert(msg: String)
    {
        
        let alert = UIAlertController(title: "Alert", message: "\(msg)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in self.loadQuestion(QuestionId: self.getQuestionId(ques: self.QuestionId))
        }))
        self.present(alert, animated: true, completion: nil)
        Audio(Input : " \(msg)")
        
        /*let alert = UIAlertController(title: "Alert", message: "\(msg)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in self.loadQuestion(QuestionId: self.getQuestionId(ques: self.QuestionId))
        }))
        ///perform close alert but doesnt perform action 
        /*let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }*/
        
        Audio(Input : " \(msg)")    */                                //audio func called
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    
    func QuestionCount()
    {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = DatabaseController.persistentContainer.viewContext
        let question:Question_Master = NSEntityDescription.insertNewObject(forEntityName: "Question_Master", into: context) as! Question_Master
        let fetchRequests:NSFetchRequest<Question_Master> = Question_Master.fetchRequest()
        
        do {
            let searchResults = try DatabaseController.getContext().fetch(fetchRequests)
            for result in searchResults as! [Question_Master]
            {
                count = searchResults.count - 1
                
            }
            print("question count : \(count)")
        }
            
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    //get no. of option is_option from table with is then used for mantaining multichoice and singlechoice QA
    func optionCount()
    {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = DatabaseController.persistentContainer.viewContext
        
        let fetchRequestsoption:NSFetchRequest<Option_Master> = Option_Master.fetchRequest()
        do {
            let OpsearchResults = try DatabaseController.getContext().fetch(fetchRequestsoption)
            let optionResults = try DatabaseController.persistentContainer.viewContext.fetch(fetchRequestsoption)
            do
            {
                let Optionpredicate = NSPredicate(format: "question_id == \(QuestionId) AND is_Option == %@", NSNumber(booleanLiteral: true))
                //let Optionpredicate = NSPredicate(format: "question_id == 11 AND is_Option == %@", NSNumber(booleanLiteral: true))
                let OptionsearchResults = (optionResults as NSArray).filtered(using: Optionpredicate)
                option_Count = OptionsearchResults.count
                print("option count \(option_Count)")
            }
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    //get question count, which is the n used to load next question and check last question
    func getQuestionId(ques: Int) -> Int
    {
        if(QuestionId < count)
        {
            QuestionId = ques + 1
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "It's Last Question!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        return QuestionId
    }
//=================================================================================================================\\
    
    
                                    //BUTTON ACTIONS\\
    
//=================================================================================================================\\
    func buttonClicked(sender: UIButton)
    {
        // Do whatever you need when the button is pressed
        let btnsendtag: UIButton = sender
        if(option_Count == 1)
        {
            var btncount = 0
            for btn: UIButton  in arrayOfOptionButton
            {
                btn.backgroundColor = UIColor.red
                IsSelected[btncount] = false
                btncount+=1
            }
            IsSelected[btnsendtag.tag - 1] = true
            btnsendtag.backgroundColor = UIColor.green
        }
        else
        {
            if (IsSelected[btnsendtag.tag - 1] == true)
            {
                IsSelected[btnsendtag.tag - 1] = false
                btnsendtag.backgroundColor = UIColor.red
            }
            else
            {
                IsSelected[btnsendtag.tag - 1] = true
                btnsendtag.backgroundColor = UIColor.green
            }
            
        }
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    @IBAction func submitBtn(_ sender: Any)
    {
        let btnsendtag: UIButton = sender as! UIButton
        var score: Int = Int(lblScore.text!)!
        var msg : String
        
        for selectedoption in IsSelected{
            print(selectedoption)
        }
        
        for selectedoption in IsOption{
            print(selectedoption)
        }
        
        if IsSelected == IsOption{
            score = score + Points
            lblScore.text = "\(score)"
            msg = "Right Answer"
            Audio(Input : "  Your have Selected  \(btnsendtag.titleLabel?.text)")
            Audio(Input : "  Your Score is   \(score)")
            showAlert(msg: msg)
            
        }else{
            msg = "Oops  Worng Answer"
            showAlert(msg: msg)
        }
        
        onLoadClearItems()
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    @IBAction func skipBtn(_ sender: Any)
    {
        onLoadClearItems()
        loadQuestion(QuestionId: self.getQuestionId(ques: self.QuestionId))
    }
//=================================================================================================================\\
    
    
//=================================================================================================================\\
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        speakTalk.stopSpeaking(at:AVSpeechBoundary.immediate)
    }
//=================================================================================================================\\
}
