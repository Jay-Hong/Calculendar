
import UIKit
import GoogleMobileAds

class UnitOfWorkPopUpViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var topDescriptionView: UIView!
    @IBOutlet weak var displayBackView: UIView!
    @IBOutlet weak var displayNumberLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var delegate: PopupDelegate?
    
    var selectedMonth = Int()
    var selectedDay = Int()
    var strNumber = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refineStrNumber()
        
        setShadow()
        
        setAdMob()
        
        // '0'저장 = 휴무 / 모두지우면 공수삭제 View
        topDescriptionView.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if strNumber != "0" {
            UIView.animate(withDuration: 2.5, delay: 0.2, animations: {self.topDescriptionView.alpha = 0.8;}, completion: {
                (value: Bool) in
                UIView.animate(withDuration: 2.8, delay: 4, animations: {self.topDescriptionView.alpha = 0;})
            })
        }
    }
    
    func setAdMob() {
//        bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: bannerView.frame.width, height: bannerView.frame.height))
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerView.frame.width)
        bannerView.adUnitID = "ca-app-pub-5095960781666456/1535171668"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func refineStrNumber() {
        if strNumber.contains(".") {
            while (strNumber.hasSuffix("0")) {
                strNumber.removeLast() }
            if strNumber.hasSuffix(".") {
                strNumber.removeLast() }
        }
        strNumber = strNumber == "" ? "0" : strNumber
        numberDisplay()
        descriptionLabel.text = "\(selectedMonth)월 \(selectedDay)일"
    }
    
    func numberDisplay() {
        displayNumberLabel.text = strNumber
    }
    
    func accumulator(digit: String) {
        strNumber += (strNumber.count < 5) ? digit : ""
    }
    
    @IBAction func numberButtonAction(_ sender: UIButton) {
        if strNumber.hasPrefix("0") {
            if !strNumber.hasPrefix("0.") {
                strNumber.removeFirst()
            }
        }
        //  . 없이는 2자리까지만 입력 가능
        if strNumber.contains(".") || (strNumber.count < 2) {
            accumulator(digit: sender.currentTitle!)
        }
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
    
    
    @IBAction func saveUnitOfWorkButtonAction(_ sender: UIButton) {
        delegate?.saveUnitOfWork(unitOfWork: displayNumberLabel.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setShadow() {
        
        topDescriptionView.layer.cornerRadius = 10
        topDescriptionView.layer.masksToBounds = true
        
        displayBackView.layer.cornerRadius = 10
        displayBackView.layer.masksToBounds = true
        
        saveButton.layer.cornerRadius = 5
        //        saveButton.layer.masksToBounds = true
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
        
//        dotButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        dotButton.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        dotButton.layer.shadowOpacity = shadowOpacity
//        dotButton.layer.shadowRadius = shadowRadius
//
//        backSpaceButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: shadowAlpha).cgColor
//        backSpaceButton.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
//        backSpaceButton.layer.shadowOpacity = shadowOpacity
//        backSpaceButton.layer.shadowRadius = shadowRadius
        
        //        n1Button.layer.masksToBounds = false
        //        n2Button.layer.masksToBounds = true
        //        n3Button.layer.masksToBounds = true
        //        n4Button.layer.masksToBounds = true
        //        n5Button.layer.masksToBounds = true
        //        n6Button.layer.masksToBounds = true
        //        n7Button.layer.masksToBounds = true
        //        n8Button.layer.masksToBounds = true
        //        n9Button.layer.masksToBounds = true
        //        n0Button.layer.masksToBounds = true
        
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
