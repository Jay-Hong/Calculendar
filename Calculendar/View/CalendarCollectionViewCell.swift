
import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var unitOfWorkLabel: UILabel!
    @IBOutlet weak var calendarCellUnitOfWorkLabelHeightConstrint: NSLayoutConstraint!
    
    func setCalendarCellUnitOfWorkLabelHeightConstrint() {
        //  Device Type 에 따라 공수(시간)출력 레이블 높이 조정
        switch UIScreen.main.bounds.size {
        case iPhoneSE:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 23
            
        case iPhone8:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 25
            
        case iPhone8Plus:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 28
            
        case iPhoneXS, iPhoneXSMAX, iPhoneXR:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 30
            
        default: break
        }
    }
}
