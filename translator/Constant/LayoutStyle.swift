//
//  LayoutStyles.swift
//
//  Created by Michael Carolius on 16/11/18.
//  Copyright © 2018 MC. All rights reserved.
//


// MARK: IMPORT

import Foundation
import UIKit


//MARK: TABLE VIEW CELL

class TableViewCellFavorite: UITableViewCell
{
    // MARK: USER INTERFACE COMPONENT
    
    @IBOutlet weak var imageLangFrom: UIImageView!
    @IBOutlet weak var imageLangTo: UIImageView!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var imageFavorite: UIImageView!
    @IBOutlet weak var buttonImageFavorite: UIButton!
    
    // MARK: REQUIRED
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        
    }
}

class TableViewCellLanguage: UITableViewCell
{
    // MARK: USER INTERFACE COMPONENT
    
    @IBOutlet weak var imageFavorite: UIImageView!
    @IBOutlet weak var imageLanguage: UIImageView!
    @IBOutlet weak var labelLanguage: UILabel!
    
    // MARK: REQUIRED
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        
    }
}
