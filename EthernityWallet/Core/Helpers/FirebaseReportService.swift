//
//  FirebaseReportService.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 03.02.2021.
//

import Firebase

extension AlphaWallet {
    class FirebaseReportService: ReportService {
        private let options: FirebaseOptions
        // NOTE: failable initializer allow us easily configure with different plist files for different configurations of project
        init?(contents: String? = Constants.googleServiceInfoPlistContent) {
            guard let contents = contents, let options = FirebaseOptions(contentsOfFile: contents) else {
                return nil
            }

            self.options = options
        }

        func configure() {
            FirebaseApp.configure(options: options)
        }
    }
}
