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
      
        print(dateString)
        var calendar = Calendar.current
        
        dateformatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        calendar.timeZone = .current
        
        guard let contentDate = dateformatter.date(from: dateString) else {
            print("날짜 변환 실패")
            return ""
        }
        
        let diffComponents = calendar
            .dateComponents(
                [.year, .month, .day, .hour, .minute],
                from:contentDate,
                to: .now
            )
        
        guard let year = diffComponents.year,
              let month = diffComponents.month,
              let day = diffComponents.day,
              let hour = diffComponents.hour,
              let min = diffComponents.minute else {
            print("날짜 계산 실패")
            return ""
        }
        
        return formattedDiff(year: year, month: month, day: day, hour: hour, min: min)
    }
    
    private func formattedDiff(year: Int, month: Int, day: Int, hour: Int, min: Int) -> String {
        if year > 0 {
            return "\(year)년 전"
        } else if month > 0 {
            return "\(month)달 전"
        } else if day > 0 {
            return "\(day)일 전"
        } else if hour > 0 {
            return "\(hour)시간 전"
        } else if min > 0 {
            return "\(min)분 전"
        } else {
            return "방금 전"
        }
    }

}
