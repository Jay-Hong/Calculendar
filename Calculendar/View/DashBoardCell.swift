
import UIKit

class DashBoardCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var imgBackViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var unitLabelBackViewWidth: NSLayoutConstraint!
    
    func setDashBoardCollectionViewCellConstraints() {
        
        switch UIScreen.main.bounds.size {
        //  스토리보드 기본사이즈
        //  imgBackViewWidthConstraint.constant = 76
        //  unitLabelBackViewWidth.constant = 50
        
        case iPhone12Pro, iPhonemini, iPhoneSE2, iPhone8Plus:
            imgBackViewWidthConstraint.constant = 76
            unitLabelBackViewWidth.constant = 50
        
        case iPhone12Max, iPhone11Max:
            imgBackViewWidthConstraint.constant = 76
            unitLabelBackViewWidth.constant = 50
        
        case iPhoneSE1:
            imgBackViewWidthConstraint.constant = 70
            unitLabelBackViewWidth.constant = 40
            
        default:
            imgBackViewWidthConstraint.constant = 80
            unitLabelBackViewWidth.constant = 80
        }
    }
    
}
