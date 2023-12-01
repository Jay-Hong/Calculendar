import UIKit
import MessageUI
import GoogleMobileAds

class JobDetailViewController: UIViewController, GADBannerViewDelegate, UIScrollViewDelegate {

    var detailData = JobInfo()
    
    @IBOutlet weak var jobScrollView: UIScrollView!
    @IBOutlet weak var jobInfoView: UIView!
    
    @IBOutlet weak var jobSiteLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var jobTypeLabel: UILabel!
    @IBOutlet weak var jobPayLabel: UILabel!
    @IBOutlet weak var jobNumPeopleLabel: UILabel!
    @IBOutlet weak var jobPhoneLabel: UILabel!
    @IBOutlet weak var jobDetailLabel: UILabel!
    
    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var imageBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var jobImageView: UIImageView!
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var adViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var applyView: UIView!
    @IBOutlet weak var cancelView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    private var lastContentOffset: CGFloat = 0
    private var initialTopViewHeight: CGFloat = 0
    private var initialBottomViewHeight: CGFloat = 0
    
    var phoneNumber: String = ""    // 전화번호 숫자만
    
    override func loadView() {
        super.loadView()
        jobScrollView.delegate = self
        initialTopViewHeight = topViewHeightConstraint.constant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setJobDetailViewPage()

        getImageFromURL()
        setAdMob()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\n⬇️ scrollViewDidScroll")
        
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= (scrollView.contentSize.height - jobScrollView.frame.height) {
            print("컨텐츠 내부")
            
            if (self.lastContentOffset > scrollView.contentOffset.y) {  // 스크롤 올릴때
                print("move up")
                view.layoutIfNeeded() //layout을 모두 업데이트 시켜놓는다.
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.topViewHeightConstraint.constant =  self.initialTopViewHeight
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
//                if topViewHeightConstraint.constant <= initialTopViewHeight {   //  topView
//                    topViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y) / 2
//                    if topViewHeightConstraint.constant >= initialTopViewHeight {
//                        topViewHeightConstraint.constant = initialTopViewHeight
//                    } else if topViewHeightConstraint.constant > initialTopViewHeight / 2 {
//                        cancelButton.isHidden = false
//                    }
//                }
            }
            
            else if (self.lastContentOffset < scrollView.contentOffset.y) { // 스크롤 내릴때
                print("move down")
                view.layoutIfNeeded() //layout을 모두 업데이트 시켜놓는다.
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.topViewHeightConstraint.constant =  0
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
//                if topViewHeightConstraint.constant > 0 {   //  topView
//                    topViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y) / 2
//                    if topViewHeightConstraint.constant <= 0 {
//                        topViewHeightConstraint.constant = 0
//                        cancelButton.isHidden = true  // backButton시 필요
//                    } else if topViewHeightConstraint.constant <= initialTopViewHeight / 2  {
//                        cancelButton.isHidden = true
//                    }
//                }
            }
            
        } else {    // 컨텐츠 외부 스크롤 동작 안함 (처음과 끝 애니매이션시 동작 안함)
            print("컨텐츠 외부")
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                print("move up")
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
                print("move down")
            }
        }
        
        print(topViewHeightConstraint.constant)
        print(self.lastContentOffset - scrollView.contentOffset.y)
        print("scrollView.contentOffset.y : \(scrollView.contentOffset.y)")
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func getImageFromURL() {
        imageSize = CGSize(width: 0,height: 0)
        
        if detailData.imageURL == "" {
            noImage()
        } else {
            guard let url = URL(string: detailData.imageURL) else {noImage(); return}
            jobImageView.load(url: url)
            print(url)
            // 사진가져오기 시도
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(120)) {
                self.setImageToView()
                
                if imageSize.width == 0 {   // 사진을 못가져왔으면 한번더 시도
                    self.jobImageView.load(url: url)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(180)) {
                        self.setImageToView()
                        
                        if imageSize.width == 0 {   // 사진을 못가져왔으면 또 시도
                            self.jobImageView.load(url: url)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                self.setImageToView()
                                
                                if imageSize.width == 0 {   // 사진을 못가져왔으면 한번더 시도
                                    self.jobImageView.load(url: url)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        self.setImageToView()
                                        
                                        if imageSize.width == 0 {   // 사진을 못가져왔으면 한번더 시도
                                            self.jobImageView.load(url: url)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self.setImageToView()
                                                
                                                if imageSize.width == 0 {   // 사진을 못가져왔으면 한번더 시도
                                                    self.jobImageView.load(url: url)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                                                        self.setImageToView()
                                                        
                                                        if imageSize.width == 0 {   // 사진을 못가져왔으면 한번더 시도
                                                            self.jobImageView.load(url: url)
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                                                self.setImageToView()
                                                                
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                                                    self.setImageToView()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setImageToView() {
        if imageSize.width == 0 {
            self.noImage()
            return
        } else {
            let imageRatio = imageSize.height / imageSize.width

            imageBackViewHeightConstraint.constant = imageBackView.frame.width * imageRatio
            imageBackViewTopConstraint.constant = 12
            jobImageView.isHidden = false
            imageBackView.isHidden = false
        }
    }
    
    func noImage() {
        imageBackViewTopConstraint.constant = 0
        imageBackViewHeightConstraint.constant = 0
        jobImageView.isHidden = true
        imageBackView.isHidden = true
        
        print("\n\n")
        print(" - - - - - - - - - - - - - - - - No Image !  - - - - - - - - - - - - - - - - ")
        print("\n\n")
        print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
        print("\n\n")
    }

    func setAdMob() {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) || !remoteConfig.configValue(forKey: RemoteConfigKeys.jobDetailAD).boolValue {
            bannerView.isHidden = true
            adView.isHidden = true
            adViewHeightConstraint.constant = 0
            adViewTopConstraint.constant = 0
        } else {
            bannerView.adSize = GADAdSizeMediumRectangle
            bannerView.adUnitID = "ca-app-pub-5095960781666456/7308179533"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    func setJobDetailViewPage() {
        jobSiteLabel.text = detailData.site
        jobTitleLabel.text = detailData.title
        jobTypeLabel.text = detailData.type
        jobPayLabel.text = detailData.pay
        jobNumPeopleLabel.text = detailData.numpeople
        jobPhoneLabel.text = detailData.phone
        jobDetailLabel.text = detailData.detail
        
        // 문자열에서 숫자만 뽑아주기 (지원하기에 사용 위함
        phoneNumber = detailData.phone.filter {
            $0.isNumber
        }
        
        jobTitleLabel.setLineSpacing(spacing: 4.0)
        jobDetailLabel.setLineSpacing(spacing: 12.0)
        
        jobInfoView.layer.cornerRadius = 20
        jobInfoView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.34).cgColor
        jobInfoView.layer.shadowOffset = CGSize(width: 2.3, height: 3.0)
        jobInfoView.layer.shadowOpacity = 1.0
        jobInfoView.layer.shadowRadius = 1.3
        
        imageBackView.layer.cornerRadius = 20
        imageBackView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.34).cgColor
        imageBackView.layer.shadowOffset = CGSize(width: 2.3, height: 3.0)
        imageBackView.layer.shadowOpacity = 1.0
        imageBackView.layer.shadowRadius = 1.3
        
        jobImageView.layer.cornerRadius = 16
        
        adView.layer.cornerRadius = 20
        adView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.23).cgColor
        adView.layer.shadowOffset = CGSize(width: 1.8, height: 2.0)
        adView.layer.shadowOpacity = 1.0
        adView.layer.shadowRadius = 1.3
        
        bannerView.layer.cornerRadius = 12
        
        applyView.layer.cornerRadius = 12
        applyView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        applyView.layer.shadowOffset = CGSize(width: 1.0, height: 2.5)
        applyView.layer.shadowOpacity = 1.0
        applyView.layer.shadowRadius = 1.5
        
        cancelView.layer.cornerRadius = 12
        cancelView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        cancelView.layer.shadowOffset = CGSize(width: 1.0, height: 2.5)
        cancelView.layer.shadowOpacity = 1.0
        cancelView.layer.shadowRadius = 1.5
        
        
        //  공지사항 용  =>  연락처에 숫자가 포함되지 않으면 (전화번호 없으면) || @포함되면 (이메일주소면) ->  지원하기 버튼 안나오게
        applyView.isHidden =  (phoneNumber.isEmpty || phoneNumber.contains("@")) ? true :  false
        
    }
    
    //  
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
//        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func applyButtonAction(_ sender: Any) {
        // 문자열에서 숫자만 뽑아주기 (지원하기에 사용 위함)
        phoneNumber = detailData.phone.filter {
            $0.isNumber
        }
        let alert = UIAlertController(title: "\n✔️ 업무시간 중에는 문자지원을 먼저 이용해주세요", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in }
        let messageAction = UIAlertAction(title: "문자로 지원하기", style: .default) { (action) in
            self.sendTextMessage()
        }
        let callAction = UIAlertAction(title: "전화로 지원하기", style: .default) { (action) in
            self.makeACall()
        }
        alert.addAction(messageAction)
        alert.addAction(callAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func sendTextMessage() {
        guard MFMessageComposeViewController.canSendText() else {
            print("SMS services are not available")
            return
        }
            
        let composeViewController = MFMessageComposeViewController()
        composeViewController.messageComposeDelegate = self
        composeViewController.recipients = [phoneNumber]
        composeViewController.body = remoteConfig.configValue(forKey: RemoteConfigKeys.applyByMessage).stringValue ?? ""
        present(composeViewController, animated: true, completion: nil)
    }
    
    func makeACall() {
        let numberUrl = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(numberUrl) {
            UIApplication.shared.open(numberUrl)
        }
    }
}

extension JobDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("failed")
            dismiss(animated: true, completion: nil)
        @unknown default:
            print("unkown Error")
            dismiss(animated: true, completion: nil)
        }
    }
}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image

                        print("\n\n")
                        print(" - - - - - - - - - - - - - - -  Image   - - - - - - - - - - - - - - - - - ")
                        print("\n")
                        print("                     The image is loaded ")
                        print("\n")
                        print("                        \(image.size) ")
                        print("\n")
                        print(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ")
                        print("\n\n")
                        
                        imageSize = image.size
                    }
                }
            }
        }
    }
}

// Label 줄간격 조정
extension UILabel {
    func setLineSpacing(spacing: CGFloat) {
        guard let text = text else { return }

        let attributeString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        attributeString.addAttribute(.paragraphStyle,
                                     value: style,
                                     range: NSRange(location: 0, length: attributeString.length))
        attributedText = attributeString
    }
}
