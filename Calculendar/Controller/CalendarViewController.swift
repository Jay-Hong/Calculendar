import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet var calendarLineView: CalendarLineView!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPosition(date)
        
        //  초기 AdRemoval
        beginningAdRemoval = UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval)
        
        //  날짜 바뀌면 오늘표시 바꿔주기
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object:nil, queue: .main) { [weak self] _ in
            setToday()
            self?.calendarCollectionView.reloadData()
        }
    }
    
    //  viewWillLayoutSubviews() | viewDidLayoutSubviews()
    //  will be called whenever the bounds change in the view controller
    override func viewDidLayoutSubviews(){
        //  광고제거 구매 / 복원 직후 시에만 reloadData()
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) && !beginningAdRemoval {
            calendarCollectionView.reloadData()
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellWidth = collectionView.bounds.width /   7
        cellHeight = numberOfCells > 35 ? (collectionView.bounds.height / 6) : (collectionView.bounds.height / 5)
        
        //  Paging 시 라인이 두번씩 겹쳐그려지는 현상 해결위해 didDrawLines 사용
        if !didDrawLines {
            calendarLineView.setHeight(cellHeight)
            calendarLineView.setNeedsDisplay()
            didDrawLines = true
        }
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
                    cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                    
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
            }  else if month == 6 && dayCounter == 6 {  //  현출일
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
                if month == 2 && (dayCounter == 1 || dayCounter == 2 || dayCounter == 3) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 5 && dayCounter == 8 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 9 || dayCounter == 10 || dayCounter == 12) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2023 {
                if month == 1 && (dayCounter == 21 || dayCounter == 23 || dayCounter == 24) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 5 && dayCounter == 26 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 28 || dayCounter == 29 || dayCounter == 30) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            } else if year == 2024 {
                if month == 2 && (dayCounter == 9 || dayCounter == 10 || dayCounter == 12) {  //  설날
                   cell.dayLabel.textColor = UIColor.red
                }  else if month == 5 && dayCounter == 15 {  //  부처님오신날
                    cell.dayLabel.textColor = UIColor.red
                } else if month == 9 && (dayCounter == 16 || dayCounter == 17 || dayCounter == 18) {  //  추석
                    cell.dayLabel.textColor = UIColor.red
                }
            }
            
            if preIndexPath.isEmpty {   // 새로만들어진 캘린더일 경우
                if dayCounter == day {
                    cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
                    preIndexPath = indexPath
                } else {
                    cell.backgroundColor = UIColor.clear
                }
            } else {    // 날짜바뀌었을 때
                if indexPath == preIndexPath {
                    cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
                } else {
                    cell.backgroundColor = UIColor.clear
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayCounter = indexPath.row + 1 - firstDayPosition
        delegate?.selectYearMonthDay(year: year, month: month, day: dayCounter)
        delegate?.callDisplayDaylyPay()
        collectionView.cellForItem(at: preIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: firstDayIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: indexPath)?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
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
