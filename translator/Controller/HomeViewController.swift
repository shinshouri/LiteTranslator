//
//  ViewController.swift
//  Lite Translate
//
//  Created by MC on 14/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit
import Vision
import StoreKit

class HomeViewController: ParentViewController,
                        UITableViewDelegate,
                        UITableViewDataSource,
                        UINavigationControllerDelegate,
                        UIImagePickerControllerDelegate,
                        SKProductsRequestDelegate,
                        SKPaymentTransactionObserver
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
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var imageAds: UIImageView!
    @IBOutlet weak var buttonScroll: UIButton!
    @IBOutlet weak var viewTable: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTableHeight: NSLayoutConstraint!
    
    private var textObservations = [VNTextObservation]()
    private var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
    
    var imagePicker: UIImagePickerController!
    var imageTake: UIImage!
    var history:NSMutableArray! = []
    var favorite:NSMutableArray! = []
    var adsUrl, langFrom, langTo, langCodeFrom, langCodeTo :String!
    var alertControllerFrom, alertControllerTo :UIAlertController!
    var flagLang, currLang :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SKPaymentQueue.default().restoreCompletedTransactions()
        SetupUI()
        
        RequestAPIAds(urlRequest: URL_REQUESTAPI_ADS, params: String(format: "bundle_id=%@&seq_num=1", BUNDLEID))
        NSLog("%@", getDeviceID())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(self.defaults.object(forKey: "LanguageFrom") != nil)
        {
            langFrom = L(key: (self.defaults.object(forKey: "LanguageFrom") as! String))
            langCodeFrom = L(key: (self.defaults.object(forKey: "LanguageCodeFrom") as! String))
            buttonFrom.setTitle(langFrom, for: .normal)
            labelFrom.text = langFrom
            langTo = L(key: (self.defaults.object(forKey: "LanguageTo") as! String))
            langCodeTo = L(key: (self.defaults.object(forKey: "LanguageCodeTo") as! String))
            buttonTo.setTitle(langTo, for: .normal)
            labelTo.text = langTo
        } else
        {
            langFrom = L(key: "key1")
            langCodeFrom = "en"
            buttonFrom.setTitle(langFrom, for: .normal)
            labelFrom.text = langFrom
            langTo = L(key: "key2")
            langCodeTo = "id"
            buttonTo.setTitle(langTo, for: .normal)
            labelTo.text = langTo
            self.defaults.set(self.langFrom, forKey: "LanguageFrom")
            self.defaults.set(self.langCodeFrom, forKey: "LanguageCodeFrom")
            self.defaults.set(self.langTo, forKey: "LanguageTo")
            self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
            self.defaults.synchronize()
        }
        
        if (self.defaults.object(forKey: "History") != nil) {
            history = ((self.defaults.object(forKey: "History") as! NSArray).mutableCopy() as! NSMutableArray)
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: IBAction
    @IBAction func SelectFrom(_ sender: Any)
    {
        flagLang = "From"
        currLang = buttonFrom.titleLabel?.text
        performSegue(withIdentifier: "Language", sender: self)
//        present(alertControllerFrom, animated: true, completion: nil)
    }
    
    @IBAction func SelectTo(_ sender: Any)
    {
        flagLang = "To"
        currLang = buttonTo.titleLabel?.text
        performSegue(withIdentifier: "Language", sender: self)
//        present(alertControllerTo, animated: true, completion: nil)
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
            TextToSpeech(str: textFrom.text, lang: langCodeFrom)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: L(key: "key32"), message: L(key: "key33")), animated: true, completion: nil)
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
            present(ShowAlertViewController(sender: self, title: L(key: "key32"), message: L(key: "key33")), animated: true, completion: nil)
        }
    }
    
    @IBAction func Zoom(_ sender: Any)
    {
        if textTo.text.count > 0
        {
            performSegue(withIdentifier: "Zoom", sender: self)
        }
        else
        {
            present(ShowAlertViewController(sender: self, title: L(key: "key32"), message: L(key: "key33")), animated: true, completion: nil)
        }
    }
    
    @IBAction func CopyTo(_ sender: Any)
    {
        CopyText(str: textTo.text)
    }
    
    @IBAction func TableScrolling(_ sender: Any)
    {
        HandleSwipeButton()
    }
    
    @IBAction func GoToConversation(_ sender: Any)
    {
//        if KeyChainStore.load("ExpiredDate") != nil {
            performSegue(withIdentifier: "Conversation", sender: self)
//        }
//        else
//        {
//            performSegue(withIdentifier: "Purchase", sender: self)
//        }
    }
    
    @IBAction func GoToOCR(_ sender: Any)
    {
        if KeyChainStore.load("ExpiredDate") != nil {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                selectImageFrom("camera")
            }
        }
        else
        {
            performSegue(withIdentifier: "Purchase", sender: self)
        }
    }
    
    @IBAction func GoToFavorite(_ sender: Any)
    {
        BackgroundTap()
        performSegue(withIdentifier: "Favorite", sender: self)
    }
    
    @IBAction func GoToPurchase(_ sender: Any)
    {
        BackgroundTap()
        performSegue(withIdentifier: "Purchase", sender: self)
    }
    
    //MARK: Function
    func SetupUI() -> Void
    {
        buttonFrom.layer.cornerRadius = 10
        buttonFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        buttonFrom.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        buttonFrom.layer.borderWidth = 1
        buttonTo.layer.cornerRadius = 10
        
        viewFrom.layer.cornerRadius = 10
        viewFrom.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        viewFrom.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_SECONDARY).cgColor
        viewFrom.layer.borderWidth = 1
        textFrom.returnKeyType = .go
        
        viewTo.layer.cornerRadius = 10
        
        textTo.isEditable = false
        
        viewTable.layer.cornerRadius = 10
        
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeButton))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeButton))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

        imageHeight.constant = 0
    }
    
    @objc func HandleSwipeButton()
    {
        if viewTableHeight.constant == 5
        {
            UIView.animate(withDuration: 0.5, animations:{() -> Void in
                self.viewTableHeight.constant = self.imageHeight.constant == 0 ? -(self.view.frame.size.height/1.83) : -(self.view.frame.size.height/1.57)
                self.view.layoutIfNeeded()})
            buttonScroll.setImage(UIImage(named: "down arrow"), for: .normal)
        }
        else
        {
            UIView.animate(withDuration: 0.5, animations:{() -> Void in
                self.viewTableHeight.constant = 5
                self.view.layoutIfNeeded()})
            buttonScroll.setImage(UIImage(named: "up arrow"), for: .normal)
        }
    }
    
    @objc func TableFavoriteTap(id:UIButton)
    {
        let tempDic = history.object(at: id.tag) as! NSDictionary
        if ((tempDic.object(forKey: "favorite") as? String) == "Y") {
            let dic: NSDictionary = ["textFrom":(tempDic.object(forKey: "textFrom") as? String)!, "textTo":(tempDic.object(forKey: "textTo") as? String)!, "favorite": "N", "index":(tempDic.object(forKey: "index") as? Int)!]
            history[id.tag] = dic
            defaults.set(history, forKey: "History")
        } else
        {
            let dic: NSDictionary = ["textFrom":(tempDic.object(forKey: "textFrom") as? String)!, "textTo":(tempDic.object(forKey: "textTo") as? String)!, "favorite": "Y", "index":(tempDic.object(forKey: "index") as? Int)!]
            history[id.tag] = dic
            defaults.set(history, forKey: "History")
        }
        tableView.reloadData()
    }
    
    @objc func BackgroundTap()
    {
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.BackgroundTap)))
    }
    
    @objc func AdsTap()
    {
        self.OpenURL(urlStr: adsUrl)
    }
    
    
    //MARK: In App Purchase Delegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let productArr = response.products;
        NSLog("%@", productArr)
        
        if (productArr.count == 0) {
            loading?.removeFromSuperview()
            present(ShowAlertViewController(sender: self, title: self.L(key: "key34"), message: self.L(key: "key36")), animated: true, completion: nil)
            return;
        }
        
        var p:SKProduct? = nil
        
        for pro in productArr {
            if (pro.productIdentifier == INAPP_PRODUCT)
            {
                p = pro;
            }
        }
        
        SKPaymentQueue.default().add(SKPayment(product: p!));
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    loading?.removeFromSuperview()
                    ShowLoading()
                    self.completeTransaction(transaction: transaction as! SKPaymentTransaction)
                    break;
                case .failed:
                    print("Purchased Failed");
                    loading?.removeFromSuperview()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    loading?.removeFromSuperview()
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
    
    func completeTransaction(transaction:SKPaymentTransaction) -> Void {
        SKPaymentQueue.default().finishTransaction(transaction)
        let temptransactionReceipt:String = try! String(data:Data(contentsOf: Bundle.main.appStoreReceiptURL!), encoding: String.Encoding.utf8)!
        var base64:String = JoDess.encodeBase64(with: temptransactionReceipt)
        base64 = base64.replacingOccurrences(of: "\n", with: "")
        base64 = base64.replacingOccurrences(of: "\r", with: "")
        base64 = base64.replacingOccurrences(of: "+", with: "%2B")
        
        self.RequestAPIAppPurchaseAds(urlRequest: URL_REQUESTAPI_APPPURCHASEADS, params: String(format: "receipt=%@&good_id=%@&bundle_id=%@&uuid=%@", base64, INAPP_PRODUCT, BUNDLEID, self.getDeviceID()))
    }
    
    
    //MARK: imagePickerController Delegate
    func selectImageFrom(_ source: String){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
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
        imageTake = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
        picker.dismiss(animated: true, completion: nil)
        handleWithTesseract(image: imageTake)
    }
    
    func handleWithTesseract(image: UIImage) {
//        let stillImageFilter:GPUImageAdaptiveThresholdFilter
//        stillImageFilter.blurRadiusInPixels = 4.0 // adjust this to tweak the blur radius of the filter, defaults to 4.0
//
//        // Retrieve the filtered image from the filter
//        let filteredImage:UIImage = stillImageFilter.
//        [stillImageFilter imageByFilteringImage:image];
//
//        // Give Tesseract the filtered image
//        tesseract.image = filteredImage;
        
        
        self.tesseract?.image = image.g8_blackAndWhite()
        self.tesseract?.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-", forKey: "tessedit_char_whitelist")
        self.tesseract?.recognize()
        
        textFrom.text = tesseract?.recognizedText ?? ""
        if textFrom.text.count > 0
        {
            RequestAPITranslate(urlRequest: URL_REQUESTAPI_TRANSLATE, params: String(format: "text=%@&from=%@&to=%@&uuid=%@", self.textFrom.text!, langCodeFrom, langCodeTo, self.getDeviceID()))
        }
        NSLog("%@", textFrom.text)
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
        
        cell.labelFrom?.text = (history.object(at: indexPath.row) as? NSDictionary)?.object(forKey: "textFrom") as? String
        cell.labelFrom?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
        cell.labelTo?.text = (history.object(at: indexPath.row) as? NSDictionary)?.object(forKey: "textTo") as? String
        cell.labelTo?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
        if((history.object(at: indexPath.row) as? NSDictionary)?.object(forKey: "favorite") as? String == "Y")
        {
            cell.imageFavorite?.image = UIImage(named: "favorite icon_red")
        }
        else
        {
            cell.imageFavorite?.image = UIImage(named: "favorite icon_red outline")
        }
        cell.buttonImageFavorite.tag = indexPath.row
        cell.buttonImageFavorite.addTarget(self, action: #selector(TableFavoriteTap(id:)), for: .touchUpInside)
        
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
//            NSLog("%@", (history.object(at: 1) as! NSDictionary).object(forKey: "textFrom") as! String)
            if textFrom.text.count > 0
            {
                RequestAPITranslate(urlRequest: URL_REQUESTAPI_TRANSLATE, params: String(format: "text=%@&from=%@&to=%@&uuid=%@", self.textFrom.text!, langCodeFrom, langCodeTo, self.getDeviceID()))
            }
            return false
        }
    
        return textView.text.count + (text.count - range.length) <= 100
    }
    
    //MARK: Segue Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "Zoom")
        {
            let vc = segue.destination as! ZoomViewController
            vc.textZoom = textTo.text
        }
        else if (segue.identifier == "Favorite")
        {
            let vc = segue.destination as! FavoriteViewController
            vc.history = history.mutableCopy() as? NSMutableArray
        }
        else if (segue.identifier == "Conversation")
        {
            let vc = segue.destination as! ConversationViewController
            vc.langFrom = self.langFrom
            vc.langCodeFrom = self.langCodeFrom
            vc.langTo = self.langTo
            vc.langCodeTo =  self.langCodeTo
        }
        else if (segue.identifier == "Language")
        {
            let vc = segue.destination as! LanguageViewController
            vc.flag = self.flagLang
            vc.currentLang = self.currLang
        }
    }
    
    //MARK: API
    func RequestAPITranslate(urlRequest:String, params:String) -> Void
    {
        BackgroundTap()
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
        {
            self.response = self.RequestAPI(urlRequest: urlRequest, params: params)
            DispatchQueue.main.async
            {
                if((self.response?.object(forKey: "error") as? Int) == 0)
                {
                    if(!self.textTo.text.contains("#") && !(self.textFrom.text == self.textTo.text))
                    {
                        self.textTo.text = ((self.response?.object(forKey: "result") as! NSDictionary).object(forKey: "text") as? String)!
                        let dic: NSDictionary = ["textFrom":self.textFrom.text, "textTo":self.textTo.text, "favorite": self.buttonFavorite.tag == 0 ? "N" :"Y", "index":self.history.count > 0 ? self.history.count : 0]
//                        self.history.addObjects(from: [dic as Any])
                        self.history.insert(dic, at: 0)
                        self.defaults.set(self.history, forKey: "History")
                        self.tableView.reloadData()
                    }
                }
                else
                {
                    self.present(self.ShowAlertViewController(sender: self, title: self.L(key: "key34"), message: self.L(key: "key35")), animated: true, completion: nil)
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
                NSLog("%@", self.response!)
                let arr:NSArray = (self.response?.object(forKey: "advertise") as? NSArray)!
                self.response = (arr.object(at: 0) as! NSDictionary)
                
                if((self.response?.object(forKey: "is_open") as? String) == "1")
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
                            self.imageHeight.constant = self.view.frame.size.width/6
                        }
                    }
                }
                self.loading?.removeFromSuperview()
                
                self.performSegue(withIdentifier: "Purchase", sender: self)
            }
        }
    }
    
    func RequestAPIAppPurchaseAds(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
            {
                self.response = self.RequestAPIenc(urlRequest: urlRequest, params: params)
                DispatchQueue.main.async
                    {
                        KeyChainStore.save("PurchaseID", data: ((self.response?.object(forKey: "data") as! NSDictionary).object(forKey: "uuid") as? String)!)
                        KeyChainStore.save("ExpiredDate", data: ((self.response?.object(forKey: "data") as! NSDictionary).object(forKey: "expired_time") as? String)!)
                        self.loading?.removeFromSuperview()
                }
        }
    }
}

