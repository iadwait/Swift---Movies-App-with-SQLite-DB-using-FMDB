//
//  MoviesViewCell.swift
//  Sqlite FMDB Demo
//
//  Created by Adwait Barkale on 18/12/20.
//  Copyright © 2020 Adwait Barkale. All rights reserved.
//

import UIKit

class MoviesViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
