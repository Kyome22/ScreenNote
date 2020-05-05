//
//  Mail.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/03.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

class Mail {
    
    static func sendIssueReport() {
        let nameKey = "CFBundleName"
        let versionKey = "CFBundleShortVersionString"
        guard let appName = Bundle.main.object(forInfoDictionaryKey: nameKey) as? String else { return }
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: versionKey) as? String else { return }
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let systemVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"

        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["kyomesuke@icloud.com"]
        service.subject = "\(appName) \("issueReport".localized)"
        service.perform(withItems: [
            "environment".localized,
            "- \(appName): ver \(appVersion)",
            "- macOS: \(systemVersion)\n",
            "whatYouTried".localized,
            "shortDescription".localized,
            "reproduceIssue".localized,
            "expectedResult".localized
        ])
    }
    
}
