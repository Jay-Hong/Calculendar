import Foundation
import MessageUI

var daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]   //  0월은 존재X
let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
var today = Date()  // 오늘
let calendar = Calendar.current
var toDay = Int()   // 오늘 날짜
var toMonth = Int() // 오늘 달
var toYear = Int()  // 오늘 년도
//let toWeekday = calendar.component(.weekday , from: today)    // 한 주의시작을 월요일로 하려면 이 값에 -1 해준다

// 화페단위
let moneyUnitsDataSource = ["만원" ,"천원" ,"원"]
//  화폐 셋자리마다 , 찍어주기위한 formatter
let formatter = NumberFormatter()
//  시작일 Item 갯수
let numStartDayPickerItem = 28  // 1~27, 마지막날

let iPhoneXS = CGSize(width: 375, height: 812)
let iPhoneXSMAX = CGSize(width: 414, height: 896)
let iPhoneXR = CGSize(width: 413, height: 896)
let iPhone8  = CGSize(width: 375, height: 667)
let iPhone8Plus = CGSize(width: 414, height: 736)
let iPhoneSE = CGSize(width: 320, height: 568)

let iOSVersion = UIDevice.current.systemVersion
let iPhoneDevice = UIDevice.current.modelName
let appVersion : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")

func setToday() {
    today = Date()                                      // 오늘
    toDay = calendar.component(.day , from: today)      // 오늘 날짜
    toMonth = calendar.component(.month , from: today)  // 오늘 달
    toYear = calendar.component(.year, from: today)     // 오늘 년도
}

func makeStrPreYearMonth(year: Int, month: Int) -> String {
    var newMonth = month
    var newYear = year
    
    switch month {
    case 1:
        newMonth = 12
        newYear -= 1
    default:
        newMonth -= 1
    }
    return "\(newYear)\(makeTwoDigitString(newMonth))"
}

func makeStrNextYearMonth(year: Int, month: Int) -> String {
    var newMonth = month
    var newYear = year
    
    switch month {
    case 12:
        newMonth = 1
        newYear += 1
    default:
        newMonth += 1
    }
    return "\(newYear)\(makeTwoDigitString(newMonth))"
}

func makeTwoDigitString(_ number : Int) -> String {
    switch number {
    case 1...9:
        return "0\(number)"
    default:
        return"\(number)"
    }
}

struct SettingsKeys {
    
    static let basePay = "basePay"                  // 기본단가
    static let moneyUnit = "moneyUnit"              // 화페단위
    static let taxRateFront = "taxRateFront"        // 세율 앞자리
    static let taxRateBack = "taxRateBack"          // 세율 뒷자리
    static let startDay = "startDay"                // 월 기준일
    static let paySystemIndex = "paySystemIndex"    // 급여형태
    static let unitOfWorkSettingPeriodIndex = "unitOfWorkSettingPeriodIndex"    // 단가변경 기간(한달 or 하루)
    static let AdRemoval = "AdRemoval"              // 광고제거 구매 여부
    static let firstScreenAd = "firstScreenAd"
}

extension Notification.Name {
    static let didSaveBasePay = Notification.Name("didSaveBasePay")
    static let didChangeMoneyUnit = Notification.Name("didChangeMoneyUnit")
    static let didSaveTaxRate = Notification.Name("didSaveTaxRate")
    static let didSaveStartDay = Notification.Name("didSaveStartDay")
    static let didTogglePaySystem = Notification.Name("didTogglePaySystem")
    static let didPurchaseAdRemoval = Notification.Name("didPurchaseAdRemoval")
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4":                              return "iPhone XS Max"
        case "iPhone11,6":                              return "iPhone XS Max China"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
