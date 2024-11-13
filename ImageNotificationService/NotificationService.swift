//
//  NotificationService.swift
//  ImageNotificationService
//
//  Created by Apple on 11/12/24.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {


    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
          
           let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
           
          
           if let userInfo = request.content.userInfo as? [String: Any],
              let images = userInfo["images"] as? [String] {
               
               var attachments: [UNNotificationAttachment] = []
               
               // Download each image and create attachments
               let dispatchGroup = DispatchGroup()
               var downloadedImages: [UNNotificationAttachment] = []
               
               for imageURL in images {
                   dispatchGroup.enter()
                   downloadImage(from: imageURL) { (attachment) in
                       if let attachment = attachment {
                           downloadedImages.append(attachment)
                       }
                       dispatchGroup.leave()
                   }
               }
               
               dispatchGroup.notify(queue: .main) {
                   if !downloadedImages.isEmpty {
                       bestAttemptContent?.attachments = downloadedImages
                   }
                   
                   // Call the content handler with the modified notification content
                   contentHandler(bestAttemptContent!)
               }
           } else {
               // If no images are present, just proceed with the original notification content
               contentHandler(bestAttemptContent!)
           }
       }

       private func downloadImage(from url: String, completion: @escaping (UNNotificationAttachment?) -> Void) {
           guard let imageURL = URL(string: url) else {
               completion(nil)
               return
           }
           
           URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
               guard let data = data, error == nil else {
                   completion(nil)
                   return
               }
               
               // Save the image data to a temporary file
               let tempDirectory = FileManager.default.temporaryDirectory
               let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
               
               do {
                   try data.write(to: tempURL)
                   let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: tempURL, options: nil)
                   completion(attachment)
               } catch {
                   completion(nil)
               }
           }.resume()
       }
   }
   
