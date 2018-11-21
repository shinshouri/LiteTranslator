//
//  ParentViewController.swift
//  MCFramework
//
//  Created by Michael Carolius on 31/05/18.
//  Copyright © 2018 All rights reserved.
//

import UIKit
import AVFoundation

open class ParentViewController: UIViewController,
                                UITextViewDelegate
{

    var response: NSDictionary?
    var loading: UIView?
    var defaults: UserDefaults! = UserDefaults.standard
    var picker: UIPickerView?
    var lang, langCode : NSArray!
    var bgView:UIView!
    var bgImage:UIImageView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BGiPhone1")!)
        bgView = UIView(frame: self.view.frame)
        bgImage = UIImageView(frame: bgView.frame)
        bgImage.image = UIImage(named: "BG iPhone 1")
        bgView.addSubview(bgImage)
        self.view.insertSubview(bgView, at: 0)
        
        lang = ["Afrikaans", "Albanian", "Amharic", "Arabic", "Armenian", "Azeerbaijani", "Basque", "Belarusian", "Bengali", "Bosnian", "Bulgarian", "Catalan", "Cebuano", "Chinese(Simplified)", "Chinese(Traditional)", "Corsican", "Croatian", "Czech", "Danish", "Dutch", "English", "Esperanto", "Estonian", "Finnish", "French", "Frisian", "Galician", "Georgian", "German", "Greek", "Gujarati", "Haitain Creole", "Hausa", "Hawaiian", "Hebrew", "Hindi", "Hmong", "Hungarian", "Icelandic", "Igbo", "Indonesian", "Irish", "Italian", "Japanese", "Javanese", "Kannada", "Kazakh", "Khmer", "Korean", "Kurdish", "Kyrgyz", "Lao", "Latin", "Latvian", "Lithuanian", "Luxembourgish", "Macedonian", "Malagasy", "Malay", "Malayalam", "Maltese", "Maori", "Marathi", "Mongolian", "Myanmar(Burmese)", "Nepali", "Norwegian", "Nyanja(Chichewa)", "Pashto", "Persian", "Polish", "Portuguese", "Punjabi", "Romanian", "Russian", "Samoan", "Scots Gaelic", "Serbian", "Sesotho", "Shona", "Sindhi", "Sinhala(Sinhalese)", "Slovak", "Slovenian", "Somali", "Spanish", "Sundanese", "Swahili", "Swedish", "Tagalog(Filipino)", "Tajik", "Tamil", "Telugu", "Thai", "Turkish", "Ukrainian", "Urdu", "Uzbek", "Vietnamese", "Welsh", "Xhosa", "Yiddish", "Yoruba", "Zulu"]
        langCode = ["af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "zh-CN", "zh-TW", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "fi", "fr", "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "he**", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ny", "ps", "fa", "pl", "pt", "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tl", "tg", "ta", "te", "th", "tr", "uk", "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu"];
    }

    override open func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UI
    public func ChangeBG(sender:UIViewController, image:String)
    {
        if (image == "") {
            bgImage.image = UIImage(named: image)
            bgImage.backgroundColor = UIColor.white
        } else
        {
            bgImage.image = UIImage(named: image)
        }
    }
    
    public func CreateView(sender:UIViewController, frame:CGRect, color:UInt32 = THEME_FONT_PRIMARY, tag:Int = 0) -> UIView
    {
        let view: UIView? = UIView(frame: frame)
        view?.backgroundColor = GeneratorUIColor(intHexColor: color)
        view?.tag = tag
        return view!
    }
    
    public func CreateButton(sender:UIViewController, frame:CGRect, tag:Int = 0) -> UIButton
    {
        let btn: UIButton? = UIButton(frame: frame)
        btn?.backgroundColor = UIColor.clear
        btn?.tag = tag
        return btn!
    }

    
    //MARK: PROCEDURE
    public func ShowLoading(loadLabel:String = "") -> Void
    {
        loading?.removeFromSuperview()
        loading = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        loading?.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY, Opacity: 0.5)
        
        if loadLabel.count > 0
        {
            let lblload:UILabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height/2+30, width: self.view.frame.size.width, height: self.view.frame.size.height/20))
            lblload.text = loadLabel
            lblload.textColor = .white
            lblload.textAlignment = .center
            loading?.addSubview(lblload)
        }
        let ai = UIActivityIndicatorView.init(style:.whiteLarge)
        ai.startAnimating()
        ai.center = (loading?.center)!
        loading?.addSubview(ai)
        
        
        self.view.addSubview(loading!)
    }
    
    public func TextToSpeech(str: String, lang: String) {
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
//        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    public func CopyText(str: String)
    {
        let pasteboard = UIPasteboard.general
        pasteboard.string = str
    }
    
    //MARK: FUNCTION
    public func getDeviceID() -> String
    {
        if ((KeyChainStore.load("DeviceID")) != nil) {
            return KeyChainStore.load("DeviceID") as! String
        }
        
        KeyChainStore.save("DeviceID", data: UUID().uuidString)
        return KeyChainStore.load("DeviceID") as! String
    }
    
    public func GeneratorUIColor(intHexColor : UInt32, Opacity : Double = 1.0) -> UIColor
    {
        let floatRedValue: CGFloat = CGFloat((intHexColor & 0xFF0000) >> 16) / 256.0
        let floatGreenValue: CGFloat = CGFloat((intHexColor & 0xFF00) >> 8) / 256.0
        let floatBlueValue: CGFloat = CGFloat(intHexColor & 0xFF) / 256.0
        
        return UIColor(red : floatRedValue, green : floatGreenValue, blue : floatBlueValue, alpha : CGFloat(Opacity))
    }
    
    public func ShowPicker(sender:UIViewController, tag:Int) -> UIPickerView {
        picker = UIPickerView(frame: CGRect(x: 0, y: self.view.frame.size.height-(self.view.frame.size.height/3), width: self.view.frame.size.width, height: self.view.frame.size.height/3))
        picker?.delegate = (sender as! UIPickerViewDelegate)
        picker?.dataSource = (sender as! UIPickerViewDataSource)
        picker?.backgroundColor = UIColor.gray
        picker?.tag = tag
        
        return picker!
    }
    
    public func ShowAlertViewController(sender: UIViewController, title:String, message:String) -> UIAlertController
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(cancelButton)
        
        return alertController
    }
    
    public func ShowAlertSheetViewController(sender: UIViewController, title:String, message:String) -> UIAlertController
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(cancelButton)
        
        return alertController
    }
    
//    public func ImageGIFfromName(str: String) -> UIImage
//    {
//        return UIImage.gif(name: str)!
//    }
    
    public func StrToDict(str: String) -> NSDictionary
    {
        let data = str.data(using: String.Encoding.utf8)
        
        return try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
    }
    
    public func Base64Encoded(data:NSData) -> String {
        let Base64Data = data.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        
        return String(data: Base64Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
    }
    
    public func Base64Decoded(data:String) -> NSData {
        return NSData(base64Encoded: data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
    }
    
    //MARK: API
    func RequestAPI(urlRequest:String, params:String) -> NSDictionary
    {
        response =  nil
        var result : NSDictionary = [:]
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .background).async
            {
                let todosEndpoint: String = urlRequest
                guard let todosURL = URL(string: todosEndpoint) else
                {
                    print("Error: cannot create URL")
                    group.leave()
                    return
                }
                var todosUrlRequest = URLRequest(url: todosURL)
                todosUrlRequest.httpMethod = "POST"
                let newTodo: String = params
                do
                {
                    todosUrlRequest.httpBody = Data(newTodo.utf8)
                } catch
                {
                    print("Error: cannot create JSON from todo")
                    group.leave()
                    return
                }
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: todosUrlRequest)
                {
                    (data, responses, error) in
                    // check for any errors
                    guard error == nil else
                    {
                        print("error calling GET on /todos/1")
                        print(error!)
                        group.leave()
                        return
                    }
                    // make sure we got data
                    guard let responseData = data else
                    {
                        print("Error: did not receive data")
                        group.leave()
                        return
                    }
                    // parse the result as JSON, since that's what the API provides
                    do
                    {
                        guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                            as? NSDictionary else
                        {
                            print("error trying to convert data to JSON")
                            group.leave()
                            return
                        }
                        
                        result = todo
                        
                        NSLog("response : %@", result)
                        group.leave()
                    } catch
                    {
                        print("error trying to convert data to JSON")
                        group.leave()
                    }
                }
                task.resume()
        }
        group.wait()
        
        return result
    }
    
    func RequestAPIenc(urlRequest:String, params:String) -> NSDictionary
    {
        response =  nil
        var result : NSDictionary = [:]
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .background).async
            {
                let todosEndpoint: String = urlRequest
                guard let todosURL = URL(string: todosEndpoint) else
                {
                    print("Error: cannot create URL")
                    group.leave()
                    return
                }
                var todosUrlRequest = URLRequest(url: todosURL)
                todosUrlRequest.httpMethod = "POST"
                let newTodo: String = params
                do
                {
                    todosUrlRequest.httpBody = Data(newTodo.utf8)
                } catch
                {
                    print("Error: cannot create JSON from todo")
                    group.leave()
                    return
                }
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: todosUrlRequest)
                {
                    (data, responses, error) in
                    // check for any errors
                    guard error == nil else
                    {
                        print("error calling GET on /todos/1")
                        print(error!)
                        group.leave()
                        return
                    }
                    // make sure we got data
                    guard let responseData = data else
                    {
                        print("Error: did not receive data")
                        group.leave()
                        return
                    }
                    // parse the result as JSON, since that's what the API provides
                    do
                    {
                        let jsonString = JoDess.decode(String(data: data!, encoding: .utf8), key: STRING_KEY)
                        let dataString = Data((jsonString?.utf8)!)
                        guard let todo = try JSONSerialization.jsonObject(with: dataString, options: [])
                            as? NSDictionary else
                        {
                            print("error trying to convert data to JSON")
                            group.leave()
                            return
                        }
                        
                        result = todo
                        
                        NSLog("response : %@", result)
                        group.leave()
                    } catch
                    {
                        print("error trying to convert data to JSON")
                        group.leave()
                    }
                }
                task.resume()
        }
        group.wait()
        
        return result
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
