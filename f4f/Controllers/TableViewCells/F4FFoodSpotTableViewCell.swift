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
    func routeTapped(cell: F4FFoodSpotTableViewCell)
}

class F4FFoodSpotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelFriends: UILabel!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonRoute: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var friendImage1: UIImageView!
    @IBOutlet weak var friendImage2: UIImageView!
    @IBOutlet weak var friendImage3: UIImageView!
    
    var delegate: FoodSpotCellLikeTappedDelegate?
    
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonLike.layer.cornerRadius = 5
        buttonLike.layer.borderWidth = 0
        buttonLike.layer.borderColor = F4FColors.blueColor.CGColor
        buttonLike.setImage(UIImage(named: "Heart"), forState: .Normal)
        
        /*buttonLike.titleLabel!.textAlignment = .Center
        buttonLike.contentHorizontalAlignment = .Left
        buttonLike.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)*/
        buttonLike.imageEdgeInsets = UIEdgeInsetsMake(0,-10,0,0)

        buttonRoute.layer.cornerRadius = 5
        buttonRoute.layer.borderWidth = 0
        buttonRoute.layer.borderColor = F4FColors.blueColor.CGColor
        buttonRoute.backgroundColor = F4FColors.blueColor
        buttonRoute.setImage(UIImage(named: "Car"), forState: .Normal)
        buttonRoute.tintColor = UIColor.whiteColor()
        buttonRoute.imageEdgeInsets = UIEdgeInsetsMake(0,-10,0,0)

        viewMain.layer.cornerRadius = 5
        viewMain.layer.masksToBounds = true
        viewMain.backgroundColor = F4FColors.backgroundColorDark
        
        layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    func drawLiked(){
        drawLiked(isLiked)
    }
    
    private func drawLiked(liked: Bool){
        let color = liked ? UIColor.clearColor() : F4FColors.blueColor
        let text = liked ? "You liked this FoodSpot" : "Like FoodSpot"
        let textColor = liked ? F4FColors.blueColor : UIColor.whiteColor()
        let image = liked ? UIImage(named: "Heart_filled") : UIImage(named: "Heart")
        
        buttonLike.backgroundColor = color
        buttonLike.setTitle(text, forState: .Normal)
        buttonLike.titleLabel!.textColor = textColor
        buttonLike.tintColor = textColor
        buttonLike.setImage(image, forState: .Normal)
    }
    
    // MARK: - Button actions
    
    @IBAction func tappedRouteButton(sender: AnyObject) {
        if let del = delegate{
            del.routeTapped(self)
        }
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
