import UIKit
import MessageUI
import FirebaseDatabase
import GoogleMobileAds

class JobListViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var jobTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    var jobInfoList: [JobInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  0:GitHub 에서 JSON파일 가져오기 , 1:Remote Config 통한 JSON , 2:Firebase ReaitimeDB , 3:서버점검 메세지
        let selectedDB = remoteConfig.configValue(forKey: RemoteConfigKeys.selectJobDB).numberValue
        
        switch selectedDB {
        case 0:
            jobDBfromGithubJSON()
        case 1:
            jobDBfromFirebaseRemoteConfig()
        case 2:
            jobDBfromFirebaseRealTimeDB()
        case 3:
            chekingServer()
        default:
            noJobDB()
            return
        }
        
        setAdMob()
    }
    
    func jobDBfromGithubJSON() {
        // URL 에서 json 데이터 가져오기
        //        let jsonURLString = "https://raw.githubusercontent.com/Jay-Hong/iTshirt/master/jobinfoURL.json"   // TEST URL
        let jsonURLString = remoteConfig.configValue(forKey: RemoteConfigKeys.jobDB_GithubURL).stringValue ?? ""
        guard let jsonURL = URL(string: jsonURLString) else {return}
        URLSession.shared.dataTask(with: jsonURL) { data, response, error in
            guard let jsonData = data else {return}
            do{
                self.jobInfoList = try JSONDecoder().decode([JobInfo].self, from: jsonData)
                DispatchQueue.main.async(execute: {
                    self.jobTableView.reloadData()
                })
            }catch{
                print("\(error.localizedDescription)")
            }
        }.resume()
    }
    
    func jobDBfromFirebaseRemoteConfig() {
        // Rmote Config 에서 JSON 가져오기 [파이어베이스 콘솔에서 jobInfoJSONRemoteConfigKey => 인앱 기본값 사용 시 서버점검중 글자 맨 위 셀에 띄움(remote_config_defaults.plist 에 설정되어 있음)]
        let jsonData = remoteConfig.configValue(forKey: RemoteConfigKeys.jobInfoJSON).dataValue
        do{
            self.jobInfoList = try JSONDecoder().decode([JobInfo].self, from: jsonData)
            DispatchQueue.main.async(execute: {
                self.jobTableView.reloadData()
            })
        }catch{
            print("\(error.localizedDescription)")
        }
    }
    
    func jobDBfromFirebaseRealTimeDB() {
        // 파이어 베이스 Realtime Database 에서 정보 가져오기
        databaseReference.child("jobinfo").observeSingleEvent(of: .value){ snapshot in
            //snapshot의 값을 딕셔너리 형태로 변경해줍니다.
            guard let snapData = snapshot.value as? [String:Any] else {return}
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do{
                self.jobInfoList = try JSONDecoder().decode([JobInfo].self, from: data)
                DispatchQueue.main.async(execute: {
                    self.jobTableView.reloadData()
                })
            }catch{
                print("\(error.localizedDescription)")
            }
            print("data : \(data)\n\n")
        }
    }
    
    func chekingServer() {
        // 서버점검 메시지
        let alert = UIAlertController(title: "⚠️\n\n서버 점검 중 입니다\n", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
//            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in }
        alert.addAction(okAction)
//            alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func noJobDB() {
        let alert = UIAlertController(title: "⚠️\n\nDB를 가져오지 못하였 습니다\n", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func writeButtonAction(_ sender: Any) {
        sendJobInfoMail()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setAdMob() {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) || !remoteConfig.configValue(forKey: RemoteConfigKeys.jobListAD).boolValue {
            bannerView.isHidden = true
            bannerViewHeightConstraint.constant = 0
        } else {
            bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
            bannerView.adUnitID = "ca-app-pub-5095960781666456/9570600544"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }

}


extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\nnumberOfRowsInSection\n")
        return jobInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobBasicCell", for: indexPath) as! JobListCell
        
        let jobInfoTemp = jobInfoList[indexPath.row]
        print("\nindexPath row : \(indexPath.row)")
        
        cell.jobSiteLabel.text = jobInfoTemp.site
        cell.jobTitleLabel.text = jobInfoTemp.title
        cell.jobTypeLabel.text = jobInfoTemp.type
        cell.jobPayLabel.text = jobInfoTemp.pay
        
        
        switch jobInfoTemp.etc1 {
        case "":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case " ":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case "숙식제공":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        case "4대보험":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.1841003787, green: 0.7484605911, blue: 0.06411089568, alpha: 1)
        case "장기근무":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "출퇴근가능":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        case "인기공고":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        case "아래디폴트":
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        default:
            cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        
        
        switch jobInfoTemp.etc2 {
        case "":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case " ":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case "숙식제공":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        case "4대보험":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.1841003787, green: 0.7484605911, blue: 0.06411089568, alpha: 1)
        case "장기근무":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "출퇴근가능":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        case "인기공고":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        case "아래디폴트":
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        default:
            cell.jobEtc2Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        
        
        switch jobInfoTemp.etc3 {
        case "":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case " ":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case "숙식제공":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        case "4대보험":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.1841003787, green: 0.7484605911, blue: 0.06411089568, alpha: 1)
        case "장기근무":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "출퇴근가능":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        case "인기공고":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        case "아래디폴트":
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        default:
            cell.jobEtc3Label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        

        cell.jobEtc1Label.textColor = UIColor.white
        cell.jobEtc1Label.text = jobInfoTemp.etc1
        cell.jobEtc1Label.layer.cornerRadius = 8
        cell.jobEtc1Label.layer.masksToBounds = true
        
        cell.jobEtc2Label.textColor = UIColor.white
        cell.jobEtc2Label.text = jobInfoTemp.etc2
        cell.jobEtc2Label.layer.cornerRadius = 8
        cell.jobEtc2Label.layer.masksToBounds = true
        
        cell.jobEtc3Label.textColor = UIColor.white
        cell.jobEtc3Label.text = jobInfoTemp.etc3
        cell.jobEtc3Label.layer.cornerRadius = 8
        cell.jobEtc3Label.layer.masksToBounds = true
        
//        cell.jobEtc1Label.backgroundColor = #colorLiteral(red: 0.977601601, green: 0.7735045688, blue: 0.1866027329, alpha: 1)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJobDetailVCSegue" {
            
            if let jobDetailVC = segue.destination as? JobDetailViewController {
                jobDetailVC.detailData = jobInfoList[jobTableView.indexPathForSelectedRow!.row]
            }
            
        }
    }
    
}


extension JobListViewController: MFMailComposeViewControllerDelegate {
    
    func sendJobInfoMail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let messageBody = remoteConfig.configValue(forKey: RemoteConfigKeys.jobInfoMail).stringValue ?? ""
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["hjpyooo@gmail.com"])
        mailComposerVC.setSubject("채용공고 올리기")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "hjpyooo@gmailcom", message: "현 기기에서 메일을 보낼수 없습니다\r\n위 메일주소로 연락주세요", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
