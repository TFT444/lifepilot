/// Service-layer marker and offline stores for LifePilot.
/// Live EventKit / WeatherKit / CloudKit adapters land behind the same
/// Core protocols with graceful degradation when denied or unavailable.
public enum ServiceModule {
    public static let version = "0.2.0-daily-life-mvp"
}
