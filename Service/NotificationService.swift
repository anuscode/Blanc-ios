//
//  NotificationService.swift
//  Service
//
//  Created by Yongwoo Lee on 2021/03/29.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            if let fcm_options = request.content.userInfo["fcm_options"] as? [String: Any],
               let imageUrl = fcm_options["image"] as? String,
               let attachment = parseAttachment(imageUrl: imageUrl) {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    func parseAttachment(imageUrl: String) -> UNNotificationAttachment? {
        if let url = URL(string: imageUrl),
           let imageData = NSData(contentsOf: url) {
            let identifier = UUID().uuidString
            let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "\(identifier).jpg", data: imageData)
            return attachment
        }
        return nil
    }
}

@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {

    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject: AnyObject]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        return nil
    }
}
