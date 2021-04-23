import UIKit
import GoogleMobileAds

class MemoPopUpViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var memoBackView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveMemoButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var fromTopToMemoBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromBottomToMemoBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromRightToMemoBackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromLeftToMemoBackViewWidthConstraint: NSLayoutConstraint!
    
    var delegate: PopupDelegate?
    
    var selectedMonth = Int()
    var selectedDay = Int()
    var memo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readyToMemo()
        setMemoBackViewConstraint()
        setShadow()
        setAdMob()
        
    }
    
    func setMemoBackViewConstraint() {
        //  Device Type 에 따라 메모화면 조정
        switch UIScreen.main.bounds.size {
        //  스토리보드 기본사이즈
        //  fromBottomToMemoBackViewHeightConstraint.constant = 360
        //  fromTopToMemoBackViewHeightConstraint.constant = 4
        //  fromRightToMemoBackViewWidthConstraint.constant = 4
        //  fromLeftToMemoBackViewWidthConstraint.constant = 4
        
        case iPhone12Max:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 315 : 370
            //  fromBottomToMemoBackViewHeightConstraint.constant = 370
        
        case iPhone12Pro:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 305 : 360
            //  fromBottomToMemoBackViewHeightConstraint.constant = 360
        
        case iPhone11Max:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 315 : 370
            //  fromBottomToMemoBackViewHeightConstraint.constant = 370
        
        case iPhonemini:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 305 : 360
            //  fromBottomToMemoBackViewHeightConstraint.constant = 360
        
        case iPhoneSE2:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 265 : 320
            //  fromBottomToMemoBackViewHeightConstraint.constant = 320
        
        case iPhone8Plus:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 275 : 330
            //  fromBottomToMemoBackViewHeightConstraint.constant = 330
        
        case iPhoneSE1:
            fromTopToMemoBackViewHeightConstraint.constant = 0
            fromRightToMemoBackViewWidthConstraint.constant = 4
            fromLeftToMemoBackViewWidthConstraint.constant = 4
            fromBottomToMemoBackViewHeightConstraint.constant = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) ? 248 : 303
            //  fromBottomToMemoBackViewHeightConstraint.constant = 303
        default:
            break
        }
    }
    
    func setAdMob() {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) {
            bannerView.isHidden = true
        } else {
            bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerView.frame.width)
            bannerView.adUnitID = "ca-app-pub-5095960781666456/3159653643"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveMemoButtonAction(_ sender: Any) {
        delegate?.saveMemo(memo: memoTextView.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func readyToMemo() {
        memoTextView.text = memo
        memoTextView.becomeFirstResponder()
        descriptionLabel.text = "\(selectedMonth)월 \(selectedDay)일"
    }
    
    func setShadow() {
        memoBackView.layer.cornerRadius = 10
        memoBackView.layer.masksToBounds = true
        
        memoTextView.layer.cornerRadius = 2
        memoTextView.layer.masksToBounds = true
        
        saveMemoButton.layer.cornerRadius = 5
        saveMemoButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        saveMemoButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveMemoButton.layer.shadowOpacity = 1.0
        saveMemoButton.layer.shadowRadius = 1.0
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButton.layer.shadowOpacity = 1.0
        cancelButton.layer.shadowRadius = 1.0
    }
}

