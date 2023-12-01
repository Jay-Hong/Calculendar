import UIKit

class BackupRestoreViewController: UITableViewController {
    
    let backupSubview = UIView()
    let backupActivityIndicatorView = UIActivityIndicatorView()
    
    struct DocumentsDirectory {
        //  설정 "iCloud를 사용하는 앱" 에서 공수계산기를 꺼 놓으면  ⌜DocumentsDirectory.iCloudDocumentsURL == nil⌟
        //  My Mac 으로 테스트 하려면 "Document" 모드로 할 것 (폰과 Mac의 파일구조가 다른 듯)
        //  My Mac 은 UbiquitousKeyValueStore 역시 가져오지 못한다
//        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.Jay.Calculendar")
        static let localDocumentsURL = dataFilePath!
    }
    
    enum UploadStatus {
        case uploadedAll
        case uploading
        case nothing    //  Just In Case
        case error
    }
    var uploadCheckerSec : Int = 0
    let uploadCheckerEndSec : Int = 60  //  해당 초 동안 Upload 완료 체크
    
    enum DownloadStatus {
        case downloadedAll  //  모두 다운로드 됨
        case notDownloaded  //  다운로드 완료되지 않음
        case error          //  Error 발생
    }
    var downloadCheckerSec : Int = 0
    let downloadCheckerEndSec : Int = 60    //  해당 초 동안 Download 완료 체크
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  백업 / 복원시 모래시계 표시하기 위함
        backupSubview.frame = self.view.frame
        backupSubview.backgroundColor = .black
        backupSubview.alpha = 0.6
        backupActivityIndicatorView.frame = CGRect(x:0, y:0, width:40, height:40)
        backupActivityIndicatorView.style = UIActivityIndicatorView.Style.large
        backupActivityIndicatorView.center = CGPoint(x: backupSubview.frame.size.width / 2, y: backupSubview.frame.size.height / 3)
        backupSubview.addSubview(backupActivityIndicatorView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.row == 0 {
            print(" + + + + + + + + + + + + + + + + + + + iCloud 백업 클릭 + + + + + + + + + + + + + + + + + ")
            let alert = UIAlertController(title: "⚠️\n새로운 백업 진행시 기존 백업은 삭제됩니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in }
            let okAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
                guard self.isiCloudEnabled() else { self.backupIsNotDone(); return }
                self.uploadFilesToCloud()
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            print(" + + + + + + + + + + + + + + + + + iCloud 데이터 가져오기 클릭 + + + + + + + + + + + + + + + ")
            let alert = UIAlertController(title: "⚠️\n현재 공수계산기 내용은 모두 삭제됩니다\n(백업된 데이터로 복원)", message: "", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in }
            let okAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
                guard self.isiCloudEnabled() else { self.restoreIsNotDone(); return }
                self.downloadFilesToLocal()
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:  -   iCloud 백업 / 복원
    
    //  설정 "iCloud를 사용하는 앱" 에서 공수계산기를 꺼 놓으면  ⌜DocumentsDirectory.iCloudDocumentsURL == nil⌟
    func isiCloudEnabled() -> Bool {
        return (DocumentsDirectory.iCloudDocumentsURL != nil) ? true : false
    }
    
    func uploadFilesToCloud() {
        let fileManager = FileManager.default
        var enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
        
        //  기기에 백업할 파일이 없는지 검사
        let enumeratorChecker = enumerator
        guard (enumeratorChecker?.nextObject()) != nil else {
            print("DEVICE has no files to Upload")
            let alert = UIAlertController(title: "백업할 데이터가 없습니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        //  백업 할 파일이 있다면 준비 시작
        self.view.addSubview(backupSubview)
        backupActivityIndicatorView.startAnimating()
        
        guard createDocumentsDirectory() else { backupIsNotDone(); return }  //  폴더 생성 중 오류가 난다면 이미 백업 실패

        guard deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL) else { backupIsNotDone(); return } // iCloud Clear 중 오류가 나도 이미 백업 실패
        
        enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
        print(" - - - - - - - - - - - - - - - Coping Items from Local to iCloud - - - - - - - - - - - - - ")
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                print("\(file.description) is Started to Copy to iCloud")
            } catch let error as NSError {
                print("Failed to move ⌜\(file)⌟ file to Cloud : \(error)")
                backupIsNotDone(); return
            }
        }
        
        watchUploadStatus()
        
    }
    
    func watchUploadStatus() {
        uploadCheckerSec += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            let status = self.checkCurrentUploadStatus()
            switch status {
            case .uploadedAll:
                self.backupIsDone()
            case .error, .nothing:
                self.backupIsNotDone()
            case .uploading :
                if self.uploadCheckerSec >= self.uploadCheckerEndSec {
                    self.uploadCheckerSec = 0
                    self.backupIsNotDone()
                } else {
                    self.watchUploadStatus()
                }
            }
        }
    }
    
    func checkCurrentUploadStatus() -> UploadStatus {
        print(" - - - - - - - - - - - - - - - - - - - checkUploadStatus - - - - - - - - - - - - - - - - - ")
        let enumerator = FileManager.default.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                let uploadedKey = try DocumentsDirectory.iCloudDocumentsURL?.appendingPathComponent(file).resourceValues(forKeys: [.ubiquitousItemIsUploadedKey])
                let uploadingKey = try DocumentsDirectory.iCloudDocumentsURL?.appendingPathComponent(file).resourceValues(forKeys: [.ubiquitousItemIsUploadingKey])
                if (uploadedKey?.ubiquitousItemIsUploaded)! {
                    print("\(file) is Uploaded")
                } else if (uploadingKey?.ubiquitousItemIsUploading)! {
                    print("\(file) is Uploading")
                    return UploadStatus.uploading
                } else {
                    print("\(file) is not even started to Upload")
                    return UploadStatus.nothing
                }
            } catch let error as NSError {
                print("⌜\(file)⌟ Failed to iCloud uploading : \(error.localizedDescription)")
                return UploadStatus.error
            }
        }
        return UploadStatus.uploadedAll
    }
    
    func backupIsDone() {
        setUbiquitousKeyValueStore()
        backupActivityIndicatorView.stopAnimating()
        backupSubview.removeFromSuperview()
        print(" = = = = = = = = = = = = = = = = = = = = backupIsDone = = = = = = = = = = = = = = = = = = = ")
        let alert = UIAlertController(title: "백업이 완료 되었습니다", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func backupIsNotDone() {
        self.backupActivityIndicatorView.stopAnimating()
        self.backupSubview.removeFromSuperview()
        print(" = = = = = = = = = = = = = = = = = = = backupIsNotDone = = = = = = = = = = = = = = = = = = = ")
        let alert = UIAlertController(title: "백업을 완료할 수 없습니다", message: "iCloud 설정 & 네트워크 상태를 확인해주세요", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func createDocumentsDirectory() -> Bool {
        print(" - - - - - - - - - - - - - - - - - - createDocumentsDirectory - - - - - - - - - - - - - - - ")
        if !FileManager.default.fileExists(atPath: DocumentsDirectory.iCloudDocumentsURL!.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: DocumentsDirectory.iCloudDocumentsURL!, withIntermediateDirectories: true, attributes: nil)
                print("created iCloud Documents Directory")
            }
            catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            print("iCloud Documents Directory already exsists")
        }
        return true
    }
    
    func deleteFilesInDirectory(url: URL?) -> Bool{
        print(" - - - - - - - - - - - - - - - - - - deleteFilesInDirectory - - - - - - - - - - - - - - - - ")
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("\(file.description) Files deleted")
            } catch let error as NSError {
                print("Failed deleting ⌜\(file)⌟ : \(error)")
                return false
            }
        }
        return true
    }
    
    func downloadFilesToLocal() {
        let fileManager = FileManager.default
        var enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
        
        //  iCloud 에 백업된 파일이 없는지 검사
        guard (enumerator?.nextObject()) != nil else {
            print("iCloud has no files to Download")
            let alert = UIAlertController(title: "백업파일이 존재하지 않습니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        //  iCloud 에 파일이 있다면 준비 시작
        self.view.addSubview(backupSubview)
        backupActivityIndicatorView.startAnimating()
        
        enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
        print(" - - - - - - - - - - - - - Start to download from iCloud to Local - - - - - - - - - - - - ")
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.startDownloadingUbiquitousItem(at: (DocumentsDirectory.iCloudDocumentsURL?.appendingPathComponent(file))!)
                print("\(file.description) is Started to download to Local")
            } catch let error as NSError {
                print("Failed to download ⌜\(file)⌟ file to local dir : \(error)")
                restoreIsNotDone(); return
            }
        }
        
        //  기존파일 정상적으로 삭제되지 않으면 복원 실패
        guard deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL) else { restoreIsNotDone(); return }
        
        watchDownloadStatus()
        
    }
  
    func watchDownloadStatus() {
        downloadCheckerSec += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            let status = self.checkCurrentDownloadStatus()
            switch status {
            case .downloadedAll:
                self.downloadIsDone()
            case .error:
                self.restoreIsNotDone()
            case .notDownloaded :
                if self.downloadCheckerSec >= self.downloadCheckerEndSec {
                    self.downloadCheckerSec = 0
                    self.restoreIsNotDone()
                } else {
                    self.watchDownloadStatus()
                }
            }
        }
    }
    
    func checkCurrentDownloadStatus() -> DownloadStatus {
        print(" - - - - - - - - - - - - - - - check Current Download Status - - - - - - - - - - - - - - - ")
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                let status = try DocumentsDirectory.iCloudDocumentsURL?.appendingPathComponent(file).resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                if status?.ubiquitousItemDownloadingStatus == .current {
                    print("\(file) is .current")
                } else if status?.ubiquitousItemDownloadingStatus == .notDownloaded || status?.ubiquitousItemDownloadingStatus == .downloaded {
                    print("\(file) is \(status?.ubiquitousItemDownloadingStatus == .notDownloaded ? ".notDownloaded" : "downloaded")")
                    return DownloadStatus.notDownloaded
                }
            } catch let error as NSError {
                print("Failed to get status : \(error.localizedDescription)")
                return DownloadStatus.error
            }
        }
        return DownloadStatus.downloadedAll
    }
    
    func downloadIsDone() {
        print(" - - - - - - - - - - - - - Coping Items from iCloud Container to Local - - - - - - - - - - - ")
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
                print("\(file.description) Moved to local dir")
            } catch let error as NSError {
                print("Failed to copy Items from iCloud Container to Local: \(error)")
                restoreIsNotDone(); return
            }
        }
        getUbiquitousKeyValueStore()
        print(" = = = = = = = = = = = = = = = = 복원 완료!! Restore is done!! = = = = = = = = = = = = = = = = ")
        backupActivityIndicatorView.stopAnimating()
        backupSubview.removeFromSuperview()
        NotificationCenter.default.post(name: .didRestoreOperation, object: nil)
        let alert = UIAlertController(title: "iCloud 데이터 가져오기 완료", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func restoreIsNotDone() {
        print(" = = = = = = = = = = = = = = = = = = = restoreIsNotDone = = = = = = = = = = = = = = = = = = = ")
        self.backupActivityIndicatorView.stopAnimating()
        self.backupSubview.removeFromSuperview()
        NotificationCenter.default.post(name: .didRestoreOperation, object: nil)
        let alert = UIAlertController(title: "복원을 완료할 수 없습니다", message: "iCloud 설정 & 네트워크 상태를 확인해주세요", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getUbiquitousKeyValueStore() { //  NSUbiquitousKeyValueStore -> UserDefaults
        print(" - - - - - - - - - - - - - - - - getUbiquitousKeyValueStore - - - - - - - - - - - - - - - - ")
        let keyValueStore = NSUbiquitousKeyValueStore()
        //  == NSUbiquitousKeyValueStore.default
        
        if let basePay = keyValueStore.string(forKey: SettingsKeys.basePay) {
            UserDefaults.standard.setValue(basePay, forKey: SettingsKeys.basePay)
            print("기본단가 : \(basePay)")
        } else {
            print("UbiquitousKeyValueStore : 기본단가를 받아오는데 실패하였습니다.")
        }
        
        let moneyUnit = keyValueStore.longLong(forKey: SettingsKeys.moneyUnit)
        UserDefaults.standard.setValue(moneyUnit, forKey: SettingsKeys.moneyUnit)
        print("화폐단위 : \(moneyUnitsDataSource[Int(moneyUnit)])")
        
        let taxRateFront = keyValueStore.longLong(forKey: SettingsKeys.taxRateFront)
        UserDefaults.standard.setValue(taxRateFront, forKey: SettingsKeys.taxRateFront)
        
        let taxRateBack = keyValueStore.longLong(forKey: SettingsKeys.taxRateBack)
        UserDefaults.standard.setValue(taxRateBack, forKey: SettingsKeys.taxRateBack)
        print("세금 : \(taxRateFront).\(taxRateBack)")
        
        var startDay = keyValueStore.longLong(forKey: SettingsKeys.startDay)
        startDay = startDay == 0 ? 1 : startDay // 초기값 0일경우 1일로 만들어 줌
        UserDefaults.standard.setValue(startDay, forKey: SettingsKeys.startDay)
        print("월 시작일 : \(startDay)")
        
        //  일급:0 / 시급:1  (기본값: 0 - 일급)
        let paySystemIndex = keyValueStore.longLong(forKey: SettingsKeys.paySystemIndex)
        UserDefaults.standard.setValue(paySystemIndex, forKey: SettingsKeys.paySystemIndex)
        print("급여형태 : \(paySystemIndex == 0 ? "일급": "시급")")
        
        //  한달:0 / 하루:1  (기본값: 0 - 한달)
        let unitOfWorkSettingPeriodIndex = keyValueStore.longLong(forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
        UserDefaults.standard.setValue(unitOfWorkSettingPeriodIndex, forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
        print("단가변경 : \(unitOfWorkSettingPeriodIndex == 0 ? "한달씩" : "하루씩")")
    }
    
    func setUbiquitousKeyValueStore() { //  UserDefaults -> NSUbiquitousKeyValueStore
        print(" - - - - - - - - - - - - - - - - setUbiquitousKeyValueStore - - - - - - - - - - - - - - - - ")
        let keyValueStore = NSUbiquitousKeyValueStore()
        //  == NSUbiquitousKeyValueStore.default
        
        let basePay = UserDefaults.standard.object(forKey: SettingsKeys.basePay) as? String ?? "0"
        keyValueStore.set(basePay, forKey: SettingsKeys.basePay)
        print("기본단가 : \(basePay)")
        
        let moneyUnit = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        keyValueStore.set(moneyUnit, forKey: SettingsKeys.moneyUnit)
        print("화폐단위 : \(moneyUnitsDataSource[Int(moneyUnit)])")
        
        let taxRateFront = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateFront)
        keyValueStore.set(taxRateFront, forKey: SettingsKeys.taxRateFront)
        
        let taxRateBack = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateBack)
        keyValueStore.set(taxRateBack, forKey: SettingsKeys.taxRateBack)
        print("세금 : \(taxRateFront).\(taxRateBack)")
        
        
        var startDay = UserDefaults.standard.integer(forKey: SettingsKeys.startDay)
        startDay = startDay == 0 ? 1 : startDay // 초기값 0일경우 1일로 만들어 줌
        keyValueStore.set(startDay, forKey: SettingsKeys.startDay)
        print("월 시작일 : \(startDay)")
        
        //  일급:0 / 시급:1  (기본값: 0 - 일급)
        let paySystemIndex = UserDefaults.standard.integer(forKey: SettingsKeys.paySystemIndex)
        keyValueStore.set(paySystemIndex, forKey: SettingsKeys.paySystemIndex)
        print("급여형태 : \(paySystemIndex == 0 ? "일급": "시급")")
        
        //  한달:0 / 하루:1  (기본값: 0 - 한달)
        let unitOfWorkSettingPeriodIndex = UserDefaults.standard.integer(forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
        keyValueStore.set(unitOfWorkSettingPeriodIndex, forKey: SettingsKeys.unitOfWorkSettingPeriodIndex)
        print("단가변경 : \(unitOfWorkSettingPeriodIndex == 0 ? "한달씩" : "하루씩")")

        keyValueStore.synchronize()
    }
}
