import UIKit

class NewsListBigImageCell: UITableViewCell {

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsCompanyLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = newsImageView.bounds
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
        newsImageView.layer.mask = gradientLayer
        
//        newsImageView.layer.cornerRadius = 7
//        newsImageView.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
