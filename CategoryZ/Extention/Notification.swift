//
//  Notification.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation


extension Notification.Name {
    
    static let cantRefresh = Notification.Name(rawValue: "cantRefresh")
    
    static let selectedProductId = Notification.Name(rawValue: "selectedProductId")
    
    static let selectedMoreButton = Notification.Name(rawValue: "selectedMoreButton")
    
    static let moveToProfile = Notification.Name(rawValue: "moveToProfile")
    
    static let moveToSettingProfile = Notification.Name(rawValue: "moveToSettingProfile")
}
