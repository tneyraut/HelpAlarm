//
//  TableViewCellWithTwoButtons.swift
//  CellLibrary
//
//  Created by Thomas Mac on 06/06/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import UIKit

class TableViewCellWithTwoButtons: UITableViewCell {

    private let buttonOne = UIButton(type: UIButtonType.RoundedRect)
    private let buttonTwo = UIButton(type: UIButtonType.RoundedRect)
    
    internal var mainTableViewController = MainTableViewController()
    
    internal var indice = -1
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let decalage = CGFloat(10.0)
        
        self.buttonTwo.frame = CGRectMake(self.frame.size.width - decalage - 3 * self.frame.size.height / 4, decalage, 3 * self.frame.size.height / 4, self.frame.size.height - 2 * decalage)
        self.buttonTwo.setBackgroundImage(UIImage(named:NSLocalizedString("ICON_VALIDATE", comment:"")), forState:.Normal)
        self.buttonTwo.titleLabel?.hidden = true
        
        self.buttonTwo.addTarget(self, action:#selector(self.buttonTwoActionListener), forControlEvents:.TouchUpInside)
        
        self.buttonOne.frame = CGRectMake(self.buttonTwo.frame.origin.x - decalage - self.buttonTwo.frame.size.width, decalage, self.buttonTwo.frame.size.width, self.buttonTwo.frame.size.height)
        self.buttonOne.setBackgroundImage(UIImage(named:NSLocalizedString("ICON_PLAY", comment:"")), forState:.Normal)
        self.buttonOne.titleLabel?.hidden = true
        
        self.buttonOne.addTarget(self, action:#selector(self.buttonOneActionListener), forControlEvents:.TouchUpInside)
        
        self.imageView?.frame = CGRectMake(decalage, decalage, self.frame.size.height - 2 * decalage, self.frame.size.height - 2 * decalage)
        
        self.textLabel?.frame = CGRectMake((self.imageView?.frame.size.width)! + 2 * decalage, 0.0, self.frame.size.width - (self.imageView?.frame.size.width)! - 3 * decalage - self.buttonOne.frame.width - self.buttonTwo.frame.width, self.frame.size.height)
        
        self.layer.borderColor = UIColor(red:213.0/255.0, green:210.0/255.0, blue:199.0/255.0, alpha:1.0).CGColor
        
        self.layer.borderWidth = 2.5
        self.layer.cornerRadius = 7.5
        self.layer.shadowOffset = CGSizeMake(0, 1)
        self.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        
        self.addSubview(self.buttonOne)
        self.addSubview(self.buttonTwo)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func buttonOneActionListener()
    {
        self.mainTableViewController.playMusicAtIndice(self.indice, numberOfLoops:0, volume:0.5)
    }
    
    @objc private func buttonTwoActionListener()
    {
        self.mainTableViewController.setNewFavorisMusic(self.indice)
    }

}
