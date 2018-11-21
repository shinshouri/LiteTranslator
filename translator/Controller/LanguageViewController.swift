//
//  LanguageViewController.swift
//  translator
//
//  Created by a on 19/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit

class LanguageViewController: ParentViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UITextFieldDelegate,
                            UISearchBarDelegate
{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var flag, currentLang:String!
    var searchActive = false
    var filtered:Array<String> = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: SearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let data = lang as! Array<String>
        
        filtered = data.filter({ (text) -> Bool in
            let tmp:NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if (searchText.count > 0){
            searchActive = true
        }
        else{
            searchActive = false
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(searchActive)
        {
            return filtered.count
        }
        else
        {
            return lang.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableViewCellLanguage = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! TableViewCellLanguage
        
        if(searchActive){
            cell.labelLanguage?.text = filtered[indexPath.row]
            cell.labelLanguage?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
            if currentLang == filtered[indexPath.row]
            {
                cell.imageFavorite?.image = UIImage(named: "checklist icon")
            }
            else
            {
                cell.imageFavorite?.image = nil
            }
        }
        else{
            cell.labelLanguage?.text = lang.object(at: indexPath.row) as? String
            cell.labelLanguage?.textColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY)
            if currentLang == (lang.object(at: indexPath.row) as? String)
            {
                cell.imageFavorite?.image = UIImage(named: "checklist icon")
            }
            else
            {
                cell.imageFavorite?.image = nil
            }
        }
        
        cell.backgroundColor = GeneratorUIColor(intHexColor: THEME_GENERAL_PRIMARY)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = GeneratorUIColor(intHexColor: THEME_GENERAL_TERTIARY).cgColor;
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(searchActive)
        {
            if (flag == "From") {
                self.defaults.set(filtered[indexPath.row], forKey: "LanguageFrom")
                self.defaults.set(langCode.object(at: lang.index(of: filtered[indexPath.row])), forKey: "LanguageCodeFrom")
                self.defaults.synchronize()
            }
            else if (flag == "To")
            {
                self.defaults.set(filtered[indexPath.row], forKey: "LanguageTo")
                self.defaults.set(langCode.object(at: lang.index(of: filtered[indexPath.row])), forKey: "LanguageCodeTo")
                self.defaults.synchronize()
            }
            currentLang = filtered[indexPath.row]
        }
        else
        {
            if (flag == "From") {
                self.defaults.set(lang.object(at: indexPath.row), forKey: "LanguageFrom")
                self.defaults.set(langCode.object(at: indexPath.row), forKey: "LanguageCodeFrom")
                self.defaults.synchronize()
            }
            else if (flag == "To")
            {
                self.defaults.set(lang.object(at: indexPath.row), forKey: "LanguageTo")
                self.defaults.set(langCode.object(at: indexPath.row), forKey: "LanguageCodeTo")
                self.defaults.synchronize()
            }
            currentLang = lang.object(at: indexPath.row) as? String
        }
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
    
    
    //MARK: Textfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
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
