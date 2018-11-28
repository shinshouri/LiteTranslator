//
//  FavoriteViewController.swift
//  Lite Translate
//
//  Created by MC on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class FavoriteViewController: ParentViewController,
                            UITableViewDelegate,
                            UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    var history : NSMutableArray! = []
    var favorite : NSMutableArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
//        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.delegate = self
        tableView.dataSource = self
        
        for i in 0..<history.count
        {
            if((history.object(at: i) as? NSDictionary)?.object(forKey: "favorite") as? String == "Y")
            {
                let tempDic = history.object(at: i) as! NSDictionary
                favorite.addObjects(from: [tempDic as Any])
            }
        }
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Function
    @objc func TableFavoriteTap(id:UIButton)
    {
        let alertController = ShowAlertViewController(sender: self, title: "Message", message: "Delete from favorite list?")
        
        let yesButton = UIAlertAction(title:"Confirm", style: .default, handler: { (action) -> Void in
            let index = (self.favorite.object(at: id.tag) as! NSDictionary).object(forKey: "index") as! Int
            let tempDic = self.history.object(at: index) as! NSDictionary
            
            let dic: NSDictionary = ["textFrom":(tempDic.object(forKey: "textFrom") as? String)!, "textTo":(tempDic.object(forKey: "textTo") as? String)!, "favorite": "N", "index":(tempDic.object(forKey: "index") as? Int)!]
            self.history[index] = dic
            self.defaults.set((self.history.mutableCopy() as! NSMutableArray), forKey: "History")
            self.defaults.synchronize()
            
            self.favorite.removeObject(at: id.tag)
            
            self.tableView.reloadData()
        })
        alertController.addAction(yesButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favorite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableViewCellFavorite = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! TableViewCellFavorite
        
        cell.labelFrom?.text = (favorite.object(at: indexPath.row) as! NSDictionary).object(forKey: "textFrom") as? String
        cell.labelFrom?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY)
        cell.labelTo?.text = (favorite.object(at: indexPath.row) as! NSDictionary).object(forKey: "textTo") as? String
        cell.labelTo?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_QUATERNARY)
        cell.imageFavorite?.image = UIImage(named: "star_1")
        
        cell.buttonImageFavorite.tag = indexPath.row
        cell.buttonImageFavorite.addTarget(self, action: #selector(TableFavoriteTap(id:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
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
