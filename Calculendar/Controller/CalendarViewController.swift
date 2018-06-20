
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
    var firstDayIndexPath = IndexPath()
    var preIndexPath = IndexPath()
    var strYearMonth = String()
    
    var monthlyItemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPosition(date)
    }

    func setPosition(_ date: Date) {
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        weekday = calendar.component(.weekday , from: date)
        day = calendar.component(.day, from: date)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
        loadItems(strYearMonth)
        print("\(year)년\(month)월 달력 생성")
        
        if month == 2 {
            daysInMonths[2] = (year%4 == 0 && year%100 != 0 || year%400 == 0) ? 29 : 28
        }
        let weekdayCounter = day % 7
        firstDayPosition = weekday - weekdayCounter
        firstDayPosition = firstDayPosition == 7 ? 0 : firstDayPosition
        firstDayPosition += firstDayPosition < 0 ? 7 : 0
        
        numberOfCells = firstDayPosition + daysInMonths[month]
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell

        let dayCounter = indexPath.row + 1 - firstDayPosition
        
        cell.dayLabel.text = " \(dayCounter)"
        
        if dayCounter < 1 {
            cell.isHidden = true
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
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.6312795164, green: 0.6869744353, blue: 0.699911484, alpha: 1)
                    case 0.0001 ... 0.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.494656867, green: 0.6382678452, blue: 1, alpha: 1)
                    case 1 ... 1.4999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.805794555, blue: 0.2924747302, alpha: 1)
                    case 1.5 ... 1.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.5099442633, blue: 0.8664344656, alpha: 1)
                    case 2 ... 2.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.5480514099, blue: 0.443981049, alpha: 1)
                    case 3 ... 3.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.3594583542, green: 0.8026477833, blue: 0.2852157565, alpha: 1)
                    case 4 ... 4.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.1601935674, green: 0.4833306365, blue: 1, alpha: 1)
                    case 5 ... 5.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.9470828202, green: 0.7243243667, blue: 0.006854730531, alpha: 1)
                    case 6 ... 6.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.8951854988, green: 0.1315182108, blue: 0.8058782186, alpha: 1)
                    case 7 ... 7.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 1, green: 0.2863476879, blue: 0.06880125082, alpha: 1)
                    case 8 ... 8.9999:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.098727484, green: 0.8026477833, blue: 0, alpha: 1)
                    default:
                        cell.unitOfWorkLabel.backgroundColor = #colorLiteral(red: 0.2385891318, green: 0.2385891318, blue: 0.2385891318, alpha: 1)
                    }
                }
                if monthlyItemArray[itemArrayIndex].memo == "" {   // 메모가 비었을 경우
                    cell.memoLabel.isHidden = true
                } else {    //  메모값이 있을경우
                    cell.memoLabel.isHidden = false
                    cell.memoLabel.text = monthlyItemArray[itemArrayIndex].memo
                }
            }
            
            switch indexPath.row {  // 주말 날짜색 설정
            case 0,7,14,21,28,35,42:
                if dayCounter > 0 {
                    cell.dayLabel.textColor = UIColor.red }
            case 6,13,20,27,34,41:
                if dayCounter > 0 {
                    cell.dayLabel.textColor = UIColor.blue }
            default: break
            }
            
            if (year == toYear && month == toMonth && dayCounter == toDay) {
                firstDayIndexPath = indexPath
                cell.dayLabel.backgroundColor = #colorLiteral(red: 1, green: 0.08361979167, blue: 0, alpha: 0.6451994243)
                cell.dayLabel.textColor = UIColor.white
            }
            
            if dayCounter == day {
                cell.backgroundColor = #colorLiteral(red: 0.9011314655, green: 0.9011314655, blue: 0.9011314655, alpha: 1)
                preIndexPath = indexPath
            }
            
            cell.unitOfWorkLabel.layer.cornerRadius = 9
            cell.unitOfWorkLabel.layer.masksToBounds = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayCounter = indexPath.row + 1 - firstDayPosition
//        print("\(year)년 \(month)월 \(dayCounter)일 이 선택 됨")
        delegate?.selectYearMonthDay(year: year, month: month, day: dayCounter)
        collectionView.cellForItem(at: preIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: firstDayIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: indexPath)?.backgroundColor = #colorLiteral(red: 0.9011314655, green: 0.9011314655, blue: 0.9011314655, alpha: 1)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        
        var height = CGFloat()
        height = numberOfCells > 35 ? (collectionView.frame.height / 6) : (collectionView.frame.height / 5)
        
        //  셀 높이와 선높이 맞춰 그려주기
        calendarLineView.setHeight(height)
        calendarLineView.setNeedsDisplay()
        
        return CGSize(width: width, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
}






