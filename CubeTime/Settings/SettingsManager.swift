import Combine
import Foundation
import SwiftUI

final class SettingsManager {
    
    static let standard = SettingsManager(userDefaults: .standard)
    fileprivate let userDefaults: UserDefaults
    
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - General Settings
    
    @UserDefault("freeze")
    var holdDownTime: Double = 0.5
    
    @UserDefault("inspection")
    var inspection: Bool = false
    
    @UserDefault("inspectionCountsDown")
    var inspectionCountsDown: Bool = false
    
    @UserDefault("showCancelInspection")
    var showCancelInspection: Bool = true
    
    @UserDefault("inspectionAlert")
    var inspectionAlert: Bool = true
    
    @UserDefault("inspectionAlertType")
    var inspectionAlertType: Int = 0
    
    @UserDefault("inputMode")
    var inputMode: InputMode = .timer
    
    @UserDefault("timeDpWhenRunning")
    var timeDpWhenRunning: Int = 3
    
    @UserDefault("showSessionName")
    var showSessionType: Bool = false
    
    @UserDefault("hapBool")
    var hapticEnabled: Bool = true
    
    @UserDefault("hapType")
    var hapticType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    
    @UserDefault("gestureDistance")
    var gestureDistance: Double = 50
    
    @UserDefault("showScramble")
    var showScramble: Bool = true
    
    @UserDefault("showStats")
    var showStats: Bool = true
    
    @UserDefault("forceAppZoom")
    var forceAppZoom: Bool = false
    
    @UserDefault("appZoom")
    var appZoom: AppZoomWrapper = AppZoomWrapper(rawValue: 3)
    
    @UserDefault("showPrevTime")
    var showPrevTime: Bool = false
    
    @UserDefault("displayDP")
    var displayDP: Int = 3
    
    
    // MARK: - Appearance Settings
    
    @UserDefault("overrideDM")
    var overrideDM: Bool = false
    
    @UserDefault("dmBool")
    var dmBool: Bool = false
    
    @UserDefault("staticGradient")
    var staticGradient: Bool = true
    
    @UserDefault("gradientSelected")
    var gradientSelected: Int = 6
    
    @UserDefault("graphGlow")
    var graphGlow: Bool = true
    
    @UserDefault("graphAnimation")
    var graphAnimation: Bool = true
    
    @UserDefault("scrambleSize")
    var scrambleSize: Int = 18
    
    @UserDefault("fontWeight")
    var fontWeight: Double = 516.0
    
    @UserDefault("fontCasual")
    var fontCasual: Double = 0.0
    
    @UserDefault("fontCursive")
    var fontCursive: Bool = false
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }
    
    init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public static subscript(
        _enclosingInstance instance: SettingsManager,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<SettingsManager, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<SettingsManager, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}

final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?
    
    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}

@propertyWrapper
struct Preference<Value>: DynamicProperty {
    
    @ObservedObject private var preferencesObserver: PublisherObservableObject
    private let keyPath: ReferenceWritableKeyPath<SettingsManager, Value>
    private let preferences: SettingsManager
    
    init(_ keyPath: ReferenceWritableKeyPath<SettingsManager, Value>, preferences: SettingsManager = .standard) {
        self.keyPath = keyPath
        self.preferences = preferences
        let publisher = preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }.map { _ in () }
            .eraseToAnyPublisher()
        self.preferencesObserver = .init(publisher: publisher)
    }

    var wrappedValue: Value {
        get { preferences[keyPath: keyPath] }
        nonmutating set { preferences[keyPath: keyPath] = newValue }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
