import UIKit
import GoogleMobileAds

class NativeAdBigCell: UITableViewCell {

    
    @IBOutlet weak var gadMediaView: GADMediaView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gadMediaView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        
        switch UIScreen.main.bounds.size {
        case iPhone15ProMax:
            gradientLayer.locations = [0, 0, 0.38, 0.42]    //  O
        case iPhone14Plus:
            gradientLayer.locations = [0, 0, 0.38, 0.42]    //
        case iPhone11, iPhone8Plus:
            gradientLayer.locations = [0, 0, 0.36, 0.4]     //
        case iPhone15Pro:
            gradientLayer.locations = [0, 0, 0.34, 0.38]    //  O
        case iPhone13Pro:
            gradientLayer.locations = [0, 0, 0.34, 0.38]    //
        case iPhoneSE3, iPhone14:
            gradientLayer.locations = [0, 0, 0.32, 0.36]    //  O
        case iPhoneSE1:
            gradientLayer.locations = [0, 0, 0.28, 0.32]    //
            
        case iPadPro13iM4:
            gradientLayer.locations = [0, 0, 0.95, 0.99]    //  O
        case iPadAir13iM2:
            gradientLayer.locations = [0, 0, 0.94, 0.98]    //  O
        case iPadPro11iM4, iPadPro11i4th, iPadAir3rd:
            gradientLayer.locations = [0, 0, 0.76, 0.8]     //  O
        case iPadAir11iM2:
            gradientLayer.locations = [0, 0, 0.75, 0.79]    //  O
        case iPad9th:
            gradientLayer.locations = [0, 0, 0.74, 0.78]
        case iPadMini5th:
            gradientLayer.locations = [0, 0, 0.7, 0.74]     //  O
        case iPadMini6th:
            gradientLayer.locations = [0, 0, 0.66, 0.7]     //  O
        default:
            gradientLayer.locations = [0, 0, 0.96, 1]
        }
        
//        gradientLayer.locations = [0, 0, 0.9, 1]
        gadMediaView.layer.mask = gradientLayer
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
