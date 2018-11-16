//
//  FavoriteViewController.swift
//  translator
//
//  Created by a on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class FavoriteViewController: ParentViewController,
                            UITableViewDelegate,
                            UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    
    var favorite : NSArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableViewCellFavorite = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! TableViewCellFavorite
        
        cell.labelFrom?.text = "1"
        cell.labelFrom?.textColor = UIColor.white
        cell.labelTo?.text = "2"
        cell.labelTo?.textColor = UIColor.white
        cell.imageFavorite?.image = UIImage(named: "favorite icon_white")
        
        cell.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor;
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
