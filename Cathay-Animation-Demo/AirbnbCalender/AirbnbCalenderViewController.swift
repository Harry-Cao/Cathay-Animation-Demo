//
//  AirbnbCalenderViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2025/2/9.
//

import UIKit
import HorizonCalendar

final class AirbnbCalenderViewController: UIViewController {
    let calendarView = CalendarView(initialContent: makeContent())

    private static func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current

        let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
        let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
        .dayItemProvider { day in
            DayLabel.calendarItemModel(
              invariantViewProperties: .init(
                font: .systemFont(ofSize: 18),
                textColor: .label,
                borderColor: .systemBlue),
              content: .init(day: day))
        }
        .verticalDayMargin(8)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

struct DayLabel: CalendarItemViewRepresentable {
    
    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
        let font: UIFont
        let textColor: UIColor
        let borderColor: UIColor
    }
    
    /// Properties that will vary depending on the particular date being displayed.
    struct Content: Equatable {
        let day: DayComponents
    }
    
    static func makeView(
        withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
    {
        let label = UILabel()
        
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = 1
        label.layer.borderColor = invariantViewProperties.borderColor.cgColor
        label.font = invariantViewProperties.font
        label.textColor = invariantViewProperties.textColor
        
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        
        return label
    }
    
    static func setContent(_ content: Content, on view: UILabel) {
        view.text = "\(content.day.day)"
    }
    
}
