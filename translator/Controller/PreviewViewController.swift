//
//  PreviewViewController.swift
//  translator
//
//  Created by a on 29/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class PreviewViewController: ParentViewController {

    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var imgLangFrom: UIImageView!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var imgLangTo: UIImageView!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var buttonTo: UIButton!
    
    var langFrom, langTo, langCodeFrom, langCodeTo :String!
    var flagLang, currLang :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ChangeBG(sender: self, image: "bg")
        viewLanguage.layer.cornerRadius = 10
        buttonFrom.layer.cornerRadius = 10
        buttonTo.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(self.defaults.object(forKey: "LanguageFrom") != nil)
        {
            langFrom = L(key: (self.defaults.object(forKey: "LanguageFrom") as! String))
            langCodeFrom = L(key: (self.defaults.object(forKey: "LanguageCodeFrom") as! String))
            labelFrom.text = langFrom
            imgLangFrom.image = UIImage(named: langCodeFrom)
            langTo = L(key: (self.defaults.object(forKey: "LanguageTo") as! String))
            langCodeTo = L(key: (self.defaults.object(forKey: "LanguageCodeTo") as! String))
            labelTo.text = langTo
            imgLangTo.image = UIImage(named: langCodeTo)
        }
        else
        {
            langFrom = L(key: "key1")
            langCodeFrom = "en"
            imgLangFrom.image = UIImage(named: langCodeFrom)
            labelFrom.text = langFrom
            langTo = L(key: "key2")
            langCodeTo = "id"
            imgLangTo.image = UIImage(named: langCodeTo)
            labelTo.text = langTo
            self.defaults.set(self.langFrom, forKey: "LanguageFrom")
            self.defaults.set(self.langCodeFrom, forKey: "LanguageCodeFrom")
            self.defaults.set(self.langTo, forKey: "LanguageTo")
            self.defaults.set(self.langCodeTo, forKey: "LanguageCodeTo")
            self.defaults.synchronize()
        }
    }
    
    @IBAction func SelectFrom(_ sender: Any)
    {
        flagLang = "From"
        currLang = labelFrom.text
        performSegue(withIdentifier: "Language", sender: self)
    }
    
    @IBAction func Swap(_ sender: Any)
    {
        langFrom = labelTo.text
        langTo = labelFrom.text
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
    
    @IBAction func SelectTo(_ sender: Any)
    {
        flagLang = "To"
        currLang = labelTo.text
        performSegue(withIdentifier: "Language", sender: self)
    }
    
    @IBAction func buttonNext(_ sender: Any)
    {
        performSegue(withIdentifier: "Preview", sender: self)
    }
    
    //MARK: Segue Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "Language")
        {
            let vc = segue.destination as! LanguageViewController
            vc.flag = self.flagLang
            vc.currentLang = self.currLang
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
