import UIKit
import MessageUI
import GoogleMobileAds
import FirebaseRemoteConfig

class MainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GADBannerViewDelegate {
    
    //MARK:  - Valuables
    @IBOutlet weak var mainYearMonthButton: UIButton!
    @IBOutlet weak var pageCalendarView: UIView!
    @IBOutlet weak var inputUnitOfWorkButton: UIButton!
    @IBOutlet weak var dashBoardCollectionView: UICollectionView!
    
    //  광고 , 광고 백뷰
    @IBOutlet weak var bannerBackView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerBackButton: UIButton!
    
    //  메인화면 광고 back View 높이 설정
    @IBOutlet weak var bannerBackViewHeightConstraint: NSLayoutConstraint!
    var originBannerBackViewHeight = CGFloat()
    
    //  년월 나오는 상단 바 높이 설정
    @IBOutlet weak var topBarViewHeightConstraint: NSLayoutConstraint!
    
    var pageVC = UIPageViewController()
    var nextCalendarVC = CalendarViewController()
    
    //  선택된 해당 년/월/일
    var selectedYear = Int()
    var selectedMonth = Int()
    var selectedDay = Int()
    
    //  달력 다음넘어갈 화면 년/월/일
    var nextYear = Int()
    var nextMonth = Int()
    var nextDay = Int()
    
    var startDay = Int()
    
    var strYearMonth = String()
    var strPreYearMonth = String()
    var strNextYearMonth = String()
    var itemArray = [Item]()
    var itemPreArray = [Item]()
    var itemNextArray = [Item]()
    
    //  각자의 팝업컨트롤에 넘겨질 변수
    var memoTemp = String()
    var payTemp = String()
    var unitOfWorkTemp = String()
    
    //  메인화면 하단 출력용 변수
    var strMonthlyUnitOfWork = String()
    var strMonthlyWorkDay = String()
    var strDaylyPay = String()
    var strMonthlySalaly = String()
    var strMonthlySalalyAfterTax = String()
    var strTax = String()
    var salaryDescription = String()
    
    
    //MARK:  - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        originBannerBackViewHeight = bannerBackViewHeightConstraint.constant    //  메인화면 하단 광고 다시 시작할시 필요
        setToday()
        setStartDay()
        setTopBar()
        setFormatter()
        makeCalendarScreen()
        makeCalendar()
        printPaySystemOnInputUnitOfWorkButton()
        setDashBoard()
        setAdMob()
        addNotification()
        fetchRemoteConfig()
        
    }
    
    
    func fetchRemoteConfig() {
        // FIXME: Remove below three lines before we go into production!!
        //        let settings = RemoteConfigSettings()
        //        settings.minimumFetchInterval = 0
        //        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Remote Config fetched!")
                remoteConfig.activate { changed, error in
                    print("Remote config activated!")
                    //  Remote config 가져오자마자 할일
                }
            } else {
                print("Remote Config not fetched")
                print("Error fetching remote config: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    
    func setStartDay() {
        startDay = UserDefaults.standard.integer(forKey: SettingsKeys.startDay)
    }
    
    
    func setFormatter() {
        //  세자리 숫자마다 , 표시위함
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 4
    }
    
    
    func addNotification() {
        //  기본단가(BasePay)가 새로 저장될 경우
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSaveBasePay), name: .didSaveBasePay, object: nil)
        //  화폐단위(MoneyUnit)가 변경 되었을 경우
        NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeMoneyUnitOnMain), name: .didChangeMoneyUnit, object: nil)
        //  세금세팅 변경되었을 경우
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSaveTaxRate), name: .didSaveTaxRate, object: nil)
        //  월 시작일 변경되어을 경우
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSaveStartDay), name: .didSaveStartDay, object: nil)
        //  급여형태 Toggle
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTogglePaySystem), name: .didTogglePaySystem, object: nil)
        //  날짜 바뀌면 Dash Board 다시 로드
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object:nil, queue: .main) { [weak self] _ in
            setToday()
            self?.setMonthlyUnitOfWorkOnDashboard()
            self?.setMonthlyWorkDayOnDashboard()
            self?.setMonthlySalalyOnDashboard()
            self?.dashBoardCollectionView.reloadData()
        }
        //  iCloud 백업파일 디바이스 복원 시
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRestoreOperation), name: .didRestoreOperation, object: nil)
        //  광고제거 구매/복원 시
        NotificationCenter.default.addObserver(self, selector: #selector(onDidPurchaseAdRemoval), name: .didPurchaseAdRemoval, object: nil)
        //  구매상태 업데이트 시
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdatePurchasedProducts), name: .didUpdatePurchasedProducts, object: nil)
    }
    
    @objc func onDidSaveBasePay(_ notification: Notification) {
        callDisplayDaylyPay()
    }
    
    @objc func onDidChangeMoneyUnitOnMain(_ notification: Notification) {
        setMonthlySalalyOnDashboard()
        dashBoardCollectionView.reloadData()
    }
    
    @objc func onDidSaveTaxRate(_ notification: Notification) {
        setMonthlySalalyOnDashboard()
        dashBoardCollectionView.reloadData()
    }
    
    @objc func onDidSaveStartDay(_ notification: Notification) {
        setStartDay()
        setMonthlyUnitOfWorkOnDashboard()
        setMonthlyWorkDayOnDashboard()
        setMonthlySalalyOnDashboard()
        dashBoardCollectionView.reloadData()
    }
    
    @objc func onDidTogglePaySystem(_ notification: Notification) {
        printPaySystemOnInputUnitOfWorkButton()
        dashBoardCollectionView.reloadData()    //  공수 / 시간
    }
    
    @objc func onDidRestoreOperation(_ notification: Notification) {
        moveYearMonth(year: selectedYear, month: selectedMonth)
    }
    
    //  구독모델 이후 사용 안함
    @objc func onDidPurchaseAdRemoval(_ notification: Notification) {
        bannerView.isHidden = true
        bannerBackView.isHidden = true
        bannerBackViewHeightConstraint.constant = 0
    }
    
    @objc func onDidUpdatePurchasedProducts(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) || !remoteConfig.configValue(forKey: RemoteConfigKeys.calendarHomeAD).boolValue {
            bannerView.isHidden = true
            bannerBackView.isHidden = true
            bannerBackButton.isHidden = true
            bannerBackViewHeightConstraint.constant = 0
        } else {
            bannerView.isHidden = false
            bannerBackView.isHidden = false
            bannerBackButton.isHidden = false
            if bannerBackViewHeightConstraint.constant != originBannerBackViewHeight {
                bannerBackViewHeightConstraint.constant = originBannerBackViewHeight
                setAdMob()
                makeCalendar()  //  광고가 생기면서 달력크기가 조정되지 않는 문제 해결
            }
        }
    }
    
    
    func setAdMob() {
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) || !remoteConfig.configValue(forKey: RemoteConfigKeys.calendarHomeAD).boolValue {
            bannerView.isHidden = true
            bannerBackView.isHidden = true
            bannerBackButton.isHidden = true
            bannerBackViewHeightConstraint.constant = 0
        } else {
            bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
            bannerView.adUnitID = "ca-app-pub-5095960781666456/5274670381"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            bannerBackButton.isHidden = true    //  광고게제 준비시에는 광고백버튼 안보이게
        }
    }
    
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("\n\n bannerView didFailToReceiveAdWithError: \(error.localizedDescription)\n\n")
        bannerView.isHidden = true
        bannerBackButton.isHidden = false   //  광고로드 실패 시 광고 백버튼 보이게
    }
    
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("\n\n bannerViewDidReceiveAd \n\n")
        bannerView.isHidden = false
        bannerBackButton.isHidden = true
    }
    
    
    func setTopBar() {
        //  Device Type 에 따라 화면 조정
        switch UIScreen.main.bounds.size {
            //  스토리보드 기본사이즈
            //  topBarViewHeightConstraint.constant = 40
            
        case iPhone15ProMax, iPhone15Pro, iPhone14, iPhone14Plus, iPhone13Pro, iPhone11: //  Top Bar 30으로 줄여주기
            topBarViewHeightConstraint.constant = 30
            bannerBackView.isHidden = false
            
        case iPhoneSE3, iPhone8Plus:  // Top Bar 40 유지
            topBarViewHeightConstraint.constant = 40
            bannerBackView.isHidden = false
            
        case iPhoneSE1:  //  Top Bar 40 유지
            topBarViewHeightConstraint.constant = 40
            bannerBackViewHeightConstraint.constant = 0
            bannerBackView.isHidden = true
            
        default:
            bannerBackView.isHidden = false
        }
    }
    
    
    func makeCalendarScreen() {
        // 달력화면 붙이기
        pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") as! UIPageViewController
        pageVC.view.frame = pageCalendarView.bounds
        addChild(pageVC)
        pageCalendarView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
    }
    
    
    func makeCalendar() {
        let firstViewController = createCalendarViewController(today)
        pageVC.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        mainYearMonthButton.setTitle("\(toYear)년 \(toMonth)월", for: .normal)
        selectYearMonthDay(year: toYear, month: toMonth, day: toDay)
        strYearMonth = "\(toYear)\(makeTwoDigitString(toMonth))"
        strPreYearMonth = makeStrPreYearMonth(year: toYear, month: toMonth)
        strNextYearMonth = makeStrNextYearMonth(year: toYear, month: toMonth)
        
        // 해당 월 공수 , 급여 , 단가 출력
        loadItems()
        loadPreItems()
        loadNextItems()
        setMonthlyUnitOfWorkOnDashboard()
        setMonthlyWorkDayOnDashboard()
        setMonthlySalalyOnDashboard()
        setDaylyPayOnDashboard()
    }
    
    
    func printPaySystemOnInputUnitOfWorkButton() {
        //  일급:0 / 시급:1  따른  공수입력 / 시간입력  버튼 출력
        switch UserDefaults.standard.integer(forKey: SettingsKeys.paySystemIndex) {
        case 0:
            inputUnitOfWorkButton.setTitle("공수", for: .normal)
        default:
            inputUnitOfWorkButton.setTitle("시간", for: .normal)
        }
    }
    
    
    func createDate (_ year: Int, _ month: Int, _ day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 12
        dateComponents.minute = 30
        
        let userCalendar = Calendar.current
        return userCalendar.date(from: dateComponents) ?? Date()
    }
    
    
    func createCalendarViewController(_ date: Date) -> CalendarViewController {
        let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CanlendarViewController") as! CalendarViewController
        calendarVC.date = date
        calendarVC.delegate = self
        return calendarVC
    }
    
    // MARK:  - Page View Controllers
    // viewControllerAfter / viewControllerBefore 의 일관성 없음!!
    // 같은 페이징 상환인데도 다음번 나와야할 ViewController를 준비할때가 있고 가끔 준비하지 않을때가 있음
    // willTransitionTo / didFinishAnimating 을 사용하여 해결
    
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        nextCalendarVC = pendingViewControllers[0] as! CalendarViewController   // 앞으로 가려고하는 달력 월
        let currentDate = nextCalendarVC.date
        nextYear = calendar.component(.year, from: currentDate)
        nextMonth = calendar.component(.month, from: currentDate)
        nextDay = (nextYear == toYear && nextMonth == toMonth) ? toDay : 1
        print("\nwillTransitionTo \(nextYear)년 \(nextMonth)월\n")
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let calendarVC = previousViewControllers[0] as! CalendarViewController  // 현재 달력 월
        let currentDate = calendarVC.date
        //        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        if month != nextMonth && completed {    //  completed 가 True ? => 페이지가 넘어갔다
            mainYearMonthButton.setTitle("\(nextYear)년 \(nextMonth)월", for: .normal)
            selectYearMonthDay(year: nextYear, month: nextMonth, day: nextDay)
            strYearMonth = "\(selectedYear)\(makeTwoDigitString(selectedMonth))"
            strPreYearMonth = makeStrPreYearMonth(year: selectedYear, month: selectedMonth)
            strNextYearMonth = makeStrNextYearMonth(year: selectedYear, month: selectedMonth)
            loadItems()
            loadPreItems()
            loadNextItems()
            setMonthlyUnitOfWorkOnDashboard()
            setMonthlyWorkDayOnDashboard()
            setMonthlySalalyOnDashboard()
            setDaylyPayOnDashboard()
            dashBoardCollectionView.reloadData()
            
            if nextCalendarVC.firstDayPosition % 2 == nextCalendarVC.preIndexPath.row % 2 {
                nextCalendarVC.calendarCollectionView.cellForItem(at: nextCalendarVC.preIndexPath)?.backgroundColor = nextCalendarVC.oddDaysColor
            } else {
                nextCalendarVC.calendarCollectionView.cellForItem(at: nextCalendarVC.preIndexPath)?.backgroundColor = nextCalendarVC.evenDaysColor
            }
            
//            nextCalendarVC.calendarCollectionView.cellForItem(at: nextCalendarVC.preIndexPath)?.backgroundColor = UIColor.clear
            nextCalendarVC.calendarCollectionView.cellForItem(at: nextCalendarVC.firstDayIndexPath)?.backgroundColor = nextCalendarVC.selectedDayColor
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController  // 현재 달력 월
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        
        switch month {
        case 12:
            month = 1
            year += 1
        default:
            month += 1
        }
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController  // 현재 달력 월
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        
        switch month {
        case 1:
            month = 12
            year -= 1
        default:
            month -= 1
        }
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    
    //MARK:  - Prepare for Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toYearMonthPopUpViewControllerSegue" {
            if let popupVC = segue.destination as? YearMonthPopUpViewController {
                popupVC.delegate = self
            }
        } else if segue.identifier == "toUnitOfWorkPopUpViewControllerSegue" {
            if let popupVC = segue.destination as? UnitOfWorkPopUpViewController {
                popupVC.delegate = self
                popupVC.strNumber = unitOfWorkTemp
                popupVC.selectedMonth = selectedMonth
                popupVC.selectedDay = selectedDay
            }
        } else if segue.identifier == "toMemoPopUpViewControllerSegue" {
            if let popupVC = segue.destination as? MemoPopUpViewController {
                popupVC.delegate = self
                popupVC.memo = memoTemp
                popupVC.selectedMonth = selectedMonth
                popupVC.selectedDay = selectedDay
            }
        } else if segue.identifier == "toPayPopUpViewControllerSegue" {
            if let popupVC = segue.destination as? PayPopUpViewController {
                popupVC.delegate = self
                popupVC.strNumber = payTemp
                popupVC.selectedMonth = selectedMonth
                popupVC.selectedDay = selectedDay
            }
        } else if segue.identifier == "toTaxBeforeAfterViewControllerSegue" {
            if let popupVC = segue.destination as? TaxBeforeAfterViewController {
                popupVC.titleDescription = salaryDescription
                popupVC.salaryBeforeTax = strMonthlySalaly
                popupVC.tax = strTax
                popupVC.salaryAfterTax = strMonthlySalalyAfterTax
            }
        }
    }
    
    
    //MARK:  - DashBoard Setting
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func setMonthlyUnitOfWorkOnDashboard() {
        
        var totalMonthlyUnitOfWork = Float()    //  해당월 총 공수(시간)
        //  현재 날짜에 따른 DashBoard 맞춤 출력
        if toDay >= startDay {
            switch startDay {
            case 1: //  시작일이 1일 일경우 해당월만 계산
                if !itemArray.isEmpty {
                    for item in itemArray
                    {totalMonthlyUnitOfWork += item.numUnitOfWork}
                }
            case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                if !itemArray.isEmpty {
                    for i in startDay - 1 ... itemArray.count - 1
                    {totalMonthlyUnitOfWork += itemArray[i].numUnitOfWork}
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {totalMonthlyUnitOfWork += itemNextArray[i].numUnitOfWork}
                }
            case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                if !itemArray.isEmpty {
                    totalMonthlyUnitOfWork += itemArray.last!.numUnitOfWork
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< itemNextArray.count - 1
                    {totalMonthlyUnitOfWork += itemNextArray[i].numUnitOfWork}
                }
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {totalMonthlyUnitOfWork += item.numUnitOfWork}
                }
            }
        } else {    //  toDay < startDay
            switch startDay {
            case 2..<numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {totalMonthlyUnitOfWork += itemArray[i].numUnitOfWork}
                }
                if !itemPreArray.isEmpty {
                    for i in startDay - 1 ... itemPreArray.count - 1
                    {totalMonthlyUnitOfWork += itemPreArray[i].numUnitOfWork}
                }
            case numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< itemArray.count - 1
                    {totalMonthlyUnitOfWork += itemArray[i].numUnitOfWork}
                }
                if !itemPreArray.isEmpty
                {totalMonthlyUnitOfWork += itemPreArray.last!.numUnitOfWork}
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {totalMonthlyUnitOfWork += item.numUnitOfWork}
                }
            }
        }
        
        strMonthlyUnitOfWork = String(format: "%.2f", totalMonthlyUnitOfWork)
        if strMonthlyUnitOfWork.contains(".") {
            while (strMonthlyUnitOfWork.hasSuffix("0")) {
                strMonthlyUnitOfWork.removeLast() }
            if strMonthlyUnitOfWork.hasSuffix(".") {
                strMonthlyUnitOfWork.removeLast() }
        }
    }
    
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func setMonthlyWorkDayOnDashboard() {
        var totalMonthlyWorkDay = Int()    //  해당월 총 근무일
        //  현재 날짜에 따른 DashBoard 맞춤 출력
        if toDay >= startDay {
            switch startDay {
            case 1: //  시작일이 1일 일경우 해당월만 계산
                if !itemArray.isEmpty {
                    for item in itemArray
                    {if item.numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                if !itemArray.isEmpty {
                    for i in startDay - 1 ... itemArray.count - 1
                    {if itemArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {if itemNextArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                if !itemArray.isEmpty {
                    if itemArray.last!.numUnitOfWork != 0 {totalMonthlyWorkDay += 1}
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< itemNextArray.count - 1
                    {if itemNextArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {if item.numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            }
        } else {    //  toDay < startDay
            switch startDay {
            case 2..<numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {if itemArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
                if !itemPreArray.isEmpty {
                    for i in startDay - 1 ... itemPreArray.count - 1
                    {if itemPreArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            case numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< itemArray.count - 1
                    {if itemArray[i].numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
                if !itemPreArray.isEmpty
                {if itemPreArray.last!.numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {if item.numUnitOfWork != 0 {totalMonthlyWorkDay += 1}}
                }
            }
        }
        
        strMonthlyWorkDay = String(totalMonthlyWorkDay)
        
    }
    
    
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func setMonthlySalalyOnDashboard() {
        
        let moneyUnitData = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        let taxRateFront = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateFront)
        let taxRateBack = UserDefaults.standard.integer(forKey: SettingsKeys.taxRateBack)
        let taxRateTotal = Double(taxRateFront) + (Double(taxRateBack) * 0.01)
        let taxRatePercentage = taxRateTotal * 0.01                 //  세율
        let afterTaxRatePercentage = (100 - taxRateTotal) * 0.01    //  세금공제 후 세율
        var monthlySalaly = Double()            //  세전 해당월 총 예상급여
        var monthlySalalyAfterTax = Double()    //  세후 해당월 총 예상급여
        var tax = Double()                      //  세금
        
        //  현재 날짜에 따른 DashBoard 맞춤 출력
        if toDay >= startDay {
            switch startDay {
            case 1: //  시작일이 1일 일경우 해당월만 계산
                if !itemArray.isEmpty {
                    for item in itemArray
                    {monthlySalaly += Double(item.numUnitOfWork * item.pay)}
                }
            case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                if !itemArray.isEmpty {
                    for i in startDay - 1 ... itemArray.count - 1
                    {monthlySalaly += Double(itemArray[i].numUnitOfWork * itemArray[i].pay)}
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {monthlySalaly += Double(itemNextArray[i].numUnitOfWork * itemNextArray[i].pay)}
                }
            case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                if !itemArray.isEmpty {
                    monthlySalaly += Double(itemArray.last!.numUnitOfWork * itemArray.last!.pay)
                }
                if !itemNextArray.isEmpty {
                    for i in 0 ..< itemNextArray.count - 1
                    {monthlySalaly += Double(itemNextArray[i].numUnitOfWork * itemNextArray[i].pay)}
                }
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {monthlySalaly += Double(item.numUnitOfWork * item.pay)}
                }
            }
        } else {    //  toDay < startDay
            switch startDay {
            case 2..<numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< startDay - 1
                    {monthlySalaly += Double(itemArray[i].numUnitOfWork * itemArray[i].pay)}
                }
                if !itemPreArray.isEmpty {
                    for i in startDay - 1 ... itemPreArray.count - 1
                    {monthlySalaly += Double(itemPreArray[i].numUnitOfWork * itemPreArray[i].pay)}
                }
            case numStartDayPickerItem:
                if !itemArray.isEmpty {
                    for i in 0 ..< itemArray.count - 1
                    {monthlySalaly += Double(itemArray[i].numUnitOfWork * itemArray[i].pay)}
                }
                if !itemPreArray.isEmpty
                {monthlySalaly += Double(itemPreArray.last!.numUnitOfWork * itemPreArray.last!.pay)}
            default:
                if !itemArray.isEmpty {
                    for item in itemArray
                    {monthlySalaly += Double(item.numUnitOfWork * item.pay)}
                }
            }
        }
        
        monthlySalalyAfterTax = monthlySalaly * afterTaxRatePercentage
        tax = monthlySalaly * taxRatePercentage
        
        //  화폐단위 만원:0 / 천원:1 / 원:2
        switch moneyUnitData {
        case 0:
            formatter.maximumFractionDigits = 4
            strMonthlySalaly = formatter.string(from: NSNumber(value: monthlySalaly))!
            strTax = formatter.string(from: NSNumber(value: tax))!
            strMonthlySalalyAfterTax = formatter.string(from: NSNumber(value: monthlySalalyAfterTax))!
        case 1:
            formatter.maximumFractionDigits = 3
            strMonthlySalaly = formatter.string(from: NSNumber(value: monthlySalaly))!
            strTax = formatter.string(from: NSNumber(value: tax))!
            strMonthlySalalyAfterTax = formatter.string(from: NSNumber(value: monthlySalalyAfterTax))!
            formatter.maximumFractionDigits = 4
        default:
            formatter.maximumFractionDigits = 0
            strMonthlySalaly = formatter.string(from: NSNumber(value: monthlySalaly))!
            strTax = formatter.string(from: NSNumber(value: tax))!
            strMonthlySalalyAfterTax = formatter.string(from: NSNumber(value: monthlySalalyAfterTax))!
            formatter.maximumFractionDigits = 4
        }
    }
    
    
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func setDaylyPayOnDashboard() {
        
        var daylyPay = Float()
        
        if itemArray.isEmpty {
            daylyPay = Float(UserDefaults.standard.object(forKey: SettingsKeys.basePay) as? String ?? "0")!
        } else {
            daylyPay = itemArray[selectedDay-1].pay
        }
        
        strDaylyPay = formatter.string(from: NSNumber(value: daylyPay))!
        if strDaylyPay.contains(".") {
            while (strDaylyPay.hasSuffix("0")) {
                strDaylyPay.removeLast() }
            if strDaylyPay.hasSuffix(".") {
                strDaylyPay.removeLast() }
        }
    }
    
    
    //MARK:  - PList 입출력
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!)
        } catch {
            print("Error encoding item array, \(error)")
        }
    }
    
    
    func loadItems() {
        itemArray.removeAll()
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
    
    
    func loadPreItems() {
        itemPreArray.removeAll()
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strPreYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {
                itemPreArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
    
    
    func loadNextItems() {
        itemNextArray.removeAll()
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strNextYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {
                itemNextArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
    
    
    func makeItemArray() {
        for _ in 1...daysInMonths[selectedMonth] {
            itemArray.append(Item())
        }
    }
    
    
    // status bar text color 흰색으로 바꿔주기
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK:  - Button Actions
    @IBAction func inputUnitOfWorkButtonAction(_ sender: UIButton) {
        loadItems()
        // 선택된 날짜 공수 입력화면에 출력
        unitOfWorkTemp = !itemArray.isEmpty ? String(itemArray[selectedDay-1].numUnitOfWork) : "0"
    }
    
    
    @IBAction func inputMemoButtonAction(_ sender: UIButton) {
        loadItems()
        // 선택된 날짜의 메모 입력화면에 출력
        memoTemp = !itemArray.isEmpty ? itemArray[selectedDay-1].memo : ""
    }
    
    
    @IBAction func inputPayButtonAction(_ sender: UIButton) {
        loadItems()
        //  선택된 달(날짜)의 단가를 입력화면에 출력
        payTemp = !itemArray.isEmpty ? String(itemArray[selectedDay-1].pay) : UserDefaults.standard.object(forKey: SettingsKeys.basePay) as? String ?? "0"
    }
    
    
    @IBAction func bannerBackButtonAction(_ sender: Any) {
        print("\n\n bannerBackButtonAction  \n\n")
    }
    
}


//MARK:  - Popup Delegate
extension MainViewController: PopupDelegate {
    
    func saveMemo(memo: String) {
        let newItem = Item()
        //loadItems()
        if itemArray.isEmpty {makeItemArray() }
        
        newItem.memo = memo
        newItem.strUnitOfWork = itemArray[selectedDay-1].strUnitOfWork
        newItem.numUnitOfWork = itemArray[selectedDay-1].numUnitOfWork
        newItem.pay = itemArray[selectedDay-1].pay
        
        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    func savePay(pay: String) {
        //loadItems()
        if itemArray.isEmpty {makeItemArray()}
        payTemp = pay == "" ? "0" : pay
        
        switch UserDefaults.standard.integer(forKey: SettingsKeys.unitOfWorkSettingPeriodIndex) {
        case 0: //  한달단위 저장
            for item in itemArray {
                item.pay = Float(payTemp)!
            }
        default:    //  하루단위 저장
            itemArray[selectedDay-1].pay = Float(payTemp)!
        }
        saveItems()
        
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
        
        setMonthlySalalyOnDashboard()
        setDaylyPayOnDashboard()
        dashBoardCollectionView.reloadData()
    }
    
    
    func saveUnitOfWork(unitOfWork: String) {
        let newItem = Item()
        //loadItems()
        if itemArray.isEmpty {makeItemArray()}
        unitOfWorkTemp = unitOfWork
        
        if unitOfWorkTemp.contains(".") {
            while (unitOfWorkTemp.hasSuffix("0")) {
                unitOfWorkTemp.removeLast() }
            if unitOfWorkTemp.hasSuffix(".") {
                unitOfWorkTemp.removeLast() }
        }
        
        switch unitOfWorkTemp {
        case "":
            newItem.strUnitOfWork = ""
            newItem.numUnitOfWork = 0
        case "0":
            newItem.strUnitOfWork = "휴무"
            newItem.numUnitOfWork = 0
        default:
            newItem.strUnitOfWork = unitOfWorkTemp
            newItem.numUnitOfWork = Float(unitOfWorkTemp)!
        }
        
        newItem.memo = itemArray[selectedDay-1].memo
        newItem.pay = itemArray[selectedDay-1].pay
        
        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
        
        setMonthlyUnitOfWorkOnDashboard()
        setMonthlyWorkDayOnDashboard()
        setMonthlySalalyOnDashboard()
        setDaylyPayOnDashboard()
        dashBoardCollectionView.reloadData()
    }
    
    
    func moveYearMonth(year: Int, month: Int, day: Int) {
        let date = createDate(year, month, day)
        let selectedVC = createCalendarViewController(date)
        pageVC.setViewControllers([selectedVC], direction: .forward, animated: false, completion: nil)
    }
    
    
    func moveYearMonth(year: Int, month: Int) {
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let date = createDate(year, month, day)
        let selectedVC = createCalendarViewController(date)
        pageVC.setViewControllers([selectedVC], direction: .forward, animated: false, completion: nil)
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        selectYearMonthDay(year: year, month: month, day: day)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
        strPreYearMonth = makeStrPreYearMonth(year: year, month: month)
        strNextYearMonth = makeStrNextYearMonth(year: year, month: month)
        loadItems()
        loadPreItems()
        loadNextItems()
        setMonthlyUnitOfWorkOnDashboard()
        setMonthlyWorkDayOnDashboard()
        setMonthlySalalyOnDashboard()
        setDaylyPayOnDashboard()
        dashBoardCollectionView.reloadData()
    }
}


//MARK:  - Calendar Delegate
extension MainViewController: CalendarDelegate {
    func selectYearMonthDay(year: Int, month: Int, day: Int) {
        selectedYear = year
        selectedMonth = month
        selectedDay = day
        print("선택된날짜 : \(year)년 \(month)월 \(day)일")
    }
    func callDisplayDaylyPay() {
        setDaylyPayOnDashboard()
        dashBoardCollectionView.reloadData()
    }
}


//MARK:  - DashBoard Controller
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setDashBoard() {
        
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 40.0, height: dashBoardCollectionView.frame.size.height - 4)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 0.4
        flowLayout.spacingMode = .fixed(spacing: 10)
        dashBoardCollectionView.collectionViewLayout = flowLayout
        
        dashBoardCurrentPage = 0
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let dashBoardPrePage = dashBoardCurrentPage
        let layout = self.dashBoardCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        dashBoardCurrentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        print("dashBoardCurrentPage = \(dashBoardCurrentPage)")
        if dashBoardPrePage != dashBoardCurrentPage {
            moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
        }
    }
    
    
    fileprivate var pageSize: CGSize {
        let layout = self.dashBoardCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("현재 선택된 indexPath.row 는 : \(indexPath.row)")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dashBoardCollectionView.dequeueReusableCell(withReuseIdentifier: "dashboardcell", for: indexPath) as! DashBoardCell
        let moneyUnitData = UserDefaults.standard.integer(forKey: SettingsKeys.moneyUnit)
        let paySystemIndex = UserDefaults.standard.integer(forKey: SettingsKeys.paySystemIndex)
        let beforeEndIndex = strYearMonth.index(strYearMonth.endIndex, offsetBy: -2)    //  뒤에서 두번째 문자열 (월의 앞자리 숫자)
        var previousMonth = strPreYearMonth
        var followingMonth = strNextYearMonth
        //  년도 4자리 제거 후 월 앞자리가 0 이면 지우고 아니면 월 앞자리 놔둔다.  ex) 202109 -> 년도 2021 과 월 앞자리 0 지움
        previousMonth[beforeEndIndex] == "0" ? previousMonth.removeFirst(5) : previousMonth.removeFirst(4)
        followingMonth[beforeEndIndex] == "0" ? followingMonth.removeFirst(5) : followingMonth.removeFirst(4)
        
        switch indexPath.row {
        case 0:
            if toDay >= startDay {
                switch startDay {
                case 1: //  시작일이 1일 일경우 해당월만 계산
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무"
                case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                    cell.descriptionLabel.text = "\(selectedMonth)/\(startDay) ~ \(followingMonth)/\(startDay-1) 근무"
                case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                    cell.descriptionLabel.text = "\(selectedMonth)/\(daysInMonths[selectedMonth]) ~ \(followingMonth)/\(daysInMonths[Int(followingMonth)!]-1) 근무"
                default:
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무"
                }
            } else {    //  toDay < startDay
                switch startDay {
                case 2..<numStartDayPickerItem:
                    cell.descriptionLabel.text = "\(previousMonth)/\(startDay) ~ \(selectedMonth)/\(startDay-1) 근무"
                case numStartDayPickerItem:
                    cell.descriptionLabel.text = "\(previousMonth)/\(daysInMonths[Int(previousMonth)!]) ~ \(selectedMonth)/\(daysInMonths[selectedMonth]-1) 근무"
                default:
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무"
                }
            }
            
            cell.contentLabel.text = strMonthlyUnitOfWork
            
            //  일급:0 / 시급:1
            switch paySystemIndex {
            case 0:
                cell.unitLabel.text = "공수"
            default:
                cell.unitLabel.text = "시간"
            }
            
            cell.backView.backgroundColor = #colorLiteral(red: 0, green: 0.7568627451, blue: 0.8431372549, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0, green: 0.662745098, blue: 0.7411764706, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_schedule")
            
        case 1:
            if toDay >= startDay {
                switch startDay {
                case 1: //  시작일이 1일 일경우 해당월만 계산
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무일"
                case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                    cell.descriptionLabel.text = "\(selectedMonth)/\(startDay) ~ \(followingMonth)/\(startDay-1) 근무일"
                case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                    cell.descriptionLabel.text = "\(selectedMonth)/\(daysInMonths[selectedMonth]) ~ \(followingMonth)/\(daysInMonths[Int(followingMonth)!]-1) 근무일"
                default:
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무일"
                }
            } else {    //  toDay < startDay
                switch startDay {
                case 2..<numStartDayPickerItem:
                    cell.descriptionLabel.text = "\(previousMonth)/\(startDay) ~ \(selectedMonth)/\(startDay-1) 근무일"
                case numStartDayPickerItem:
                    cell.descriptionLabel.text = "\(previousMonth)/\(daysInMonths[Int(previousMonth)!]) ~ \(selectedMonth)/\(daysInMonths[selectedMonth]-1) 근무일"
                default:
                    cell.descriptionLabel.text = "\(selectedMonth)월 근무일"
                }
            }
            
            cell.contentLabel.text = strMonthlyWorkDay
            cell.unitLabel.text = "일"
            
            cell.backView.backgroundColor = #colorLiteral(red: 0.9570236802, green: 0.5908840299, blue: 0.1887014806, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0.8799408078, green: 0.5285210013, blue: 0.1777598858, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_day_white_48")
            
        case 2:
            if toDay >= startDay {
                switch startDay {
                case 1: //  시작일이 1일 일경우 해당월만 계산
                    salaryDescription = "\(selectedMonth)월"
                case 2..<numStartDayPickerItem: //  시작일이 1일이 아니고 마지막날도 아닐경우
                    salaryDescription = "\(selectedMonth)/\(startDay) ~ \(followingMonth)/\(startDay-1)"
                case numStartDayPickerItem: //  시작일이 마지막 날일 경우
                    salaryDescription = "\(selectedMonth)/\(daysInMonths[selectedMonth]) ~ \(followingMonth)/\(daysInMonths[Int(followingMonth)!]-1)"
                default:
                    salaryDescription = "\(selectedMonth)월"
                }
            } else {    //  toDay < startDay
                switch startDay {
                case 2..<numStartDayPickerItem:
                    salaryDescription = "\(previousMonth)/\(startDay) ~ \(selectedMonth)/\(startDay-1)"
                case numStartDayPickerItem:
                    salaryDescription = "\(previousMonth)/\(daysInMonths[Int(previousMonth)!]) ~ \(selectedMonth)/\(daysInMonths[selectedMonth]-1)"
                default:
                    salaryDescription = "\(selectedMonth)월"
                }
            }
            
            cell.descriptionLabel.text = salaryDescription + " 예상급여"
            
            cell.contentLabel.text = strMonthlySalalyAfterTax
            cell.unitLabel.text = moneyUnitsDataSource[moneyUnitData]   // 만원 or 천원 or 원
            
            cell.backView.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0, blue: 0.3490196078, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0.8705882353, green: 0, blue: 0.3098039216, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_wallet")
            
        case 3:
            cell.contentLabel.text = strDaylyPay
            cell.descriptionLabel.text = "\(selectedMonth)월 \(selectedDay)일 단가"
            cell.unitLabel.text = moneyUnitsDataSource[moneyUnitData]   // 만원 or 천원 or 원
            cell.backView.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8039215686, blue: 0.2745098039, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0.4039215686, green: 0.7019607843, blue: 0.2431372549, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_won")
            
        default:
            break
        }
        cell.setDashBoardCollectionViewCellConstraints()
        return cell
    }
}

