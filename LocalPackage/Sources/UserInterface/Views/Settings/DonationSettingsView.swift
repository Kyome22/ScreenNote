import DataSource
import Model
import StoreKit
import SwiftUI

struct DonationSettingsView: View {
    @StateObject var store: DonationSettings

    var body: some View {
        Form {
            Section {
                Label {
                    Text("donationDescription", bundle: .module)
                } icon: {
                    Image(nsImage: NSImage.appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
            }
            Section {
                ProductView(id: DonationProduct.oneTime.id, prefersPromotionalIcon: true) {
                    Image(systemName: "mug.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .productIconBorder()
                }
                .tint(.accentColor)
            } header: {
                Text("oneTimeDonation", bundle: .module)
            } footer: {
                if store.isPurchased {
                    Text("thankYouDonation", bundle: .module)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                ProductView(id: DonationProduct.yearly.id, prefersPromotionalIcon: true) {
                    Image(.cocoaPowder)
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                        .productIconBorder()
                }
                .tint(.accentColor)
            } header: {
                Text("continuousSupport", bundle: .module)
            } footer: {
                HStack(alignment: .firstTextBaseline) {
                    if store.isSubscribed {
                        Text("thankYouSupporting", bundle: .module)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        if store.isSubscribed {
                            Link(destination: URL.manageSubscriptions) {
                                Text("manageSubscription", bundle: .module)
                            }
                        } else {
                            Button {
                                Task { await store.send(.restoreSubscriptionButtonTapped) }
                            } label: {
                                Text("restoreSubscription", bundle: .module)
                            }
                            .buttonStyle(.link)
                        }
                        Link(destination: URL.termsOfService) {
                            Text("termsOfService", bundle: .module)
                        }
                        Link(destination: URL.localizedPrivacyPolicy) {
                            Text("privacyPolicy", bundle: .module)
                        }
                    }
                    .textScale(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .alert(
            isPresented: $store.showingAlert,
            error: store.error,
            actions: { _ in },
            message: { _ in }
        )
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
        .storeProductsTask(for: DonationProduct.allCases.map(\.id)) { taskState in
            await store.send(.onReceiveProductTaskState(taskState))
        }
        .onInAppPurchaseCompletion { product, result in
            await store.send(.onPurchaseCompleted(product, result))
        }
        .subscriptionStatusTask(for: store.subscriptionGroupID) { taskState in
            await store.send(.onReceiveSubscriptionTaskState(taskState))
        }
    }
}

extension DonationSettings: ObservableObject {}
