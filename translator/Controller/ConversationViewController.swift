//
//  ConversationViewController.swift
//  translator
//
//  Created by a on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit
import Speech

class ConversationViewController: ParentViewController,
                                SFSpeechRecognizerDelegate {

    @IBOutlet weak var viewFrom: UIView!
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var textFrom: UITextView!
    @IBOutlet weak var viewTo: UIView!
    @IBOutlet weak var buttonTo: UIButton!
    @IBOutlet weak var textTo: UITextView!
    @IBOutlet weak var leftMic: UIButton!
    @IBOutlet weak var rightMic: UIButton!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var langFrom, langTo, langCodeFrom, langCodeTo :String!
    var alertControllerFrom, alertControllerTo :UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SetupUI()
        
        speechRecognizer!.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
//                self.leftMic.isEnabled = true
//                self.rightMic.isEnabled = true
                break
                
            case .denied:
//                self.leftMic.isEnabled = false
//                self.rightMic.isEnabled = false
                print("User denied access to speech recognition")
                break
                
            case .restricted:
//                self.leftMic.isEnabled = false
//                self.rightMic.isEnabled = false
                print("Speech recognition restricted on this device")
                break
                
            case .notDetermined:
//                self.leftMic.isEnabled = false
//                self.rightMic.isEnabled = false
                print("Speech recognition not yet authorized")
                break
            }
            
            OperationQueue.main.addOperation() {
                
            }
        }
    }
    
    //MARK: IBAction    
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SelectFrom(_ sender: Any)
    {
        present(alertControllerFrom, animated: true, completion: nil)
    }
    
    @IBAction func SelectTo(_ sender: Any)
    {
        present(alertControllerTo, animated: true, completion: nil)
    }
    
    @IBAction func CopyFrom(_ sender: Any)
    {
        CopyText(str: textFrom.text)
    }
    
    @IBAction func SynthesisFrom(_ sender: Any)
    {
        TextToSpeech(str: textTo.text, lang: "en-US")
    }
    
    @IBAction func ZoomFrom(_ sender: Any)
    {
        performSegue(withIdentifier: "Zoom", sender: self)
    }
    
    @IBAction func LeftStart(_ sender: Any)
    {
        NSLog("%@", "Left Start")
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        startRecording()
    }
    
    @IBAction func LeftEnd(_ sender: Any)
    {
        NSLog("%@", "Left End")
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    @IBAction func LeftSynthesis(_ sender: Any)
    {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            //            microphoneButton.isEnabled = false
            //            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
            startRecording()
            //            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    @IBAction func RightStart(_ sender: Any)
    {
        NSLog("%@", "Right Start")
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        startRecording()
    }
    
    @IBAction func RightEnd(_ sender: Any)
    {
        NSLog("%@", "Right End")
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    
    //MARK: Function
    func SetupUI() -> Void
    {
        ChangeBG(sender: self, image: "")
        
        viewFrom.layer.cornerRadius = 10
        viewFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewFrom.layer.shadowColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewFrom.layer.shadowOpacity = 0.3
        viewFrom.layer.shadowOffset = CGSize.zero
        viewFrom.layer.shadowRadius = 3
        viewFrom.layer.shadowPath = UIBezierPath(rect: viewFrom.bounds).cgPath
        
        viewTo.layer.cornerRadius = 10
        viewTo.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewTo.layer.shadowColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewTo.layer.shadowOpacity = 0.3
        viewTo.layer.shadowOffset = CGSize.zero
        viewTo.layer.shadowRadius = 3
        viewTo.layer.shadowPath = UIBezierPath(rect: viewTo.bounds).cgPath
        
        alertControllerFrom = ShowAlertSheetViewController(sender: self, title: "", message: "Select Language")
        
        for i in 0..<lang.count
        {
            let sendButton = UIAlertAction(title:(self.lang.object(at: i) as! String), style: .default, handler: { (action) -> Void in
                self.buttonFrom.setTitle((self.lang.object(at: i) as! String), for: .normal)
                self.langFrom = (self.lang.object(at: i) as! String)
                self.langCodeFrom = (self.langCode.object(at: i) as! String)
                self.defaults.set(self.langFrom, forKey: "LanguageFrom")
                self.defaults.set(self.langCodeFrom, forKey: "LanguageCodeFrom")
                self.defaults.synchronize()
            })
            alertControllerFrom.addAction(sendButton)
        }
        
        alertControllerTo = ShowAlertSheetViewController(sender: self, title: "", message: "Select Language")
        
        for i in 0..<lang.count
        {
            let sendButton = UIAlertAction(title:(self.lang.object(at: i) as! String), style: .default, handler: { (action) -> Void in
                self.buttonTo.setTitle((self.lang.object(at: i) as! String), for: .normal)
                self.langTo = (self.lang.object(at: i) as! String)
                self.langCodeTo = (self.langCode.object(at: i) as! String)
                self.defaults.set(self.langTo, forKey: "LanguageTo")
                self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
                self.defaults.synchronize()
            })
            alertControllerTo.addAction(sendButton)
        }
    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: .interruptSpokenAudioAndMixWithOthers)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textFrom.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //        textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available:Bool)
    {
        //        if available {
        //            microphoneButton.isEnabled = true
        //        } else {
        //            microphoneButton.isEnabled = false
        //        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Zoom") {
            let vc = segue.destination as! ZoomViewController
            vc.textZoom = textFrom.text
        }
    }
    

}
