import UIKit
import WebKit

class NewsDetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {

    var detailData = NewsInfo()
    
    @IBOutlet weak var newsWKWebView: WKWebView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var bottomBackButton: UIButton!
    @IBOutlet weak var bottomForwardButton: UIButton!
    @IBOutlet weak var bottomRefreshButton: UIButton!
    
    @IBOutlet weak var topUIView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomUIView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    
    private var lastContentOffset: CGFloat = 0
    private var initialTopViewHeight: CGFloat = 0
    private var initialBottomViewHeight: CGFloat = 0
    
    private func loadWebPage(_ url: String) {
        guard let newsUrl = URL(string: url) else {return}
        let request = URLRequest(url: newsUrl)
        newsWKWebView.load(request)
    }

    override func loadView() {
        super.loadView()
        newsWKWebView.uiDelegate = self
        newsWKWebView.navigationDelegate = self
        newsWKWebView.scrollView.delegate = self
        initialTopViewHeight = topViewHeightConstraint.constant
        initialBottomViewHeight = bottomViewHeightConstraint.constant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage(detailData.newsURL)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\n⬇️ scrollViewDidScroll")
        if scrollView.contentOffset.y == 0 {
            topViewHeightConstraint.constant = initialTopViewHeight
            bottomViewHeightConstraint.constant = initialBottomViewHeight
            cancelButton.isHidden = false; backButton.isHidden = false; forwardButton.isHidden = false;
//            bottomRefreshButton.isHidden = false; bottomBackButton.isHidden = false; bottomForwardButton.isHidden = false
        } else if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= (scrollView.contentSize.height - newsWKWebView.frame.height) {
            
            print("컨텐츠 내부")
            
            if (self.lastContentOffset > scrollView.contentOffset.y) {  // 스크롤 올릴때
                print("move up")
                view.layoutIfNeeded() //layout을 모두 업데이트 시켜놓는다.
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.bottomViewHeightConstraint.constant =  self.initialBottomViewHeight
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                if topViewHeightConstraint.constant <= initialTopViewHeight {   //  topView
                    topViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y)/(initialBottomViewHeight/initialTopViewHeight)
                    if topViewHeightConstraint.constant >= initialTopViewHeight {
                        topViewHeightConstraint.constant = initialTopViewHeight
                    } else if topViewHeightConstraint.constant > initialTopViewHeight / 2 {
                        cancelButton.isHidden = false; backButton.isHidden = false; forwardButton.isHidden = false
                    }
                }

//                if bottomViewHeightConstraint.constant <= initialBottomViewHeight {   //  bottomView
//                    bottomViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y)
//                    if bottomViewHeightConstraint.constant >= initialBottomViewHeight {
//                        bottomViewHeightConstraint.constant = initialBottomViewHeight
//                    } else if bottomViewHeightConstraint.constant > initialBottomViewHeight * 2 / 3 {
//                        bottomRefreshButton.isHidden = false; bottomBackButton.isHidden = false; bottomForwardButton.isHidden = false
//                    }
//                }
            }
            
            else if (self.lastContentOffset < scrollView.contentOffset.y) { // 스크롤 내릴때
                print("move down")
                view.layoutIfNeeded() //layout을 모두 업데이트 시켜놓는다.
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.bottomViewHeightConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                if topViewHeightConstraint.constant > 0 {   //  topView
                    topViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y)/(initialBottomViewHeight/initialTopViewHeight)
                    if topViewHeightConstraint.constant <= 0 {
                        topViewHeightConstraint.constant = 0
                        cancelButton.isHidden = true; backButton.isHidden = true; forwardButton.isHidden = true  // backButton시 필요
                    } else if topViewHeightConstraint.constant <= initialTopViewHeight / 2  {
                        cancelButton.isHidden = true; backButton.isHidden = true; forwardButton.isHidden = true
                    }
                }

//                if bottomViewHeightConstraint.constant > 0 {   //  bottomView
//                    bottomViewHeightConstraint.constant += (self.lastContentOffset - scrollView.contentOffset.y)
//                    if bottomViewHeightConstraint.constant <= 0 {
//                        bottomViewHeightConstraint.constant = 0
//                        bottomRefreshButton.isHidden = true; bottomBackButton.isHidden = true; bottomForwardButton.isHidden = true
//                    } else if bottomViewHeightConstraint.constant <= initialBottomViewHeight * 2 / 3  {
//                        bottomRefreshButton.isHidden = true; bottomBackButton.isHidden = true; bottomForwardButton.isHidden = true
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
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        forwardButton.isEnabled = newsWKWebView.canGoForward
        bottomForwardButton.isEnabled = newsWKWebView.canGoForward
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if newsWKWebView.canGoBack {
            newsWKWebView.goBack()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        if newsWKWebView.canGoForward {
            newsWKWebView.goForward()
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        newsWKWebView.reload()
    }
    
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() } //모달창 닫힐때 앱 종료현상 방지.
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in completionHandler(false) }))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler(true) }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // href="_blank" 처리
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil
    }
        
}
