
import Foundation

class Item: Codable {
    
    var strUnitOfWork : String = ""
    var numUnitOfWork : Float = 0.0
    var memo : String = ""
    var pay : Float = Float(UserDefaults.standard.object(forKey: "basePay") as? String ?? "0")!
}
