//
//  PurchaseViewController.swift
//  translator
//
//  Created by a on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class PurchaseViewController: ParentViewController  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonBuyMonthly: UIButton!
    @IBOutlet weak var buttonBuyYearly: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSize(width: self.view.frame.size.width*2, height: self.view.frame.size.height)
        buttonBuyMonthly.layer.cornerRadius = 20
        buttonBuyYearly.layer.cornerRadius = 20
        ChangeBG(sender: self, image: "BG iPhone 2")
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
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
