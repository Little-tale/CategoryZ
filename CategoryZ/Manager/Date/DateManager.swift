//
//  DateManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/18/24.
//

import Foundation

final class DateManager {
    
    private 
    init() {}
    
    
    static let shared = DateManager()
    
    private
    let dateformatter = ISO8601DateFormatter()
    
    
    
    func differenceDateString(_ dateString: String) -> String{
        let now = Date()
        guard let contentDate = dateformatter.date(from: dateString) else {
            return ""
        }
        let calendar = Calendar.current
        
        dateformatter.formatOptions = [.withFullDate, .withFullTime, .withInternetDateTime]
        
        let diffComponents = Calendar
            .current
            .dateComponents(
                [.day, .hour, .minute],
                from:contentDate,
                to:now
            )
        guard let day = diffComponents.day,
              let hour = diffComponents.hour,
              let min = diffComponents.minute else {
                  return ""
              }
        if day == 0 {
            if hour == 0 {
                return "\(min)분 전"
            }
            return "\(hour)시간 전"
        }
        return "\(day)일 전"
    }
    
}
