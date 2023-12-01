import Foundation
import MessageUI
import FirebaseRemoteConfig
import FirebaseDatabase

var remoteConfig = RemoteConfig.remoteConfig()
let databaseReference = Database.database().reference()

var imageSize = CGSize()    //  채용정보 관련 사진 사이즈

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

let iPhone15ProMax = CGSize(width: 430, height: 932)     //  iPhone15 Plus
let iPhone14Plus = CGSize(width: 428, height:926)        //  iPhone12Max
let iPhone11 = CGSize(width: 414, height: 896)           //  iPhone11ProMAX , iPhoneXS Max , iPhoneXR
let iPhone8Plus = CGSize(width: 414, height: 736)
let iPhone15Pro = CGSize(width: 393, height: 852)        //  iPhone15
let iPhone13Pro = CGSize(width: 390, height: 844)        //  iPhone12 , iPhone12Pro
let iPhone14 = CGSize(width: 375, height: 812)           //  iPhoneXS , iPhoneX , iPhone11 Pro , iPhonemini
let iPhoneSE3  = CGSize(width: 375, height: 667)         //  iPhone8 , iPhone7 , iPhone6s , iPhoneSE2
let iPhoneSE1 = CGSize(width: 320, height: 568)

let iOSVersion = UIDevice.current.systemVersion
let iPhoneDevice = UIDevice.current.modelName
let appVersion : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")

var dashBoardCurrentPage: Int = 0

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

struct RemoteConfigKeys {
    static let jobInfoJSON = "jobInfoJSON"
    static let removeAD_Price = "removeAD_Price"
    static let selectJobDB = "selectJobDB"
    static let applyByMessage = "applyByMessage"
    static let jobInfoMail = "jobInfoMail"
    static let jobListAD = "jobListAD"
    static let jobDetailAD = "jobDetailAD"
    static let jobDB_GithubURL = "jobDB_GithubURL"
    static let newsDB_GithubURL = "newsDB_GithubURL"
    static let newsListAdIndex = "newsListAdIndex"
    static let newsListBigAdIndex = "newsListBigAdIndex"
    static let newsListImageWords = "newsListImageWords"
    static let newsListNextBigCell = "newsListNextBigCell"
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
    static let firstLaunchTime = "firstLaunchTime"  // 앱 새로 설치 후 첫 런치한 기준시간   (업데이트 설치는 UserDefaults값 유지)
    
    static let firstScreenAd = "firstScreenAd"      //  [Deprecated] 첫화면 광고 여부, AdMob 페이지 에서 하루 한번만 첫화면 전면 광고 설정 가능
}

extension Notification.Name {
    static let didSaveBasePay = Notification.Name("didSaveBasePay")
    static let didChangeMoneyUnit = Notification.Name("didChangeMoneyUnit")
    static let didSaveTaxRate = Notification.Name("didSaveTaxRate")
    static let didSaveStartDay = Notification.Name("didSaveStartDay")
    static let didTogglePaySystem = Notification.Name("didTogglePaySystem")
    static let didPurchaseAdRemoval = Notification.Name("didPurchaseAdRemoval")
    static let didRestoreOperation = Notification.Name("didRestoreOperation")
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
        case "iPod5,1":                                       return "iPod touch (5th generation)"
        case "iPod7,1":                                       return "iPod touch (6th generation)"
        case "iPod9,1":                                       return "iPod touch (7th generation)"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
        case "iPhone4,1":                                     return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
        case "iPhone7,2":                                     return "iPhone 6"
        case "iPhone7,1":                                     return "iPhone 6 Plus"
        case "iPhone8,1":                                     return "iPhone 6s"
        case "iPhone8,2":                                     return "iPhone 6s Plus"
        case "iPhone8,4":                                     return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
        case "iPhone11,2":                                    return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
        case "iPhone11,8":                                    return "iPhone XR"
        case "iPhone12,1":                                    return "iPhone 11"
        case "iPhone12,3":                                    return "iPhone 11 Pro"
        case "iPhone12,5":                                    return "iPhone 11 Pro Max"
        case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
        case "iPhone13,1":                                    return "iPhone 12 mini"
        case "iPhone13,2":                                    return "iPhone 12"
        case "iPhone13,3":                                    return "iPhone 12 Pro"
        case "iPhone13,4":                                    return "iPhone 12 Pro Max"
        case "iPhone14,4":                                    return "iPhone 13 mini"
        case "iPhone14,5":                                    return "iPhone 13"
        case "iPhone14,2":                                    return "iPhone 13 Pro"
        case "iPhone14,3":                                    return "iPhone 13 Pro Max"
        case "iPhone14,7":                                    return "iPhone 14"
        case "iPhone14,8":                                    return "iPhone 14 Plus"
        case "iPhone15,2":                                    return "iPhone 14 Pro"
        case "iPhone15,3":                                    return "iPhone 14 Pro Max"
        case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
        case "iPhone15,4":                                    return "iPhone 15"
        case "iPhone15,5":                                    return "iPhone 15 Plus"
        case "iPhone16,1":                                    return "iPhone 15 Pro"
        case "iPhone16,2":                                    return "iPhone 15 Pro Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
        case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
        case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
        case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
        case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
        case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
        case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
        case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
        case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
        case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            
        case "AppleTV5,3":                                    return "Apple TV"
        case "AppleTV6,2":                                    return "Apple TV 4K"
        case "AudioAccessory1,1":                             return "HomePod"
        case "AudioAccessory5,1":                             return "HomePod mini"
        case "i386", "x86_64", "arm64":                       return "Simulator"
        default:                                              return identifier
        }
    }
}
