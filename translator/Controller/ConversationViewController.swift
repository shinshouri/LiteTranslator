//
//  ConversationViewController.swift
//  Lite Translate
//
//  Created by MC on 15/11/18.
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
    private var audioEngine = AVAudioEngine()
    
    
    var langFrom, langTo, langCodeFrom, langCodeTo, flag, ConvertString, zoomString :String!
    var alertControllerFrom, alertControllerTo :UIAlertController!
    var seconds: Int!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SetupUI()
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        speechRecognizer!.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
                switch AVAudioSession.sharedInstance().recordPermission
                {
                case AVAudioSession.RecordPermission.granted:
                    print("Permission granted")
                case AVAudioSession.RecordPermission.denied:
                    print("Pemission denied")
                case AVAudioSession.RecordPermission.undetermined:
                    print("Request permission here")
                    AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                        // Handle granted
                    })
                }
                break
                
            case .denied:
                print("User denied access to speech recognition")
                break
                
            case .restricted:
                print("Speech recognition restricted on this device")
                break
                
            case .notDetermined:
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
//        present(alertControllerFrom, animated: true, completion: nil)
    }
    
    @IBAction func SelectTo(_ sender: Any)
    {
//        present(alertControllerTo, animated: true, completion: nil)
    }
    
    @IBAction func ShareFrom(_ sender: Any)
    {
        Share(shareString: textFrom.text)
    }
    
    @IBAction func ShareTo(_ sender: Any)
    {
        Share(shareString: textTo.text)
    }
    
    @IBAction func CopyFrom(_ sender: Any)
    {
        CopyText(str: textFrom.text)
    }
    
    @IBAction func CopyTo(_ sender: Any)
    {
        CopyText(str: textTo.text)
    }
    
    @IBAction func SynthesisFrom(_ sender: Any)
    {
        if textFrom.text.count > 0
        {
            TextToSpeech(str: textFrom.text, lang: langCodeFrom)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: "Warning!", message: "No Text"), animated: true, completion: nil)
        }
    }
    
    @IBAction func SynthesisTo(_ sender: Any)
    {
        if textTo.text.count > 0
        {
            TextToSpeech(str: textTo.text, lang: langCodeTo)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: "Warning!", message: "No Text"), animated: true, completion: nil)
        }
    }
    
    @IBAction func ZoomFrom(_ sender: Any)
    {
        if textFrom.text.count > 0
        {
            zoomString = textFrom.text
            performSegue(withIdentifier: "Zoom", sender: self)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: L(key: "key32"), message: L(key: "key33")), animated: true, completion: nil)
        }
    }
    
    @IBAction func ZoomTo(_ sender: Any)
    {
        if textTo.text.count > 0
        {
            zoomString = textTo.text
            performSegue(withIdentifier: "Zoom", sender: self)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: L(key: "key32"), message: L(key: "key33")), animated: true, completion: nil)
        }
    }
    
    @IBAction func LeftStart(_ sender: Any)
    {
        NSLog("%@", "Left Start")
        flag = "left"
        loading?.removeFromSuperview()
        ShowLoading(loadLabel: L(key: "key37"))
        leftMic.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY)
        leftMic.setTitleColor(GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY), for: .normal)
        NSLog("%@", langCodeFrom)
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: langCodeFrom))
        startRecording()
        self.seconds = 3
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                             selector: #selector(self.updateTimer),
                             userInfo: nil, repeats: true)
    }
    
    @IBAction func RightStart(_ sender: Any)
    {
        NSLog("%@", "Right Start")
        flag = "right"
        loading?.removeFromSuperview()
        ShowLoading(loadLabel: L(key: "key37"))
        rightMic.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY)
        rightMic.setTitleColor(GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY), for: .normal)
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: langCodeTo))
        startRecording()
        self.seconds = 3
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                            selector: #selector(self.updateTimer),
                            userInfo: nil, repeats: true)
    }
    
    
    //MARK: Function
    func SetupUI() -> Void
    {
        ChangeBG(sender: self, image: "")
        
        viewFrom.layer.cornerRadius = 10
        viewFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewFrom.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewFrom.layer.borderWidth = 1
        
        buttonFrom.setTitle(L(key: defaults.object(forKey: "LanguageFrom") as! String), for: .normal)
        
        leftMic.layer.cornerRadius = 10
        leftMic.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY).cgColor
        leftMic.layer.borderWidth = 1
        leftMic.setTitle(L(key: defaults.object(forKey: "LanguageFrom") as! String), for: .normal)
        
        viewTo.layer.cornerRadius = 10
        viewTo.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewTo.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewTo.layer.borderWidth = 1
        
        buttonTo.setTitle(L(key: defaults.object(forKey: "LanguageTo") as! String), for: .normal)
        
        rightMic.layer.cornerRadius = 10
        rightMic.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY).cgColor
        rightMic.layer.borderWidth = 1
        rightMic.setTitle(L(key: defaults.object(forKey: "LanguageTo") as! String), for: .normal)
        
//        alertControllerFrom = ShowAlertSheetViewController(sender: self, title: "", message: "Select Language")
//        
//        for i in 0..<lang.count
//        {
//            let sendButton = UIAlertAction(title:(self.lang.object(at: i) as! String), style: .default, handler: { (action) -> Void in
//                self.buttonFrom.setTitle((self.lang.object(at: i) as! String), for: .normal)
//                self.langFrom = (self.lang.object(at: i) as! String)
//                self.langCodeFrom = (self.langCode.object(at: i) as! String)
//                self.defaults.set(self.langFrom, forKey: "LanguageFrom")
//                self.defaults.set(self.langCodeFrom, forKey: "LanguageCodeFrom")
//                self.defaults.synchronize()
//            })
//            alertControllerFrom.addAction(sendButton)
//        }
//        
//        alertControllerTo = ShowAlertSheetViewController(sender: self, title: "", message: "Select Language")
//        
//        for i in 0..<lang.count
//        {
//            let sendButton = UIAlertAction(title:(self.lang.object(at: i) as! String), style: .default, handler: { (action) -> Void in
//                self.buttonTo.setTitle((self.lang.object(at: i) as! String), for: .normal)
//                self.langTo = (self.lang.object(at: i) as! String)
//                self.langCodeTo = (self.langCode.object(at: i) as! String)
//                self.defaults.set(self.langTo, forKey: "LanguageTo")
//                self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
//                self.defaults.synchronize()
//            })
//            alertControllerTo.addAction(sendButton)
//        }
    }
    
    @objc func updateTimer() {
        NSLog("%i", seconds)
        if seconds > 0
        {
            seconds -= 1
        }
        else
        {
            timer.invalidate()
            let inputNode = self.audioEngine.inputNode
            self.audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            self.recognitionTask = nil
            loading?.removeFromSuperview()
            if(self.flag == "left")
            {
                self.leftMic.backgroundColor = self.GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
                self.leftMic.setTitleColor(self.GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY), for: .normal)
                if self.ConvertString.count > 0
                {
                    self.RequestAPITranslate(urlRequest: URL_REQUESTAPI_TRANSLATE, params: String(format: "text=%@&from=%@&to=%@&uuid=%@", self.ConvertString, self.langCodeFrom, self.langCodeTo, self.getDeviceID()))
                }
            }
            else if(self.flag == "right")
            {
                self.rightMic.backgroundColor = self.GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
                self.rightMic.setTitleColor(self.GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY), for: .normal)
                if self.ConvertString.count > 0
                {
                    self.RequestAPITranslate(urlRequest: URL_REQUESTAPI_TRANSLATE, params: String(format: "text=%@&from=%@&to=%@&uuid=%@", self.ConvertString, self.langCodeTo, self.langCodeFrom, self.getDeviceID()))
                }
            }
            else
            {
                flag = ""
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio, options: .defaultToSpeaker)
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
            
            if result != nil
            {
                NSLog("%@", (result?.bestTranscription.formattedString)!)
                isFinal = (result?.isFinal)!
                
                self.ConvertString = result?.bestTranscription.formattedString
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
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
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available:Bool)
    {
//        if available {
//            microphoneButton.isEnabled = true
//        } else {
//            microphoneButton.isEnabled = false
//        }
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Zoom") {
            let vc = segue.destination as! ZoomViewController
            vc.textZoom = zoomString
        }
    }

    //MARK: API
    func RequestAPITranslate(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading(loadLabel: L(key: "key38"))
        DispatchQueue.global().async
            {
                self.response = self.RequestAPI(urlRequest: urlRequest, params: params)
                DispatchQueue.main.async
                    {
                        if((self.response?.object(forKey: "error") as? Int) == 0)
                        {
                            if(self.flag == "left")
                            {
                                self.textFrom.text = ((self.response?.object(forKey: "result") as! NSDictionary).object(forKey: "text_source") as? String)!
                                self.textTo.text = ((self.response?.object(forKey: "result") as! NSDictionary).object(forKey: "text") as? String)!
                                self.leftMic.backgroundColor = self.GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
                                self.leftMic.setTitleColor(self.GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY), for: .normal)
                                self.TextToSpeech(str: self.textTo.text, lang: self.langCodeTo)
                            }
                            else if(self.flag == "right")
                            {
                                self.textTo.text = ((self.response?.object(forKey: "result") as! NSDictionary).object(forKey: "text_source") as? String)!
                                self.textFrom.text = ((self.response?.object(forKey: "result") as! NSDictionary).object(forKey: "text") as? String)!
                                self.rightMic.backgroundColor = self.GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
                                self.rightMic.setTitleColor(self.GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY), for: .normal)
                                self.TextToSpeech(str: self.textFrom.text, lang: self.langCodeFrom)
                            }
                        }
                        else
                        {
                            self.present(self.ShowAlertViewController(sender: self, title: self.L(key: "key34"), message: self.L(key: "key35")), animated: true, completion: nil)
                        }
                        self.ConvertString = ""
                        self.flag = ""
                        self.loading?.removeFromSuperview()
                }
        }
    }
}
