//
//  EducationGuideModel.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 25.05.2022.
//
import UIKit

struct EducationGuideModel {
    var title: String
    var date: String
    var time: String

    private var separator = " • "

    var copyright: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let string = date + separator + time
        return .init(string: string, attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14) as Any,
            .foregroundColor: Colors.black
        ])
    }

    init(title: String, date: String, time: String) {
        self.title = title
        self.date = date
        self.time = time
    }

    func getTimeAndDate() -> String {
        print(date + separator + time)
        return date + separator + time
    }
}
