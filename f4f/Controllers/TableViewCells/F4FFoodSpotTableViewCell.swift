//
//  F4FFoodSpotTableViewCell.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit

protocol FoodSpotCellLikeTappedDelegate {
    func likeTapped(cell: UITableViewCell)
}

class F4FFoodSpotTableViewCell: UITableViewCell {

    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var buttonLike: UIButton!
    
    var delegate: FoodSpotCellLikeTappedDelegate?
    
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        buttonLike.layer.cornerRadius = 5
        buttonLike.layer.borderWidth = 1
        buttonLike.layer.borderColor = UIColor.init(red: 27/255, green: 66/255, blue: 82/255, alpha: 1.0).CGColor
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func drawLiked(){
        drawLiked(isLiked)
    }
    
    private func drawLiked(liked: Bool){
        let color = liked ? UIColor.init(red: 118/255, green: 193/255, blue: 144/255, alpha: 1.0) : UIColor.whiteColor()
        let text = liked ? "Your FoodSpot" : "Like FoodSpot"
        
        buttonLike.backgroundColor = color
        buttonLike.setTitle(text, forState: .Normal)
    }
    
    @IBAction func tappedLikeButton(sender: AnyObject) {
        drawLiked(!isLiked)
        
        if let del = delegate{
            del.likeTapped(self)
        }
    }
}
