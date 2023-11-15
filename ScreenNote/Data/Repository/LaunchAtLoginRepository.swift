/*
  LaunchAtLoginRepository.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Foundation
import ServiceManagement

protocol LaunchAtLoginRepository: AnyObject {
    var current: Bool { get }

    init()

    func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void)
}

final class LaunchAtLoginRepositoryImpl: LaunchAtLoginRepository {
    var current: Bool {
        return SMAppService.mainApp.status == .enabled
    }

    func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void) {
        do {
            if newValue {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            logput(error.localizedDescription)
        }
        if current != newValue {
            failureHandler()
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class LaunchAtLoginRepositoryMock: LaunchAtLoginRepository {
        var current: Bool = false
        func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void) {}
    }
}
