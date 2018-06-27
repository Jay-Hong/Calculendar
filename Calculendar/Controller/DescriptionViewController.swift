import UIKit
import WebKit

class DescriptionViewController: UIViewController {

    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let initialURL = "https://postfiles.pstatic.net/MjAxODA2MjRfMTg3/MDAxNTI5NzgxOTExNzcy.7qb84eJBrHYZ-pokR0fm75OGEBxJKbpn0QXXZ2ltKHEg.O43pQUUsqJCOgHjQfGxGYJuWEAdsnFxzRc7SM_4lXKYg.PNG.hjpyooo/Calculendar.png?type=w773"
        let myURL = URL(string: initialURL)
        let myRequest = URLRequest(url: myURL!)
        descriptionWebView.load(myRequest)
        
        //  Device Type 에 따라 화면 조정
        switch UIScreen.main.bounds.size {
        case iPhoneSE:  //  메인화면 광고 없애기
            topBarHeightConstraint.constant = 60

        case iPhone8Plus, iPhone8:
            topBarHeightConstraint.constant = 60

        case iPhoneX:   //  Top Bar 80으로 늘려주기
            topBarHeightConstraint.constant = 80
            
        default: break
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // status bar text color 흰색으로 바꿔주기
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
