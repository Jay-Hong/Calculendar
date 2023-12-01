import UIKit
import GoogleMobileAds

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    //    var newsInfoList: [NewsInfo] = []
    //    var newsInfoList: [AnyObject] = []
    var newsInfoList = [AnyObject]()
    
//    var adNativeUnit = "ca-app-pub-3940256099942544/3986624511" // TEST
    var adNativeUnit = "ca-app-pub-5095960781666456/8151852600"   //  REAL
    
    let numAdItems = 5
    var nextBigCell = Int()
    
    var newsListBigAdIndex = [Int]()
    var newsListSmallAdIndex = [Int]()
    var newsListAllAdIndex = Array<Int>()
    
    var imageItemWords = [Substring]()
    
    let strToInt: (Substring) -> Int = { Int($0) ?? 9999 }  //  .map() 사용 위함 -> String을 Int로 변환해줌
    
    var nativeAds = [GADNativeAd]()
    
    var adLoader: GADAdLoader!
    
    private func registerXib() {
        let nibName = UINib(nibName: "NewsListBigImageCell", bundle: nil)
        newsTableView.register(nibName, forCellReuseIdentifier: "NewsListBigImageCell2")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerXib()
        newsTableView.rowHeight = UITableView.automaticDimension
        getRemoteConfig()
        setAdMob()
        
        // URL 에서 json 데이터 가져오기
        let jsonURLString = "https://raw.githubusercontent.com/Jay-Hong/News_JSON/master/newsURL.json"
        // let jsonURLString = remoteConfig.configValue(forKey: RemoteConfigKeys.newsDB_GithubURL).stringValue ?? ""
        guard let jsonURL = URL(string: jsonURLString) else {return}
        URLSession.shared.dataTask(with: jsonURL) { data, response, error in
            guard let jsonData = data else {return}
            do{
                self.newsInfoList = try JSONDecoder().decode([NewsInfo].self, from: jsonData)
                DispatchQueue.main.async(execute: {
                    self.newsInfoList.shuffle()
                    self.newsTableView.reloadData()
                })
            }catch{
                print("\(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func getRemoteConfig() {
        //  사진 꼭 넣을 뉴스단어 가져오기
        let imageItemWordsString = remoteConfig.configValue(forKey: RemoteConfigKeys.newsListImageWords).stringValue ?? ""
        imageItemWords = imageItemWordsString.split(separator: ",")
        print("\n\n\(imageItemWords)\n")
        
        //  큰 사진 반복 Index
        let preNextBigCell = Int(truncating: remoteConfig.configValue(forKey: RemoteConfigKeys.newsListNextBigCell).numberValue)   //  Int(NSNumber)
        nextBigCell = preNextBigCell == 0 ? 1 : preNextBigCell  // newxtBigCell 이 0 이 되지 않게 (아래 코드에서 0으로 나누면 Error)
        
        //  작은 광고 Index
        let newsListAdString = remoteConfig.configValue(forKey: RemoteConfigKeys.newsListAdIndex).stringValue ?? ""
        newsListSmallAdIndex = newsListAdString.split(separator: ",").map(strToInt)
        
        //  큰 광고 Index
        let newsListBigAdString = remoteConfig.configValue(forKey: RemoteConfigKeys.newsListBigAdIndex).stringValue ?? ""
        newsListBigAdIndex = newsListBigAdString.split(separator: ",").map(strToInt)
        
        let newsListAllAdItemsIndexSet = Set(newsListSmallAdIndex + newsListBigAdIndex)   // Set으로 중복제거
        newsListAllAdIndex = newsListAllAdItemsIndexSet.sorted()                          // sorted() 로 정렬하여 Set -> Array
        print("\nnewsListAllAdIndex :\n\(newsListAllAdIndex)\n")
    }
    
    
    func setAdMob() {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) || newsListAllAdIndex.isEmpty {
            //  Do nothing
        } else {
            loadNativeAd(numAdItems)    //  광고 로드
        }
    }
    
    
    func loadNativeAd(_ adCnt: Int) {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = adCnt
        self.adLoader = GADAdLoader(adUnitID: self.adNativeUnit, rootViewController: self,
                                    adTypes: [.native],
                                    options: [multipleAdsOptions])
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
        
        newsTableView.register(UINib(nibName: "NativeAdCell", bundle: nil),forCellReuseIdentifier: "NativeAdCell")
        newsTableView.register(UINib(nibName: "NativeAdBigCell", bundle: nil),forCellReuseIdentifier: "NativeAdBigCell")
    }
    
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("Received native ad: \(nativeAd)")
        self.nativeAds.append(nativeAd)
        nativeAd.delegate = self
    }
    
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("\n\n   adLoaderDidFinishLoading \n\n")
        
        if !nativeAds.isEmpty {
            let availableAds =  newsListAllAdIndex.filter { $0 < newsInfoList.count }                                  //  newsInfoList  크기보다 큰 수는 제외 (Array index Error 방지)
            let filteredAdItemsIndex =  newsListAllAdIndex.filter { $0 < newsInfoList.count + availableAds.count }     //  newsInfoList + availableAds (Array index Error 방지)
            
            print("\n\n newsInfoList.count : \(newsInfoList.count)\n")
            print("\n\n availableAds : \(availableAds)\n")
            print("\n filteredAdItemsIndex : \(filteredAdItemsIndex)\n")
            
            for (index, itemIndex) in filteredAdItemsIndex.enumerated() {
                let nativeAd = self.nativeAds[index % numAdItems]
                self.newsInfoList.insert(nativeAd, at: itemIndex)
            }
            self.newsTableView.reloadData()
        }
    }
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\n\n \(adLoader) failed with error: \(error.localizedDescription) \n\n")
        print("Failed to receive ads \n\n")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsInfoList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newsInfoItem = newsInfoList[indexPath.item]
        
        if newsInfoItem is GADNativeAd {
            let nativeAd = newsInfoItem as! GADNativeAd
            nativeAd.rootViewController = self
            
            if newsListBigAdIndex.contains(indexPath.item) {
                let nativeAdBigCell = tableView.dequeueReusableCell(withIdentifier: "NativeAdBigCell", for: indexPath)
                let adView : GADNativeAdView = nativeAdBigCell.contentView.subviews.first as! GADNativeAdView
                adView.nativeAd = nativeAd
                (adView.headlineView as? UILabel)?.text = nativeAd.headline
                (adView.bodyView as? UILabel)?.text = nativeAd.body
                (adView.callToActionView as? UIButton)?.isUserInteractionEnabled = false
                return nativeAdBigCell
            } else {
                let nativeAdCell = tableView.dequeueReusableCell(withIdentifier: "NativeAdCell", for: indexPath)
                let adView : GADNativeAdView = nativeAdCell.contentView.subviews.first as! GADNativeAdView
                adView.nativeAd = nativeAd
                (adView.headlineView as? UILabel)?.text = nativeAd.headline
                (adView.bodyView as? UILabel)?.text = nativeAd.body
                (adView.callToActionView as? UIButton)?.isUserInteractionEnabled = false
                return nativeAdCell
            }
//            (adView.headlineView as? UILabel)?.text = nativeAd.headline
//            (adView.priceView as! UILabel).text = nativeAd.price
//            if let starRating = nativeAd.starRating {(adView.starRatingView as! UILabel).text = starRating.description + "\u{2605}"
//            } else {(adView.starRatingView as! UILabel).text = nil}
//            (adView.bodyView as? UILabel)?.text = nativeAd.body
//            (adView.advertiserView as! UILabel).text = nativeAd.advertiser
//            // The SDK automatically turns off user interaction for assets that are part of the ad, but it is still good to be explicit.
//            (adView.callToActionView as? UIButton)?.isUserInteractionEnabled = false
//            (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: UIControl.State.normal)
                        
        } else {
            
            let newsInfoItem = newsInfoItem as! NewsInfo

            if ( newsInfoItem.title.count > 43 && !newsInfoItem.title.contains(imageItemWords) ) || newsInfoItem.image == "" || newsInfoItem.image.contains("blank") {   //  https://news.nateimg.co.kr/ui/uidev/images/mobile/img/common/blank_138x79.jpg
                let noImagecell = tableView.dequeueReusableCell(withIdentifier: "NewsListNoImageCell", for: indexPath) as! NewsListCell
                noImagecell.newsTitleLabel.text = newsInfoItem.title
                noImagecell.newsCompanyLabel.text = newsInfoItem.company
                return noImagecell
            } else if indexPath.item % nextBigCell == 0 {
                let bigImageCell = tableView.dequeueReusableCell(withIdentifier: "NewsListBigImageCell2", for: indexPath) as! NewsListBigImageCell
                if let url = URL(string: newsInfoItem.image) { bigImageCell.newsImageView.load(url: url) }
                bigImageCell.newsTitleLabel.text = newsInfoItem.title
                bigImageCell.newsCompanyLabel.text = newsInfoItem.company
                return bigImageCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListCell", for: indexPath) as! NewsListCell
                if let url = URL(string: newsInfoItem.image) { cell.newsImageView.load(url: url) }
                cell.newsTitleLabel.text = newsInfoItem.title
                cell.newsCompanyLabel.text = newsInfoItem.company
                return cell
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewsDetailVCSegue"{
            if let newsDetailVC = segue.destination as? NewsDetailViewController {
                newsDetailVC.detailData = newsInfoList[newsTableView.indexPathForSelectedRow!.row] as! NewsInfo
            }
        }
    }
    
    
    //  xib 사용한 Cell 만들었다면 아래 didSelectRowAt 함수 꼭 사용해줘야 클릭된다
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toNewsDetailVCSegue", sender: nil)
    }
    
    
    // This for debugging
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("The native ad was shown.")
    }
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("The native ad was clicked on.")
    }
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("The native ad will present a full screen view.")
    }
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("The native ad will dismiss a full screen view.")
    }
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("The native ad did dismiss a full screen view.")
    }
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        print("The native ad will cause the application to become inactive and open a new application.")
    }
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension String {  //  문자배열 contains 확인
    func contains(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
    func contains(_ strings: [Substring]) -> Bool {
        strings.contains { contains($0) }
    }
}
