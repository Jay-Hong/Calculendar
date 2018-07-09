
import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var unitOfWorkLabel: UILabel!
    @IBOutlet weak var calendarCellUnitOfWorkLabelHeightConstrint: NSLayoutConstraint!
    
    func setCalendarCellUnitOfWorkLabelHeightConstrint() {
        //  Device Type 에 따라 Top Bar 조정
        switch UIScreen.main.bounds.size {
        case iPhoneSE:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 23
            
        case iPhone8:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 25
            
        case iPhone8Plus:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 28
            
        case iPhoneX:
            calendarCellUnitOfWorkLabelHeightConstrint.constant = 30
            
        default: break
        }
    }
}
