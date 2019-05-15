import UIKit
import CoreBluetooth

struct Constants {

    static let kAvatarImagePrefix = "avatar"
    
    static let colors = [UIColor(red: 255/255, green: 175/255, blue:209/255, alpha: 1.0),
                         UIColor(red: 114/255, green: 119/255, blue:245/255, alpha: 1.0),
                         UIColor(red: 175/255, green: 183/255, blue:63/255, alpha: 1.0),
                         UIColor(red: 182/255, green: 85/255, blue:16/255, alpha: 1.0),
                         UIColor(red: 88/255, green: 221/255, blue:176/255, alpha: 1.0),
                         UIColor(red: 241/255, green: 169/255, blue:111/255, alpha: 1.0),
                         UIColor(red: 108/255, green: 137/255, blue:232/255, alpha: 1.0),
                         UIColor(red: 116/255, green: 177/255, blue:28/255, alpha: 1.0),
                         UIColor(red: 76/255, green: 150/255, blue:145/255, alpha: 1.0)]
    
    static let SERVICE_UUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5")
    static let RX_UUID = CBUUID(string: "3B66D024-2336-4F22-A980-8095F4898C42")
    static let RX_PROPERTIES: CBCharacteristicProperties = .write
    static let RX_PERMISSIONS: CBAttributePermissions = .writeable
    
}
