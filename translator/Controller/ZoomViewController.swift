//
//  ZoomViewController.swift
//  Lite Translate
//
//  Created by MC on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class ZoomViewController: UIViewController {

    
    @IBOutlet weak var ZoomLabel: UILabel!
    
    var textZoom: String!
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")        
        ZoomLabel.adjustsFontSizeToFitWidth = true
        ZoomLabel.minimumScaleFactor = 0.01
        ZoomLabel.numberOfLines = 0
        ZoomLabel.text = textZoom
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.BackgroundTap)))
        
        appDel.myOrientation = .landscape
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        appDel.myOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return .landscape
    }
    
    //MARK: Function
    @objc func BackgroundTap()
    {
        self.navigationController?.popViewController(animated: true)
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
