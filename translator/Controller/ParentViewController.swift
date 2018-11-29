//
//  ParentViewController.swift
//
//  Created by Michael Carolius on 31/05/18.
//  Copyright © 2018 MC. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit
import CoreData

open class ParentViewController: UIViewController,
                                UITextViewDelegate
{
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    var response: NSDictionary?
    var loading: UIView?
    var defaults: UserDefaults! = UserDefaults.standard
    var picker: UIPickerView?
    var lang, langCode : NSMutableArray!
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
        
        if (defaults.object(forKey: "Language") != nil && defaults.object(forKey: "LanguageCode") != nil)
        {
            lang = ((self.defaults.object(forKey: "Language") as! NSArray).mutableCopy() as! NSMutableArray)
            langCode = ((self.defaults.object(forKey: "LanguageCode") as! NSArray).mutableCopy() as! NSMutableArray)
        }
        else
        {
            lang = ["key1", "key2", "key3", "key4", "key5",
                    "key6", "key7", "key8", "key9", "key10",
                    "key11", "key12", "key13", "key14",
                    "key15", "key16", "key17", "key18",
                    "key19", "key20", "key21", "key22",
                    "key23", "key24", "key25", "key26",
                    "key27", "key28", "key29", "key30",
                    "key31"]
            langCode = ["en", "id", "zh-CN", "zh-TW", "ar",
                        "ca", "hr", "cs", "da", "nl",
                        "fi", "fr", "de", "el",
                        "hi", "hu", "it", "ja",
                        "ko", "ms", "pl", "pt",
                        "ro", "ru", "sk", "es",
                        "sv", "th", "tr", "uk",
                        "vi"];
//            "de-AT", "yue-CN", "hi-IN-translit",
//            "hu-HU", "zh-HK", "nb-NO", "hr-HR", "he-IL",
//            "wuu-CN", "de-CH", "de-DE", "hi-Latn",
            
            defaults.set(lang, forKey: "Language")
            defaults.set(langCode, forKey: "LanguageCode")
            defaults.synchronize()
        }
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDelegate.persistentContainer.viewContext
    }

    override open func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UI
    public func ChangeBG(sender:UIViewController, image:String)
    {
        if (image == "")
        {
            bgImage.image = UIImage(named: image)
            bgImage.backgroundColor = UIColor.white
        }
        else
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
    
    public func TextToSpeech(str: String, lang: String)
    {
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
//        utterance.rate = 0.25
//        utterance.pitchMultiplier = 0.25
//        utterance.volume = 1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    public func Share(shareString:String)
    {
        let textToShare = [ shareString ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
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
    
    public func L(key:String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
    
    public func PasteText() -> String
    {
        let pasteboard = UIPasteboard.general
        return pasteboard.string ?? ""
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
    
    public func OpenURL(urlStr:String)
    {
        guard let url = URL(string: urlStr) else
        {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
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
    
    
    //MARK: COREDATA
    func InsertCoreData(tableName:String, dict:NSDictionary) -> Void
    {
        let entity = NSEntityDescription.entity(forEntityName: tableName, in: context)
        let newLanguage = NSManagedObject(entity: entity!, insertInto: context)
        
        for (key, value) in dict
        {
            newLanguage.setValue(value, forKey: key as! String)
        }
        
        appDelegate.saveContext()
    }
    
    func UpdateCoreData(tableName:String, query:NSPredicate, dict:NSDictionary) -> Void
    {
        let requestUpdate = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        requestUpdate.predicate = query
        requestUpdate.returnsObjectsAsFaults = false
        do
        {
            let result = try context.fetch(requestUpdate)
            if result.count > 0
            {
                let objectToUpdate = result[0] as! NSManagedObject

                for (key, value) in dict
                {
                    objectToUpdate.setValue(value, forKey: key as! String)
                }
                try context.save()
            }
        }
        catch
        {
            print("Failed")
        }
    }
    
    func DeleteCoreData(tableName:String, query:NSPredicate) -> Void
    {
        let requestDelete = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        requestDelete.predicate = query
        requestDelete.returnsObjectsAsFaults = false
        do
        {
            let result = try context.fetch(requestDelete)
            if result.count > 0
            {
                let objectToDelete = result[0] as! NSManagedObject
                context.delete(objectToDelete)
                try context.save()
            }
        }
        catch
        {
            print("Failed")
        }
    }
    
    func SelectCoreData(tableName:String, query:NSPredicate) -> NSArray
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LanguageTable")
//        request.predicate = NSPredicate(format: "id = %@", "3")
        request.returnsObjectsAsFaults = false
        do
        {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let arr: NSMutableArray! = []
                for data in result as! [NSManagedObject]
                {
                    let dic:NSDictionary = ["id":data.value(forKey: "id") as! String, "languageCode":data.value(forKey: "languageCode") as! String,"languageName":data.value(forKey: "languageName") as! String]
                    arr.addObjects(from: [dic as Any])
//                    print(data.value(forKey: "id") as! String)
//                    print(data.value(forKey: "languageCode") as! String)
//                    print(L(key: data.value(forKey: "languageName") as! String))
                }
                return arr.mutableCopy() as! NSArray
            }
        }
        catch
        {
            print("Failed")
        }
        return NSArray()
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
                todosUrlRequest.cachePolicy = .reloadIgnoringLocalCacheData
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
                        let jsonString = JoDess.decode(String(data: responseData, encoding: .utf8), key: STRING_KEY)
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
