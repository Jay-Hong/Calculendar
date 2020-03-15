import UIKit

class TaxBeforeAfterViewController: UIViewController {
    @IBOutlet weak var titleDescriptionLabel: UILabel!
    @IBOutlet weak var beforeTaxMoneyUnitLabel: UILabel!
    @IBOutlet weak var taxMoneyUnitLabel: UILabel!
    @IBOutlet weak var afterTaxMoneyUnitLabel: UILabel!
    @IBOutlet weak var salaryBeforeTaxLabel: UILabel!
    @IBOutlet weak var salaryAfterTaxLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var taxRateLabel: UILabel!
    
    var moneyUnit = Int() {
        didSet{
            beforeTaxMoneyUnitLabel.text = moneyUnitsDataSource[moneyUnit]
            taxMoneyUnitLabel.text = moneyUnitsDataSource[moneyUnit]
            afterTaxMoneyUnitLabel.text = moneyUnitsDataSource[moneyUnit]
        }
    }

    //  전달받는 인자 들
    var titleDescription = String()
    var salaryBeforeTax = String()
    var salaryAfterTax = String()
    var tax = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        
        let taxRateFront = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateFront)
        let taxRateBack = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateBack)
        taxRateLabel.text = "\(taxRateFront)." + makeTwoDigitString(taxRateBack) + " %"
        
        titleDescriptionLabel.text = titleDescription + "  정산"
        salaryBeforeTaxLabel.text = salaryBeforeTax
        salaryAfterTaxLabel.text = salaryAfterTax
        taxLabel.text = tax
        
    }
    
    @objc func onDidChangeMoneyUnitOnBasePayVC(_ notification: Notification) {
        moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
