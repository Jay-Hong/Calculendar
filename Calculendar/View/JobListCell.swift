
import UIKit

class JobListCell: UITableViewCell {

    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var jobTypeLabel: UILabel!
    @IBOutlet weak var jobSiteLabel: UILabel!
    @IBOutlet weak var jobPayLabel: UILabel!
    @IBOutlet weak var jobEtc1Label: UILabel!
    @IBOutlet weak var jobEtc2Label: UILabel!
    @IBOutlet weak var jobEtc3Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
