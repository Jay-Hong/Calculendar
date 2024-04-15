import UIKit
import WebKit

class SubscriptionDetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet weak var detailWKWebView: WKWebView!
    
    var detailURL: String?
    
    private func loadWebPage(_ url: String) {
        guard let newsUrl = URL(string: url) else {return}
        let request = URLRequest(url: newsUrl)
        detailWKWebView.load(request)
    }
    
    override func loadView() {
        super.loadView()
        detailWKWebView.uiDelegate = self
        detailWKWebView.navigationDelegate = self
        detailWKWebView.scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWebPage(detailURL ?? "")
    }
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
