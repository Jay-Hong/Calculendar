
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
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
            
        case iPhone8:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 22
            
        case iPhone8Plus, iPhoneXS:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 24
            
        case iPhoneXR:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 26
            
        case iPhoneXSMAX:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 28
            
        default: break
        }
    }
}
