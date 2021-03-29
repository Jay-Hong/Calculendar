
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
        
        case iPhone12Pro, iPhonemini, iPhoneSE2, iPhone8Plus, iPhoneSE1:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
        
        case iPhone12Max, iPhone11Max:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 26
            
        default: break
        }
    }
}
