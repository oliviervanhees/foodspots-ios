//
//  F4FFoodSpotTableViewCell.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit

protocol FoodSpotCellLikeTappedDelegate {
    func likeTapped(cell: F4FFoodSpotTableViewCell)
}

class F4FFoodSpotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var viewMain: UIView!
    
    var delegate: FoodSpotCellLikeTappedDelegate?
    
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonLike.layer.cornerRadius = 5
        buttonLike.layer.borderWidth = 1
        buttonLike.layer.borderColor = F4FColors.blueColor.CGColor
        
        viewMain.layer.cornerRadius = 5
        viewMain.layer.masksToBounds = true
        viewMain.backgroundColor = F4FColors.backgroundColorDark
        
        layer.backgroundColor =  UIColor.clearColor().CGColor
    }
    
    func drawLiked(){
        drawLiked(isLiked)
    }
    
    private func drawLiked(liked: Bool){
        let color = liked ? F4FColors.blueColor : F4FColors.mainColor
        let text = liked ? "Navigate To FoodSpot" : "Like FoodSpot"
        
        buttonLike.backgroundColor = color
        buttonLike.setTitle(text, forState: .Normal)
    }
    
    @IBAction func tappedLikeButton(sender: AnyObject) {
        if(!isLiked){
            drawLiked(!isLiked)
        }
        
        if let del = delegate{
            del.likeTapped(self)
        }
    }
}
