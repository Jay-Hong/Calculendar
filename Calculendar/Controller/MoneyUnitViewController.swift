import UIKit

class MoneyUnitViewController: UITableViewController {
 
    var moneyUnit = Int()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moneyUnitsDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyUnitCell", for: indexPath)
        cell.textLabel?.text = moneyUnitsDataSource[indexPath.row]
        cell.accessoryType = indexPath.row == moneyUnit ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 이전 체크 제거
        let preIndexPath = IndexPath(row: moneyUnit, section: indexPath.section)
        let preCell = tableView.cellForRow(at: preIndexPath)
        preCell?.accessoryType = .none
        
        // 새로 선택된 화폐단위 체크
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .checkmark
        moneyUnit = indexPath.row
        
        performSegue(withIdentifier: "unwindFromMoneyUnitVC", sender: newCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromMoneyUnitVC" {
            if let setting2VC = segue.destination as? Setting2ViewController {
                setting2VC.moneyUnit = moneyUnit
            }
        }
    }
    
}
