import UIKit
import MessageUI

class Setting2ViewController: UITableViewController {
    
    @IBOutlet weak var basePayDetailLabel: UILabel!
    @IBOutlet weak var paySystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var unitOfWorkSettingPeriodSegmentedControl: UISegmentedControl!
    
    var selectedDay = Int()
    var selectedMonth = Int()
    
    var basePay = "" {
        didSet{
            basePayDetailLabel.text = basePay
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("init Setting2ViewController")
    }

    deinit {
        print("deinit Setting2ViewController")
    }
    
    override func viewDidLoad() {
        basePay = UserDefaults.standard.object(forKey: "basePay") as? String ?? "0"
        initialSetting()
    }
    
    func initialSetting() {
        //  일급:0 / 시급:1  초기화  (기본값: 0 - 일급)
        paySystemSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "paySystemIndex")
        
        //  한달:0 / 하루:1 (기본값: 0 - 한달)
        unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "unitOfWorkSettingPeriodIndex")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBasePayPopUpViewControllerSegue" {
        }
    }
    
    //MARK:  - Unwind Segue
    @IBAction func savebasePayToSetting2ViewController(_ segue: UIStoryboardSegue) {
        basePay = UserDefaults.standard.object(forKey: "basePay") as? String ?? "0"
    }
    
    @IBAction func paySystemSegmentedControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(paySystemSegmentedControl.selectedSegmentIndex, forKey: "paySystemIndex")
        // 기본단가(BasePay)가 새로 저장되면 메인화면의 DashBoard 기본단가표기 저장된 값으로 변경 시킴
        NotificationCenter.default.post(name: .didTogglePaySystem, object: nil)
    }
    
    @IBAction func unitOfWorkSettingPeriodSegmenteControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex, forKey: "unitOfWorkSettingPeriodIndex")
    }
    
}

//MARK:  - Mail Controller Delegate
extension Setting2ViewController: MFMailComposeViewControllerDelegate {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  2nd section 1st row (Sending E-Mail)
        if indexPath.section == 1 && indexPath.row == 0 {
            sendMailButtonAction()
        }
    }
    
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
