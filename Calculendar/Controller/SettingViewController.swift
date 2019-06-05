import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paySystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var unitOfWorkSettingPeriodSegmentedControl: UISegmentedControl!
    
    
    var delegate: PopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTopBar()
        initialSetting()
        
    }
    
    func initialSetting() {
        //  일급:0 / 시급:1  초기화  (기본값: 0 - 일급)
        paySystemSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "paySystemIndex")
        
        //  한달:0 / 하루:1 (기본값: 0 - 한달)
        unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "unitOfWorkSettingPeriodIndex")
    }
    
    @IBAction func paySystemSegmentedControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(paySystemSegmentedControl.selectedSegmentIndex, forKey: "paySystemIndex")
        delegate?.applySetting()
    }
    
    @IBAction func unitOfWorkSettingPeriodSegmenteControlAction(_ sender: Any) {
        UserDefaults.standard.set(unitOfWorkSettingPeriodSegmentedControl.selectedSegmentIndex, forKey: "unitOfWorkSettingPeriodIndex")
    }
    
    func setTopBar() {
        //  Device Type 에 따라 Top Bar 조정
        switch UIScreen.main.bounds.size {
        case iPhoneSE:
            topBarHeightConstraint.constant = 60
            
        case iPhone8Plus, iPhone8:
            topBarHeightConstraint.constant = 60
            
        case iPhoneXS, iPhoneXSMAX, iPhoneXR:
            topBarHeightConstraint.constant = 80
            
        default: break
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // status bar text color 흰색으로 바꿔주기
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
