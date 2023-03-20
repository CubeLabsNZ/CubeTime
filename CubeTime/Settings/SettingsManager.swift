import Combine
import Foundation
import SwiftUI

final class SettingsManager {
    static let standard = SettingsManager(userDefaults: .default)
    fileprivate let userDefaults: NSUbiquitousKeyValueStore
    
    fileprivate var keys: [String: AnyKeyPath] = [:]
    
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    @objc func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        if let changeReason = (notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? NSArray)?.firstObject as? NSString,
           let keyPath = self.keys[String(changeReason)] {
            preferencesChangedSubject.send(keyPath)
        }
    }

    init(userDefaults: NSUbiquitousKeyValueStore) {
        self.userDefaults = userDefaults
        let ret = userDefaults.synchronize()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(
            ubiquitousKeyValueStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: self.userDefaults)
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
    
    @UserDefault("inspectionAlertFollowsSilent")
    var inspectionAlertFollowsSilent: Bool = false
    
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
    
    @UserDefault("gestureDistanceTrackpad")
    var gestureDistanceTrackpad: Double = 500
    
    @UserDefault("showScramble")
    var showScramble: Bool = true
    
    @UserDefault("showStats")
    var showStats: Bool = true
    
    @UserDefault("forceAppZoom")
    var forceAppZoom: Bool = false
    
    @UserDefault("appZoom")
    var appZoom: AppZoom = AppZoom(rawValue: 3)
    
    @UserDefault("showPrevTime")
    var showPrevTime: Bool = false
    
    @UserDefault("displayDP")
    var displayDP: Int = 3
    
    
    // MARK: - Appearance Settings
    
    @UserDefault("overrideDM")
    var overrideDM: Bool = false
    
    @UserDefault("dmBool")
    var dmBool: Bool = false
    
    @UserDefault("isStaticGradient")
    var isStaticGradient: Bool = true
    
    @UserDefault("graphGlow")
    var graphGlow: Bool = true
    
    @UserDefault("graphAnimation")
    var graphAnimation: Bool = true
    
    @UserDefault("scrambleSize")
    var scrambleSize: Int = UIDevice.deviceIsPad ? 26 : 18
    
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
            #warning("TODO: this is absolutely terrible, but I spent hours trying to check if Value is any RawRepresentable to no avail...")
            if Value.self == InputMode.self {
                guard let pref = container.object(forKey: key) as? InputMode.RawValue else { return defaultValue }
                return InputMode(rawValue: pref) as! Value? ?? defaultValue
            }
            typealias FeedbackType = UIImpactFeedbackGenerator.FeedbackStyle
            if Value.self == FeedbackType.self {
                guard let pref = container.object(forKey: key) as? FeedbackType.RawValue else { return defaultValue }
                return FeedbackType(rawValue: pref) as! Value? ?? defaultValue
            }
            
            instance.keys[key] = wrappedKeyPath
            
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            if let newValue = newValue as? (any RawRepresentable) {
                container.set(newValue.rawValue, forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}

final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?
    
    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
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
