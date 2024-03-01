import UIKit
import SafariServices

class CalendarViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet var calendarLineView: CalendarLineView!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    var jobNewsButton = UIButton()    //  2021/10/12 스토어 바로가기 버튼 추가 -> 2023/05 채용정보 로 변경
    
    var delegate: CalendarDelegate?
    
    var date = Date()   // 전달인자
    var year = Int()
    var month = Int()
    var weekday = Int()
    var day = Int()
    var firstDayPosition = Int()
    var numberOfCells = Int()
    var firstDayIndexPath = IndexPath() // 캘린더 화면 전환시 원래 날짜 셋팅값 찾아갈 수 있도록 Main에서 쓰임
    var preIndexPath = IndexPath()
    var strYearMonth = String()
    
    var monthlyItemArray = [Item]()
    
    var beginningAdRemoval = Bool()     //  초기 AdRemoval  UserDefaults 값 저장
    var cellHeight = CGFloat()
    var cellWidth = CGFloat()
    
    //  Paging 시 두번씩 그려지는 현상으로 당월_5줄 라인이 전월_6줄 것으로 표기되는 현상 해결위해
    //  [e.g. 당월_5줄 -> 전월_6줄 (살짝 당겼다 놓음) -> 당월_5줄] => 당월_5줄 라인이 6줄로 표시되는 오류
    //  Line 은 한번만 그려줘도 bounds 변하면 알아서 따라 변한다 / Collectionview Cell 들은 다시 reload() 해줘야 함
    var didDrawLines = false
    
    let oddDaysColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.03)
    let evenDaysColor = UIColor.clear
    let selectedDayColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.3)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPosition(date)
        
        beginningAdRemoval = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval)     //  초기 AdRemoval
        
        //  날짜 바뀌면 오늘표시 바꿔주기
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object:nil, queue: .main) { [weak self] _ in
            setToday()
            self?.calendarCollectionView.reloadData()
        }
        
        addJobNewsButton()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        basicAnimation(imageView: jobNewsButton.imageView!) //  채용&뉴스 버튼 반짝이는 애니메이션
        advancedAnimation(imageView: jobNewsButton.imageView!)
    }
    
    
    //  viewWillLayoutSubviews() | viewDidLayoutSubviews()
    //  will be called whenever the bounds change in the view controller
    override func viewDidLayoutSubviews(){
        //  광고제거 구매 / 복원 직후 시에만 reloadData()
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) && !beginningAdRemoval {
            calendarCollectionView.reloadData()
        }
    }
    
    
    func addJobNewsButton() {
        //  jobInfoButton
        let jobInfoButtonWidth = self.view.bounds.width / 7
        self.view.addSubview(jobNewsButton)
        jobNewsButton.translatesAutoresizingMaskIntoConstraints = false
        
        jobNewsButton.widthAnchor.constraint(equalToConstant: jobInfoButtonWidth).isActive = true
        jobNewsButton.heightAnchor.constraint(equalToConstant: jobInfoButtonWidth).isActive = true
        
        jobNewsButton.setImage(UIImage(named: "job_news_image"), for: .normal)
        
        if numberOfCells == 35 {
            jobNewsButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
            jobNewsButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        } else {
            jobNewsButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            jobNewsButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        }
        
        jobNewsButton.layer.cornerRadius = 5
        jobNewsButton.layer.masksToBounds = true
        
        jobNewsButton.addTarget(self, action: #selector(jobInfoButtonAction), for: .touchUpInside)
        
//        basicAnimation(imageView: jobNewsButton.imageView!)
    }
    
    
    @objc func jobInfoButtonAction() {
        print("\nJob List Button is pressed!!\n")
        self.performSegue(withIdentifier: "toTabBarControllerSegue", sender: self)
//        print("storeButton is pressed!!\n")
//        let storeURL = NSURL(string: "https://smartstore.naver.com/like-mart")
//        let storeSafariView: SFSafariViewController = SFSafariViewController(url: storeURL! as URL)
//        self.present(storeSafariView, animated: true, completion: nil)
    }
    
    
    func setPosition(_ date: Date) {
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        weekday = calendar.component(.weekday , from: date)
        day = calendar.component(.day, from: date)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
        loadItems(strYearMonth)
        print("\(year)년\(month)월 달력 생성")
        
        if month == 2 || month == 1 || month == 3{  //  월 시작일이 마지막 날일경우 2월 마지막날 확인 필요
            daysInMonths[2] = (year%4 == 0 && year%100 != 0 || year%400 == 0) ? 29 : 28
        }
        let weekdayCounter = day % 7
        firstDayPosition = weekday - weekdayCounter
        firstDayPosition = firstDayPosition == 7 ? 0 : firstDayPosition
        firstDayPosition += firstDayPosition < 0 ? 7 : 0
        
        numberOfCells = firstDayPosition + daysInMonths[month]
    }
    
    func advancedAnimation(imageView: UIImageView) {
        let opacityKeyframe = CAKeyframeAnimation(keyPath: "opacity")
        opacityKeyframe.values = [1.0, 1.0, 0.0, 1.0, 1.0]
        opacityKeyframe.keyTimes = [0, 0.3, 0.5, 0.7, 1.0]
//        opacityKeyframe.duration = 2.3
//        opacityKeyframe.repeatCount = .infinity
        
        let scaleKeyFrame = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleKeyFrame.values = [1.0, 1.0, 0.5, 1.0, 1.0]
        scaleKeyFrame.keyTimes = [0, 0.3, 0.5, 0.7, 1.0]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityKeyframe, scaleKeyFrame]
        animationGroup.duration = 2.2
        animationGroup.repeatCount = Float.infinity
        animationGroup.fillMode = .forwards             // 애니메이션 완료 후 상태 유지
        animationGroup.isRemovedOnCompletion = false    // 애니메이션 완료 후 제거하지 않음
        
        imageView.layer.add(animationGroup, forKey: "advancedAnimationGroup")

//        imageView.layer.removeAnimation(forKey: "myAnimationGroup")       //  애니메이션 삭제 방법
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellWidth = collectionView.bounds.width /   7
        cellHeight = numberOfCells > 35 ? (collectionView.bounds.height / 6) : (collectionView.bounds.height / 5)
        
        //  Paging 시 라인이 두번씩 겹쳐그려지는 현상 해결위해 didDrawLines 사용
//        if !didDrawLines {
//            calendarLineView.setHeight(cellHeight)
//            calendarLineView.setNeedsDisplay()
//            didDrawLines = true
//        }
        return numberOfCells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell

        let dayCounter = indexPath.row + 1 - firstDayPosition
        
        cell.dayLabel.text = " \(dayCounter)"
        
        if dayCounter < 1 {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        if dayCounter == 1 {
            firstDayIndexPath = indexPath
        }
        
        // 화면에 데이터 뿌려주기
        if indexPath.row >= firstDayPosition {

            let itemArrayIndex = indexPath.row - firstDayPosition

            if monthlyItemArray.isEmpty {  // itemArray 가 비어 있을 경우
                cell.unitOfWorkLabel.isHidden = true
                cell.memoLabel.isHidden = true
            } else {    // itemArray에 값이 있고
                if monthlyItemArray[itemArrayIndex].strUnitOfWork == "" ||
                    monthlyItemArray[itemArrayIndex].strUnitOfWork == "0" {  // 공수가 비었을경우
                    cell.unitOfWorkLabel.isHidden = true
                } else {    // 공수에 값이 있을경우
                    cell.unitOfWorkLabel.isHidden = false
                    
                    switch dashBoardCurrentPage {
                    case 0:
                        cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                    case 1:
                        cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                    case 2:
                        cell.unitOfWorkLabel.font = cell.unitOfWorkLabel.font.withSize(12)
                        cell.unitOfWorkLabel.adjustsFontSizeToFitWidth = true
                        cell.unitOfWorkLabel.text = formatter.string(from: NSNumber(value: monthlyItemArray[itemArrayIndex].numUnitOfWork * monthlyItemArray[itemArrayIndex].pay))
                    case 3:
                        cell.unitOfWorkLabel.font = cell.unitOfWorkLabel.font.withSize(12)
                        cell.unitOfWorkLabel.adjustsFontSizeToFitWidth = true
                        cell.unitOfWorkLabel.text = formatter.string(from: NSNumber(value: monthlyItemArray[itemArrayIndex].pay * (monthlyItemArray[itemArrayIndex].numUnitOfWork == 0 ? 0 : 1 )))
                    default:
                        cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                    }
                    
//                    cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                    
                    let numUnitOfWork = monthlyItemArray[itemArrayIndex].numUnitOfWork
                    switch numUnitOfWork {
                    case 0:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.631372549, green: 0.6869744353, blue: 0.699911484, alpha: 1)
                    case 0.0001 ..< 1:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.3800676739, green: 0.5721034273, blue: 1, alpha: 1)
                    case 1 ..< 1.5:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.1841003787, green: 0.7484605911, blue: 0.06411089568, alpha: 1)
                    case 1.5 ..< 2:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.977601601, green: 0.7735045688, blue: 0.1866027329, alpha: 1)
                    case 2 ..< 2.5:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.4626982859, blue: 0.3224007863, alpha: 1)
                    case 2.5 ..< 3:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.5514207035, green: 0.3453891092, blue: 0.9958749898, alpha: 1)
                    case 3 ..< 4:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.4097951526, blue: 0.834882776, alpha: 1)
                    case 4 ..< 5:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.1601935674, green: 0.4833306365, blue: 1, alpha: 1)
                    case 5 ..< 6:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.9470828202, green: 0.7243243667, blue: 0.006854730531, alpha: 1)
                    case 6 ..< 7:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.1315182108, blue: 0.8058782186, alpha: 1)
                    case 7 ..< 8:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.2863476879, blue: 0.06880125082, alpha: 1)
                    case 8 ..< 9:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.1841003787, green: 0.7484605911, blue: 0.06411089568, alpha: 1)
                    case 9 ..< 10:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.977601601, green: 0.7735045688, blue: 0.1866027329, alpha: 1)
                    case 10 ..< 11:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.977601601, green: 0.7735045688, blue: 0.1866027329, alpha: 1)
                    case 11 ..< 12:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.4626982859, blue: 0.3224007863, alpha: 1)
                    case 12 ..< 13:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.4097951526, blue: 0.834882776, alpha: 1)
                    case 13 ..< 14:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.2140718176, blue: 0.7878490385, alpha: 1)
                    case 14 ..< 15:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.3743945629, blue: 0.1582283342, alpha: 1)
                    case 15 ..< 16:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.2206499482, blue: 0.04487571603, alpha: 1)
                    case 16 ..< 17:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    default:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.200000003, green: 0.200000003, blue: 0.200000003, alpha: 1)
                    }
                    cell.setCalendarCellUnitOfWorkLabelHeightConstrint()
                    cell.unitOfWorkLabel.layer.cornerRadius = 2
                    cell.unitOfWorkLabel.layer.masksToBounds = true
                }
                if monthlyItemArray[itemArrayIndex].memo == "" {   // 메모가 비었을 경우
                    cell.memoLabel.isHidden = true
                } else {    //  메모값이 있을경우
                    cell.memoLabel.isHidden = false
                    cell.memoLabel.text = monthlyItemArray[itemArrayIndex].memo
                }
            }
            
            if (year == toYear && month == toMonth && dayCounter == toDay) {
                firstDayIndexPath = indexPath
                cell.dayLabel.backgroundColor = #colorLiteral(red: 1, green: 0.08361979167, blue: 0, alpha: 0.6451994243)
                cell.dayLabel.font = UIFont.boldSystemFont(ofSize: cell.dayLabel.font.pointSize)
                cell.dayLabel.textColor = UIColor.white
            } else {
                cell.dayLabel.backgroundColor = UIColor.clear
                cell.dayLabel.font = UIFont.systemFont(ofSize: cell.dayLabel.font.pointSize)
                
                switch indexPath.row {  // 주말 날짜색 설정
                case 0,7,14,21,28,35,42:
                    if dayCounter > 0 {
                        cell.dayLabel.textColor = UIColor.red }
                case 6,13,20,27,34,41:
                    if dayCounter > 0 {
                        cell.dayLabel.textColor = UIColor.blue }
                default:
                    cell.dayLabel.textColor = UIColor.black
                }
            }
            
            //  휴일 빨간색 표기
            if month == 1 && dayCounter == 1 {  //  새해
                cell.dayLabel.textColor = UIColor.red
            } else if month == 3 && dayCounter == 1 {  //  3.1절
                cell.dayLabel.textColor = UIColor.red
            } else if month == 5 && dayCounter == 5 {  //  어린이날
                cell.dayLabel.textColor = UIColor.red
            }  else if month == 6 && dayCounter == 6 {  //  현충일
                cell.dayLabel.textColor = UIColor.red
            } else if month == 8 && dayCounter == 15 {  //  광복절
                cell.dayLabel.textColor = UIColor.red
            } else if month == 10 && dayCounter == 3 {  //  개천절
                cell.dayLabel.textColor = UIColor.red
            } else if month == 10 && dayCounter == 9 {  //  한글날
                cell.dayLabel.textColor = UIColor.red
            } else if month == 12 && dayCounter == 25 {  //  크리스마스
                cell.dayLabel.textColor = UIColor.red
            }
            
            if year == 2020 {
                if month == 1 && (dayCounter == 24 || dayCounter == 25 || dayCounter == 27) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 4 && dayCounter == 30 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if (month == 9 && dayCounter == 30) || (month == 10 && (dayCounter == 1 || dayCounter == 2 || dayCounter == 3)) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2021 {
                if month == 2 && (dayCounter == 11 || dayCounter == 12 || dayCounter == 13) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 5 && dayCounter == 19 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 20 || dayCounter == 21 || dayCounter == 22) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2022 {
                if month == 1 && (dayCounter == 31) {   //  설날
                    cell.dayLabel.textColor = UIColor.red
                }
                if month == 2 && (dayCounter == 1 || dayCounter == 2) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                } else if month == 3 && dayCounter == 9 {  //  대통령선거
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 5 && dayCounter == 8 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 6 && dayCounter == 1 {  //  지방선거
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 9 || dayCounter == 10 || dayCounter == 12) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 10 && dayCounter == 10 {  //  한글날 대체공휴일
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2023 {
                if month == 1 && (dayCounter == 21 || dayCounter == 23 || dayCounter == 24) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 5 && dayCounter == 27 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 28 || dayCounter == 29 || dayCounter == 30) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2024 {
                if month == 2 && (dayCounter == 9 || dayCounter == 10 || dayCounter == 12) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                } else if month == 4 && dayCounter == 10 {  //  국회의원 선거
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 5 && dayCounter == 6 {  //  어린이날 대체휴일
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 5 && dayCounter == 15 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 16 || dayCounter == 17 || dayCounter == 18) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2025 {
                if month == 1 && (dayCounter == 28 || dayCounter == 29 || dayCounter == 30) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                } else if month == 3 && dayCounter == 3 {  //  3.1절 대체공휴일
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 5 && dayCounter == 6 {  //  어린이날, 부처님오신날 대체 공휴일
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 5 && dayCounter == 15 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 10 && (dayCounter == 6 || dayCounter == 7 || dayCounter == 8) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2026 {
                if month == 2 && (dayCounter == 16 || dayCounter == 17 || dayCounter == 18) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                } else if month == 3 && dayCounter == 2 {  //  3.1절 대체공휴일
                    cell.dayLabel.textColor = UIColor.red
//                } else if month == 5 && dayCounter == 6 {  //  부처님오신날 대체 공휴일
//                    cell.dayLabel.textColor = UIColor.red
                } else if month == 8 && dayCounter == 17 {  //  광복절 대체공휴일
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 24 || dayCounter == 25 || dayCounter == 26) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 10 && dayCounter == 5 {  //  개천절 대체공휴일
                    cell.dayLabel.textColor = UIColor.red
                }
            }
            
            if preIndexPath.isEmpty {   // 새로만들어진 캘린더일 경우
                if dayCounter == day {
                    cell.backgroundColor = selectedDayColor
                    preIndexPath = indexPath
                } else {
//                    cell.backgroundColor = UIColor.clear
                    if dayCounter % 2 == 1 {
                        cell.backgroundColor = oddDaysColor
                    } else {
                        cell.backgroundColor = evenDaysColor
                    }
                }
            } else {    // 날짜바뀌었을 때
                if indexPath == preIndexPath {
                    cell.backgroundColor = selectedDayColor
                } else {
//                    cell.backgroundColor = UIColor.clear
                    if dayCounter % 2 == 1 {
                        cell.backgroundColor = oddDaysColor
                    } else {
                        cell.backgroundColor = evenDaysColor
                    }
                }
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayCounter = indexPath.row + 1 - firstDayPosition
        delegate?.selectYearMonthDay(year: year, month: month, day: dayCounter)
        delegate?.callDisplayDaylyPay()
        
        print(firstDayIndexPath.row)
        print(firstDayPosition)
        
        if firstDayPosition % 2 == firstDayIndexPath.row % 2 {
            collectionView.cellForItem(at: firstDayIndexPath)?.backgroundColor = oddDaysColor
        } else {
            collectionView.cellForItem(at: firstDayIndexPath)?.backgroundColor = evenDaysColor
        }
        
        if firstDayPosition % 2 == preIndexPath.row % 2 {
            collectionView.cellForItem(at: preIndexPath)?.backgroundColor = oddDaysColor
        } else {
            collectionView.cellForItem(at: preIndexPath)?.backgroundColor = evenDaysColor
        }
        
//        collectionView.cellForItem(at: preIndexPath)?.backgroundColor = UIColor.clear
        
        
        collectionView.cellForItem(at: indexPath)?.backgroundColor = selectedDayColor
        preIndexPath = indexPath
    }
    
    func loadItems(_ strYearMonth: String) {
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {monthlyItemArray = try decoder.decode([Item].self, from: data)
            } catch {print("Error decoding item array, \(error)")
            }
        }
    }
    
}


extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    //  collectionview 크기에 맞추어 Cell 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        print("\nminimumInteritemSpacingForSectionAt")
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        print("\nminimumLineSpacingForSectionAt"\n)
//        return 0
//    }
}
