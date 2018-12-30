
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
//        setShadow()
        
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
    
//    func setShadow() {
//        let shadowAlpha: CGFloat = 0.7
//        let shadowHeight = 2.5
//        let shadowOpacity: Float = 1.0
//        let shadowRadius: CGFloat = 1.5
//
//        monthButton1.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton1.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton1.layer.shadowOpacity = shadowOpacity
//        monthButton1.layer.shadowRadius = shadowRadius
//
//        monthButton2.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton2.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton2.layer.shadowOpacity = shadowOpacity
//        monthButton2.layer.shadowRadius = shadowRadius
//
//        monthButton3.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton3.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton3.layer.shadowOpacity = shadowOpacity
//        monthButton3.layer.shadowRadius = shadowRadius
//
//        monthButton4.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton4.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton4.layer.shadowOpacity = shadowOpacity
//        monthButton4.layer.shadowRadius = shadowRadius
//
//        monthButton5.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton5.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton5.layer.shadowOpacity = shadowOpacity
//        monthButton5.layer.shadowRadius = shadowRadius
//
//        monthButton6.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton6.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton6.layer.shadowOpacity = shadowOpacity
//        monthButton6.layer.shadowRadius = shadowRadius
//
//        monthButton7.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton7.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton7.layer.shadowOpacity = shadowOpacity
//        monthButton7.layer.shadowRadius = shadowRadius
//
//        monthButton8.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton8.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton8.layer.shadowOpacity = shadowOpacity
//        monthButton8.layer.shadowRadius = shadowRadius
//
//        monthButton9.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton9.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton9.layer.shadowOpacity = shadowOpacity
//        monthButton9.layer.shadowRadius = shadowRadius
//
//        monthButton10.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton10.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton10.layer.shadowOpacity = shadowOpacity
//        monthButton10.layer.shadowRadius = shadowRadius
//
//        monthButton11.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton11.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton11.layer.shadowOpacity = shadowOpacity
//        monthButton11.layer.shadowRadius = shadowRadius
//
//        monthButton12.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        monthButton12.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        monthButton12.layer.shadowOpacity = shadowOpacity
//        monthButton12.layer.shadowRadius = shadowRadius
//
//
//
//
//        var numberButtonCornerRadius = CGFloat()
//        numberButtonCornerRadius = 5
//
//        monthButton1.layer.cornerRadius = numberButtonCornerRadius
//        monthButton2.layer.cornerRadius = numberButtonCornerRadius
//        monthButton3.layer.cornerRadius = numberButtonCornerRadius
//        monthButton4.layer.cornerRadius = numberButtonCornerRadius
//        monthButton5.layer.cornerRadius = numberButtonCornerRadius
//        monthButton6.layer.cornerRadius = numberButtonCornerRadius
//        monthButton7.layer.cornerRadius = numberButtonCornerRadius
//        monthButton8.layer.cornerRadius = numberButtonCornerRadius
//        monthButton9.layer.cornerRadius = numberButtonCornerRadius
//        monthButton10.layer.cornerRadius = numberButtonCornerRadius
//        monthButton11.layer.cornerRadius = numberButtonCornerRadius
//        monthButton12.layer.cornerRadius = numberButtonCornerRadius
//    }
}
