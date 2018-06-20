
import UIKit

class YearMonthPopUpViewController: UIViewController {

    @IBOutlet weak var yearLabel: UILabel!
    var delegate: PopupDelegate?
    
    var selectedYear = Int()
    var selectedMonth = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedYear = toYear
        selectedMonth = toMonth
        yearLabel.text = "\(selectedYear)"
        
    }
    
    @IBAction func monthButtonAction(_ sender: UIButton) {
        selectedMonth = Int(sender.currentTitle!)!
        delegate?.moveYearMonth(year: selectedYear, month: selectedMonth)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toDayButtonAction(_ sender: UIButton) {
        selectedYear = toYear
        selectedMonth = toMonth
        delegate?.moveYearMonth(year: selectedYear, month: selectedMonth)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextYearButtonAction(_ sender: UIButton) {
        if selectedYear <= toYear + 100{
            selectedYear += 1
            yearLabel.text = "\(selectedYear)"
        }
    }
    
    @IBAction func preYearButtonAction(_ sender: UIButton) {
        if selectedYear >= 1900 {
            selectedYear -= 1
            yearLabel.text = "\(selectedYear)"
        }
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
