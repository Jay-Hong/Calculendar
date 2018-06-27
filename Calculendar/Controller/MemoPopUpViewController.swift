
import UIKit
import GoogleMobileAds

class MemoPopUpViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var memoBackView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveMemoButton: UIButton!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var delegate: PopupDelegate?
    
    var selectedMonth = Int()
    var selectedDay = Int()
    var memo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readyToMemo()
        
        setShadow()
        
        setAdMob()
        
    }
    
    func setAdMob() {
        bannerView.adSize = kGADAdSizeBanner
        bannerView.adUnitID = "ca-app-pub-5095960781666456/3159653643"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        //  Device Type 에 따라 화면 조정
        switch UIScreen.main.bounds.size {
        case iPhoneX, iPhone8, iPhone8Plus:
            bannerView.isHidden = true
        case iPhoneSE:  //  iPhoneSE만 메모화면 광고넣기
            bannerView.isHidden = false
        default:
            bannerView.isHidden = true
        }
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
        descriptionLabel.text = "\(selectedDay)일 메모"
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

