//
//  Extension.swift
//  AutoTimetable
//
//  Created by Hwang insung on 8/2/25.
//

import Foundation

extension Date {
    func koreanWeekday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return String(formatter.string(from: self).prefix(1))
    }
}
