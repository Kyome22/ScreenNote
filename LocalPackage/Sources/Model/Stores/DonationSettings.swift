import DataSource
import Observation
import StoreKit
import SwiftUI

@MainActor @Observable
public final class DonationSettings: Composable {
    private let logService: LogService

    public var subscriptionGroupID: String
    public var isPurchased: Bool
    public var isSubscribed: Bool
    public var showingAlert: Bool
    public var error: StoreKitError?
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        subscriptionGroupID: String? = nil,
        isPurchased: Bool = false,
        isSubscribed: Bool = false,
        showingAlert: Bool = false,
        error: StoreKitError? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.logService = .init(appDependencies)
        self.subscriptionGroupID = subscriptionGroupID
            ?? appDependencies.appStateClient.withLock(\.subscriptionGroupID)
        self.isPurchased = isPurchased
        self.isSubscribed = isSubscribed
        self.showingAlert = showingAlert
        self.error = error
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case .restoreSubscriptionButtonTapped:
            do {
                try await AppStore.sync()
            } catch {
                handle(error)
            }

        case let .onReceiveProductTaskState(taskState):
            if case let .failure(error) = taskState {
                handle(error)
            }

        case let .onPurchaseCompleted(product, result):
            switch result {
            case let .success(.success(verificationResult)):
                do {
                    let transaction = try verificationResult.payloadValue
                    if product.id == DonationProduct.oneTime.id {
                        isPurchased = true
                    }
                    await transaction.finish()
                } catch {
                    handle(error)
                }
            case .success:
                return
            case let .failure(error):
                handle(error)
            }

        case let .onReceiveSubscriptionTaskState(taskState):
            isSubscribed = if let states = taskState.value?.map(\.state) {
                states.contains { [.subscribed, .inGracePeriod].contains($0) }
            } else {
                false
            }
        }
    }

    private func handle(_ error: any Error) {
        if let error = error as? StoreKitError {
            switch error {
            case .userCancelled:
                return
            default:
                self.error = error
                showingAlert = true
            }
        } else {
            logService.error(.donationFailed(error))
        }
    }

    public enum Action: Sendable {
        case task(String)
        case restoreSubscriptionButtonTapped
        case onReceiveProductTaskState(Product.CollectionTaskState)
        case onPurchaseCompleted(Product, Result<Product.PurchaseResult, any Error>)
        case onReceiveSubscriptionTaskState(EntitlementTaskState<[Product.SubscriptionInfo.Status]>)
    }
}
