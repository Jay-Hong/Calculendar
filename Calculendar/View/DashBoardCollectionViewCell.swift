
import UIKit

class DashBoardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var imgBackViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var unitLabelBackView: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setDashBoardCollectionViewCellConstraints() {

        
        switch UIScreen.main.bounds.size {
            
        case iPhoneXS, iPhone8:
            backViewWidthConstraint.constant = 335
            backViewHeightConstraint.constant = 76
            imgBackViewWidthConstraint.constant = 80
            unitLabelBackView.constant = 50
            
        case iPhone8Plus, iPhoneXSMAX:  //
            backViewWidthConstraint.constant = 374
            backViewHeightConstraint.constant = 76
            imgBackViewWidthConstraint.constant = 80
            unitLabelBackView.constant = 50
            
        case iPhoneXR:   //
            backViewWidthConstraint.constant = 373
            backViewHeightConstraint.constant = 76
            imgBackViewWidthConstraint.constant = 80
            unitLabelBackView.constant = 50
            
        case iPhoneSE:  //
            backViewWidthConstraint.constant = 280
            backViewHeightConstraint.constant = 76
            imgBackViewWidthConstraint.constant = 70
            unitLabelBackView.constant = 40
            
        default:
            backViewWidthConstraint.constant = UIScreen.main.bounds.size.width - 40
            backViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 4
            imgBackViewWidthConstraint.constant = 80
            unitLabelBackView.constant = 50
        }
    }

}
