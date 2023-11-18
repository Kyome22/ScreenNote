/*
  IssueReportModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Cocoa

protocol IssueReportModel {
    static func send()
}

struct IssueReporterImpl: IssueReportModel {
    static func send() {
        let appName = "CFBundleName".infoString
        let appVersion = "CFBundleShortVersionString".infoString
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let systemVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"

        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["kyomesuke@icloud.com"]
        service.subject = "\(appName) \(String(localized: "issueReport"))"
        service.perform(withItems: [
            String(localized: "environment\(appName)\(appVersion)\(systemVersion)"),
            String(localized: "whatYouTried"),
            String(localized: "shortDescription"),
            String(localized: "reproduceIssue"),
            String(localized: "expectedResult")
        ])
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    struct IssueReportModelMock: IssueReportModel {
        static func send() {}
    }
}
