import Foundation
import CoreData
import Combine
import CloudKit

class CloudkitStatusManager: ObservableObject {
    var subscribers = Set<AnyCancellable>()
    
    @Published var currentStatus: Int? = 0
    
    init() {
        if (FileManager.default.ubiquityIdentityToken == nil) {
            self.currentStatus = 2
        }
        
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink(receiveValue: { notification in
                if let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event {
                    
                    if cloudEvent.endDate == nil {
                        DispatchQueue.main.async {
                            self.currentStatus = nil
                        }
                    } else {
                        if cloudEvent.succeeded {
                            DispatchQueue.main.async {
                                self.currentStatus = 0
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.currentStatus = 1
                            }
                        }
                        
                        if let _ = cloudEvent.error {
                            DispatchQueue.main.async {
                                self.currentStatus = 1
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentStatus = 0
                    }
                }
            })
            .store(in: &self.subscribers)
    }
}
