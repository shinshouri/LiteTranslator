//
//  ViewController.swift
//  translator
//
//  Created by a on 14/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit
import Vision

class HomeViewController: ParentViewController,
                        UITableViewDelegate,
                        UITableViewDataSource,
                        UIImagePickerControllerDelegate
{
    //MARK: Property
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var buttonTo: UIButton!
    @IBOutlet weak var viewFrom: UIView!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var textFrom: UITextView!
    @IBOutlet weak var viewTo: UIView!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var textTo: UITextView!
    @IBOutlet weak var imageAds: UIImageView!
    @IBOutlet weak var viewTable: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMenu: UIView!
    
    @IBOutlet weak var ToggleMenu: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    private var textObservations = [VNTextObservation]()
    private var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
    
    var imagePicker: UIImagePickerController!
    var imageTake: UIImage!
    var history:NSMutableArray! = []
    var favorite:NSMutableArray! = []
    var adsUrl, langFrom, langTo, langCodeFrom, langCodeTo :String!
    var alertControllerFrom, alertControllerTo :UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SetupUI()
        
        RequestAPIAds(urlRequest: URL_REQUESTAPI_ADS, params: String(format: "bundle_id=%@&seq_num=1", BUNDLEID))
        NSLog("%@", getDeviceID())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if((self.defaults.object(forKey: "LanguageFrom") as? String)?.count ?? 0 > 0)
        {
            langFrom = (self.defaults.object(forKey: "LanguageFrom") as! String)
            langCodeFrom = (self.defaults.object(forKey: "LanguageCodeFrom") as! String)
            buttonFrom.setTitle(langFrom, for: .normal)
            labelFrom.text = langFrom
            langTo = (self.defaults.object(forKey: "LanguageTo") as! String)
            langCodeTo = (self.defaults.object(forKey: "LanguageCodeTo") as! String)
            buttonTo.setTitle(langTo, for: .normal)
            labelTo.text = langTo
        } else
        {
            langFrom = "English"
            langCodeFrom = "en"
            buttonFrom.setTitle(langFrom, for: .normal)
            labelFrom.text = langFrom
            langTo = "Indonesian"
            langCodeTo = "id"
            buttonTo.setTitle(langTo, for: .normal)
            labelTo.text = langTo
        }
    }
    
    
    //MARK: IBAction
    @IBAction func SelectMenu(_ sender: Any)
    {
        ToggleMenu.constant = 0
    }
    
    @IBAction func SelectFrom(_ sender: Any)
    {
        present(alertControllerFrom, animated: true, completion: nil)
    }
    
    @IBAction func SelectTo(_ sender: Any)
    {
        present(alertControllerTo, animated: true, completion: nil)
    }
    
    @IBAction func Swap(_ sender: Any)
    {
        langFrom = buttonTo.titleLabel?.text
        langTo = buttonFrom.titleLabel?.text
        buttonFrom.setTitle(langFrom, for: .normal)
        buttonTo.setTitle(langTo, for: .normal)
        labelFrom.text = langFrom
        labelTo.text = langTo
        let temp = langCodeFrom
        langCodeFrom = langCodeTo
        langCodeTo = temp
        self.defaults.set(self.langFrom, forKey: "LanguageFrom")
        self.defaults.set(self.langCodeFrom, forKey: "LanguageCodeFrom")
        self.defaults.set(self.langTo, forKey: "LanguageTo")
        self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
        self.defaults.synchronize()
    }
    
    @IBAction func SynthesisFrom(_ sender: Any)
    {
        if textFrom.text.count > 0
        {
            TextToSpeech(str: textFrom.text, lang: "en-US")
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
            TextToSpeech(str: textTo.text, lang: "en-US")
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: "Warning!", message: "No Text"), animated: true, completion: nil)
        }
    }
    
    @IBAction func Zoom(_ sender: Any)
    {
        performSegue(withIdentifier: "Zoom", sender: self)
    }
    
    @IBAction func CopyTo(_ sender: Any)
    {
        CopyText(str: textTo.text)
    }
    
    @IBAction func Favorite(_ sender: Any)
    {
        
    }
    
    @IBAction func GoToConversation(_ sender: Any)
    {
        performSegue(withIdentifier: "Conversation", sender: self)
    }
    
    @IBAction func GoToOCR(_ sender: Any)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            selectImageFrom("camera")
        }
    }
    
    @IBAction func GoToHome(_ sender: Any)
    {
        BackgroundTap()
    }
    
    @IBAction func GoToFavorite(_ sender: Any)
    {
        BackgroundTap()
        performSegue(withIdentifier: "Favorite", sender: self)
    }
    
    @IBAction func GoToOfflineTranslation(_ sender: Any)
    {
        BackgroundTap()
    }
    
    @IBAction func GoToPurchase(_ sender: Any)
    {
        BackgroundTap()
    }
    
    //MARK: Function
    func SetupUI() -> Void
    {
        buttonFrom.layer.cornerRadius = 10
//        buttonFrom.titleLabel?.numberOfLines = 0;
//        buttonFrom.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        buttonFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        buttonFrom.layer.shadowColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        buttonFrom.layer.shadowOpacity = 0.3
        buttonFrom.layer.shadowOffset = CGSize.zero
        buttonFrom.layer.shadowRadius = 3
        buttonFrom.layer.shadowPath = UIBezierPath(rect: buttonFrom.bounds).cgPath
        buttonTo.layer.cornerRadius = 10
        viewFrom.layer.cornerRadius = 10
        viewFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewFrom.layer.shadowColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewFrom.layer.shadowOpacity = 0.3
        viewFrom.layer.shadowOffset = CGSize.zero
        viewFrom.layer.shadowRadius = 3
        viewFrom.layer.shadowPath = UIBezierPath(rect: viewFrom.bounds).cgPath
        viewTo.layer.cornerRadius = 10
        textTo.isEditable = false
        viewTable.layer.cornerRadius = 10
        viewTable.backgroundColor = UIColor.clear
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        viewMenu.layer.cornerRadius = 10
        viewMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.BackgroundTap)))
        
        ToggleMenu.constant = -200
        imageHeight.constant = 0
        
        alertControllerFrom = ShowAlertSheetViewController(sender: self, title: "", message: "Select Language")
        
        for i in 0..<lang.count
        {
            let sendButton = UIAlertAction(title:(self.lang.object(at: i) as! String), style: .default, handler: { (action) -> Void in
                self.buttonFrom.setTitle((self.lang.object(at: i) as! String), for: .normal)
                self.labelFrom.text = (self.lang.object(at: i) as! String)
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
                self.labelTo.text = (self.lang.object(at: i) as! String)
                self.langTo = (self.lang.object(at: i) as! String)
                self.langCodeTo = (self.langCode.object(at: i) as! String)
                self.defaults.set(self.langTo, forKey: "LanguageTo")
                self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
                self.defaults.synchronize()
            })
            alertControllerTo.addAction(sendButton)
        }
    }
    
    @objc func BackgroundTap()
    {
        ToggleMenu.constant = -200
    }
    
    @objc func AdsTap()
    {
        guard let url = URL(string: adsUrl) else
        {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK: imagePickerController Delegate
    func selectImageFrom(_ source: String){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        switch source {
        case "camera":
            imagePicker.sourceType = .camera
        case "photoLibrary":
            imagePicker.sourceType = .photoLibrary
        default:
            return
        }
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        imageTake = nil
        imageTake = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        picker.dismiss(animated: true, completion: nil)
        handleWithTesseract(image: imageTake)
    }
    
    func handleWithTesseract(image: UIImage) {
        self.tesseract?.image = image.g8_blackAndWhite()
        self.tesseract?.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- ", forKey: "tessedit_char_whitelist")
        self.tesseract?.recognize()
        
        textFrom.text = tesseract?.recognizedText ?? ""
        NSLog("%@", textFrom.text)
        //        delegate?.ocrService(self, didDetect: text)
    }
    
    //MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableViewCellFavorite = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! TableViewCellFavorite
        
        cell.labelFrom?.text = "1"
        cell.labelFrom?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
        cell.labelTo?.text = "2"
        cell.labelTo?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
        if(indexPath.row%2 == 0)
        {
            cell.imageFavorite?.image = UIImage(named: "favorite icon_red")
        }
        else
        {
            cell.imageFavorite?.image = UIImage(named: "favorite icon_red outline")
        }
        
        cell.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY).cgColor
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    //MARK: TextView Delegate
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (text == "\n")
        {
//            RequestAPITranslate(urlRequest: URL_REQUESTAPI_TRANSLATE, params: String(format: "text=%@&from=%@&to=%@", self.textFrom.text!, self.labelFrom.text!, self.labelTo.text!))
        }
    
        return textView.text.count + (text.count - range.length) <= 100;
    }
    
    //MARK: Segue Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "Zoom")
        {
            let vc = segue.destination as! ZoomViewController
            vc.textZoom = textTo.text
        }
    }
    
    //MARK: API
    func RequestAPITranslate(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
        {
            self.response = self.RequestAPI(urlRequest: urlRequest, params: params)
            DispatchQueue.main.async
            {
                if((self.response?.object(forKey: "is_open") as? String)! == "1")
                {
                            
                }
                else
                {
                    
                }
                self.loading?.removeFromSuperview()
            }
        }
    }
    
    func RequestAPIAds(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
        {
            self.response = self.RequestAPI(urlRequest: urlRequest, params: params)
            DispatchQueue.main.async
            {
                let arr:NSArray = (self.response?.object(forKey: "advertise") as? NSArray)!
                self.response = (arr.object(at: 0) as! NSDictionary)
                
                if((self.response?.object(forKey: "is_open") as? String)! == "1")
                {
                    let url = URL(string: (self.response?.object(forKey: "image_url") as? String)!)
                
                    DispatchQueue.global().async
                    {
                        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async
                        {
                            self.imageAds.image = UIImage(data: data!)
                            self.adsUrl = (self.response?.object(forKey: "url") as? String)!
                            self.imageAds.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.AdsTap)))
                            self.imageAds.isUserInteractionEnabled = true
                            self.imageHeight.constant = 50
                            self.loading?.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    func RequestAPIAppPurchaseAds(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
        {
            self.response = self.RequestAPI(urlRequest: urlRequest, params: params)
            DispatchQueue.main.async
            {
                if((self.response?.object(forKey: "is_open") as? String)! == "1")
                {
                    
                }
                self.loading?.removeFromSuperview()
            }
        }
    }
}

