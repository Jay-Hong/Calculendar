import Foundation

protocol PopupDelegate {
    func moveYearMonth(year: Int, month: Int)
    func moveYearMonth(year: Int, month: Int, day: Int)
    func saveUnitOfWork(unitOfWork: String)
    func saveMemo(memo: String)
    func savePay(pay: String)
}
