/// Subscription tiers for a Cambric product.
///
/// Tiers are ordered from least to most capable. A higher tier grants
/// everything a lower tier grants. The free tier is always available and
/// requires no payment or account.
enum SubscriptionTier {
  free,
  pro,
  enterprise;

  /// Parses a tier from its stored name, defaulting to [free] on unknown input.
  static SubscriptionTier fromName(String? name) {
    for (final tier in SubscriptionTier.values) {
      if (tier.name == name) return tier;
    }
    return SubscriptionTier.free;
  }

  /// Whether this tier is at least as capable as [other].
  bool atLeast(SubscriptionTier other) => index >= other.index;
}