
import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var unitOfWorkLabel: UILabel!
    @IBOutlet weak var calendarCellUnitOfWorkLabelHeightConstrint: NSLayoutConstraint!
    
    func setCalendarCellUnitOfWorkLabelHeightConstrint() {
        
        switch UIScreen.main.bounds.size {
        //  Device Type 에 따라 Calendar Cell별(날짜별) 공수출력 레이블 높이 조정
        //  스토리보드 기본사이즈
        //  calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
        
        case iPhone13Pro, iPhone14, iPhoneSE3, iPhone8Plus, iPhoneSE1:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
        
        // iPhone15ProMax 에서 캘린더 셀 메모에서 5줄 출력 가능하도록 26 -> 22로 줄임
        case iPhone15ProMax, iPhone15Pro, iPhone14Plus, iPhone11:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
            
        default: break
        }
    }
}
