import UIKit
import MessageUI

class Setting2ViewController: UITableViewController {
    
    @IBOutlet weak var basePayDetailLabel: UILabel!
    @IBOutlet weak var moneyUnitDetailLabel: UILabel!
    @IBOutlet weak var taxDetailLabel: UILabel!
    @IBOutlet weak var backTaxPicker: UIPickerView!
    @IBOutlet weak var frontTaxPicker: UIPickerView!
    @IBOutlet weak var paySystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var unitOfWorkSettingPeriodSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var versionDetailLabel: UILabel!
    
    var basePay = String() {
        didSet{ basePayDetailLabel.text = formatter.string(from: NSNumber(value: Double(basePay) ?? 0))! }
    }
    var moneyUnit = Int() {
        didSet{ moneyUnitDetailLabel.text = moneyUnitsDataSource[moneyUnit] }
    }
    var taxRateFront = Int() {
        didSet { taxDetailLabel.text = "\(taxRateFront).\(taxRateBack) %" }
    }
    var taxRateBack = Int() {
        didSet { taxDetailLabel.text = "\(taxRateFront).\(taxRateBack) %" }
    }
    
    var taxPickerViewIsOn = false   // 첫 세팅화면에 TaxPicker 안보이게
    
    let numTaxPickerItem = 100      // 0~99
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("init Setting2ViewController")
    }

    deinit {
        print("deinit Setting2ViewController")
    }
    
    override func viewDidLoad() {

        initialSetting()
        
    }
    
    func initialSetting() {
        //  기본단가 표기
        basePay = UserDefaults.standard.object(forKey: SettingsKeys.basePay) as? String ?? "0"
        
        //  화폐단위 선택  만원:0 / 천원:1 / 원:2  (기본값: 0 - 만원)
        moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        
        //  세금 표시해 주기
        frontTaxPicker.dataSource = self
        frontTaxPicker.delegate = self
        backTaxPicker.dataSource = self
        backTaxPicker.delegate = self
        taxRateFront = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateFront)
        taxRateBack = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateBack)
        frontTaxPicker.selectRow(taxRateFront, inComponent: 0, animated: false)
        backTaxPicker.selectRow(taxRateBack, inComponent: 0, animated: false)
        
        //  일급:0 / 시급:1  (기본값: 0 - 일급)
        paySystemSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: SettingsKeys.paySystemIndex)
        
        //  한달:0 / 하루:1  (기본값: 0 - 한달)
        unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
        
        versionDetailLabel.text = "\(appVersion!)"
    }
    
    // Cell 높이 설정
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 3 && !taxPickerViewIsOn {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //  세금Cell 누르면 TaxPicker 내리고 올리기 (heightForRowAt 호출)
        if indexPath.section == 0 && indexPath.row == 2 {
            taxPickerViewIsOn = !taxPickerViewIsOn
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        //  2nd section 1st row (Sending E-Mail)
        if indexPath.section == 1 && indexPath.row == 0 {
            sendMailButtonAction()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBasePayPopUpVCSegue" {
            if let basePayVC = segue.destination as? BasePayPopUpViewController {
                basePayVC.strNumber = basePay
            }
        } else if segue.identifier == "toMoneyUnitVCSegue" {
            if let moneyUnitVC = segue.destination as? MoneyUnitViewController {
                moneyUnitVC.moneyUnit = moneyUnit
            }
        }
    }
    
    //MARK:  - Unwind Segue / Set UserDefaults
    @IBAction func saveBasePayToSetting2ViewController(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(basePay, forKey: SettingsKeys.basePay)
        
        // 기본단가(BasePay)가 새로 저장되면, 메인화면의 DashBoard Reload
        NotificationCenter.default.post(name: .didSaveBasePay, object: nil)
    }
    
    @IBAction func saveMoneyUnitToSetting2ViewController(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(moneyUnit, forKey: SettingsKeys.moneyUnit)
        
        // 화폐단위(MoneyUnit)가 새로 저장되면, 화폐단위 재설정
        NotificationCenter.default.post(name: .didChangeMoneyUnit, object: nil)
    }
    
    @IBAction func paySystemSegmentedControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(paySystemSegmentedControl.selectedSegmentIndex, forKey: SettingsKeys.paySystemIndex)
        NotificationCenter.default.post(name: .didTogglePaySystem, object: nil)
    }
    
    @IBAction func unitOfWorkSettingPeriodSegmenteControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex, forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension Setting2ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numTaxPickerItem
    }
}

extension Setting2ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == frontTaxPicker {
            taxRateFront = row
            UserDefaults.standard.set(taxRateFront, forKey: SettingsKeys.taxRateFront)
        } else {
            taxRateBack = row
            UserDefaults.standard.set(taxRateBack, forKey: SettingsKeys.taxRateBack)
        }
        //  TaxPicker가 변경되면 세금계산 다시
        NotificationCenter.default.post(name: .didSaveTaxRate, object: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return String(row)
    }
}

//MARK:  - Mail Controller Delegate
extension Setting2ViewController: MFMailComposeViewControllerDelegate {
    
    func sendMailButtonAction() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let messageBody = "\n\n\n\n\n\n\n\n\n\niOS version: \(iOSVersion)"
            + "\nApp version : \(appVersion!)\nDevice type: \(iPhoneDevice)"
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["hjpyooo@gmail.com"])
        mailComposerVC.setSubject("공수계산기 버그/불만 접수")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "hjpyooo@gmailcom", message: "현 기기에서 메일을 보낼수 없습니다\r\n위 메일주소로 연락주세요", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
