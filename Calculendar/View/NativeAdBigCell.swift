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
            gradientLayer.locations = [0, 0, 0.9, 1]
        case iPhone14Plus:
            gradientLayer.locations = [0, 0, 0.89, 0.99]
        case iPhone11, iPhone8Plus:
            gradientLayer.locations = [0, 0, 0.86, 0.96]
        case iPhone15Pro:
            gradientLayer.locations = [0, 0, 0.82, 0.91]
        case iPhone13Pro:
            gradientLayer.locations = [0, 0, 0.81, 0.9]
        case iPhoneSE3, iPhone14:
            gradientLayer.locations = [0, 0, 0.78, 0.87]
        case iPhoneSE1:
            gradientLayer.locations = [0, 0, 0.7, 0.78]
        default:
            gradientLayer.locations = [0, 0, 0.89, 0.99]
        }
//        gradientLayer.locations = [0, 0, 0.9, 1]
        gadMediaView.layer.mask = gradientLayer
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
