
import UIKit

class NewsListCell: UITableViewCell {

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsCompanyLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsImageView.layer.cornerRadius = 7
        newsImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
