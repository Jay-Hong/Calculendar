import UIKit
import GoogleMobileAds

class BasePayPopUpViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var displayBackView: UIView!
    @IBOutlet weak var displayNumberLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moneyUnitLabel: UILabel!
    
    @IBOutlet weak var n1Button: UIButton!
    @IBOutlet weak var n2Button: UIButton!
    @IBOutlet weak var n3Button: UIButton!
    @IBOutlet weak var n4Button: UIButton!
    @IBOutlet weak var n5Button: UIButton!
    @IBOutlet weak var n6Button: UIButton!
    @IBOutlet weak var n7Button: UIButton!
    @IBOutlet weak var n8Button: UIButton!
    @IBOutlet weak var n9Button: UIButton!
    @IBOutlet weak var n0Button: UIButton!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var backSpaceButton: UIButton!
    
    var strNumber = String()
    var moneyUnit = Int() {
        didSet{
            moneyUnitLabel.text = moneyUnitsDataSource[moneyUnit]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAdMob()
        setBasePayScene()
        setShadow()
        
        moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        
        //  화폐단위(MoneyUnit)가 변경 되었을 경우
        NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeMoneyUnitOnBasePayVC), name: .didChangeMoneyUnit, object: nil)
    }
    
    func setAdMob() {
        if UserDefaults.standard.bool(forKey: "AdRemoval") {
            print("Hide Ad")
            bannerView.isHidden = true
        } else {
            bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
            bannerView.adUnitID = "ca-app-pub-5095960781666456/8022994244"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.layer.cornerRadius = 3
            bannerView.layer.masksToBounds = true
            bannerView.delegate = self
        }
    }
    
    func setBasePayScene() {
//        descriptionLabel.text = "기본 단가 설정"
        trimStrNumber()
        numberDisplay()
    }
    
    @objc func onDidChangeMoneyUnitOnBasePayVC(_ notification: Notification) {
        moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
    }
    
    func trimStrNumber() {
        if strNumber.contains(".") {
            while (strNumber.hasSuffix("0")) {
                strNumber.removeLast() }
            if strNumber.hasSuffix(".") {
                strNumber.removeLast() }
        }
        strNumber = strNumber == "" ? "0" : strNumber
    }
    
    func numberDisplay() {
        displayNumberLabel.text = strNumber
    }
    
    // 저장 버튼을 누르면 Unwind Segue 로 SettingVC로 이동 (기본단가 세팅화면에 뿌려주고 저장)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromBasePayVC" {
            if let setting2VC = segue.destination as? Setting2ViewController {
                trimStrNumber()
                setting2VC.basePay = strNumber
            }
        }
    }
    
    func accumulator(digit: String) {
        strNumber += (strNumber.count < 6) ? digit : ""
    }
    
    
    @IBAction func numberButtonAction(_ sender: UIButton) {
        if strNumber.hasPrefix("0") {
            if !strNumber.hasPrefix("0.") {
                strNumber.removeFirst()
            }
        }
        accumulator(digit: sender.currentTitle!)
        numberDisplay()
    }
    
    @IBAction func dotButtonAction(_ sender: UIButton) {
        if strNumber.isEmpty{
            strNumber += "0."
        }
        if !strNumber.contains(".") {
            accumulator(digit: ".")
        }
        numberDisplay()
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        if !strNumber.isEmpty {
            strNumber.removeLast()
        }
        numberDisplay()
    }
    
    //  사용하지 않는 백뷰 버튼
    @IBAction func backgroundButtonAction(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setShadow() {
        
        displayBackView.layer.cornerRadius = 10
        displayBackView.layer.masksToBounds = true
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowOpacity = 1.0
        saveButton.layer.shadowRadius = 1.0
        
        
        let shadowAlpha: CGFloat = 0.7
        let shadowHeight = 2.5
        let shadowOpacity: Float = 1.0
        let shadowRadius: CGFloat = 1.5
        
        n1Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n1Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n1Button.layer.shadowOpacity = shadowOpacity
        n1Button.layer.shadowRadius = shadowRadius
        
        n2Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n2Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n2Button.layer.shadowOpacity = shadowOpacity
        n2Button.layer.shadowRadius = shadowRadius
        
        n3Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n3Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n3Button.layer.shadowOpacity = shadowOpacity
        n3Button.layer.shadowRadius = shadowRadius
        
        n4Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n4Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n4Button.layer.shadowOpacity = shadowOpacity
        n4Button.layer.shadowRadius = shadowRadius
        
        n5Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n5Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n5Button.layer.shadowOpacity = shadowOpacity
        n5Button.layer.shadowRadius = shadowRadius
        
        n6Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n6Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n6Button.layer.shadowOpacity = shadowOpacity
        n6Button.layer.shadowRadius = shadowRadius
        
        n7Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n7Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n7Button.layer.shadowOpacity = shadowOpacity
        n7Button.layer.shadowRadius = shadowRadius
        
        n8Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n8Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n8Button.layer.shadowOpacity = shadowOpacity
        n8Button.layer.shadowRadius = shadowRadius
        
        n9Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n9Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n9Button.layer.shadowOpacity = shadowOpacity
        n9Button.layer.shadowRadius = shadowRadius
        
        n0Button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
        n0Button.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        n0Button.layer.shadowOpacity = shadowOpacity
        n0Button.layer.shadowRadius = shadowRadius
        
        var numberButtonCornerRadius = CGFloat()
        numberButtonCornerRadius = 5
        
        n1Button.layer.cornerRadius = numberButtonCornerRadius
        n2Button.layer.cornerRadius = numberButtonCornerRadius
        n3Button.layer.cornerRadius = numberButtonCornerRadius
        n4Button.layer.cornerRadius = numberButtonCornerRadius
        n5Button.layer.cornerRadius = numberButtonCornerRadius
        n6Button.layer.cornerRadius = numberButtonCornerRadius
        n7Button.layer.cornerRadius = numberButtonCornerRadius
        n8Button.layer.cornerRadius = numberButtonCornerRadius
        n9Button.layer.cornerRadius = numberButtonCornerRadius
        n0Button.layer.cornerRadius = numberButtonCornerRadius
        dotButton.layer.cornerRadius = numberButtonCornerRadius
        backSpaceButton.layer.cornerRadius = numberButtonCornerRadius
    }
    
}
