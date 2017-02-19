//
//  CategoryCell.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit

class CategoryCell: BaseCell, CellIdentifiable {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
        layer.cornerRadius = 4
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = layer.cornerRadius
    
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    var loading: Bool = false {
        didSet {
            if loading {
                categoryImageView.alpha = 0
                categoryNameLabel.alpha = 0
                indicator.isHidden = false
                indicator.startAnimating()
                isUserInteractionEnabled = false
            } else {
                categoryImageView.alpha = 1
                categoryNameLabel.alpha = 1
                indicator.stopAnimating()
                isUserInteractionEnabled = true
            }
        }
    }
    
    func configWith(category: Category?) {
        if let category = category {
            loading = false
            categoryImageView.image = category.image
            categoryNameLabel.text = category.name
        } else {
            loading = true
        }
    }
}
