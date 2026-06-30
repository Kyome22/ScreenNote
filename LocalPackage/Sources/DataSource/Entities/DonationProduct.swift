public enum DonationProduct: String, Sendable, CaseIterable {
    case oneTime = "donation.onetime"
    case yearly = "donation.subscription.yearly"

    public var id: String {
        "com.kyome.ScreenNote.\(rawValue)"
    }
}
