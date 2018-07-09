
import UIKit
import GoogleMobileAds

class MemoPopUpViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var memoBackView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveMemoButton: UIButton!

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
        case iPhoneX:
            fromTopToMemoBackViewHeightConstraint.constant = 58
            fromBottomToMemoBackViewHeightConstraint.constant = 360
            fromRightToMemoBackViewWidthConstraint.constant = 10
            fromLeftToMemoBackViewWidthConstraint.constant = 10
        case iPhone8:
            fromTopToMemoBackViewHeightConstraint.constant = 57
            fromBottomToMemoBackViewHeightConstraint.constant = 320
            fromRightToMemoBackViewWidthConstraint.constant = 10
            fromLeftToMemoBackViewWidthConstraint.constant = 10
        case iPhone8Plus:
            fromTopToMemoBackViewHeightConstraint.constant = 54
            fromBottomToMemoBackViewHeightConstraint.constant = 330
            fromRightToMemoBackViewWidthConstraint.constant = 10
            fromLeftToMemoBackViewWidthConstraint.constant = 10
        case iPhoneSE:
            fromTopToMemoBackViewHeightConstraint.constant = 44
            fromBottomToMemoBackViewHeightConstraint.constant = 303
            fromRightToMemoBackViewWidthConstraint.constant = 10
            fromLeftToMemoBackViewWidthConstraint.constant = 10
        default:
            break
        }
    }
    
    func setAdMob() {
        bannerView.adSize = kGADAdSizeBanner
        bannerView.adUnitID = "ca-app-pub-5095960781666456/3159653643"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveMemoButtonAction(_ sender: Any) {
        delegate?.saveMemo(memo: memoTextView.text)
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
    }
}

