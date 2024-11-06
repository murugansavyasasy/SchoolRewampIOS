//
//  AWSS3Manager.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation


import UIKit

import AWSS3 //1



typealias progressBlock = (_ progress: Double) -> Void //2

typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void //3







class AWSS3Manager {

    

  

    static let shared = AWSS3Manager() // 4

    private init () { }



    let S3BucketName = AwsCredentials.bucketNameIndia

    let CognitoPoolID = AwsCredentials.CognitoPoolID

    let Region = AWSRegionType.APSouth1

    

   

    func uploadAWS(image : UIImage){

        

 

       

        

       

        

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)

        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration

        

        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)

        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)

        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".jpg")

        let dateFormatter = DateFormatter()



        dateFormatter.dateFormat = "dd-MM-yyyy"



        let  currentDate =   dateFormatter.string(from: Date())

        

        

   

        

       

        

        let ext = imageName as String

      

        let fileName = imageNameWithoutExtension

        let fileType = ".jpg"

        

        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)

        let data = image.jpegData(compressionQuality: 0.9)

        do {

            try data?.write(to: imageURL)

        }

        catch {}

        

        print(imageURL)

        

        let uploadRequest = AWSS3TransferManagerUploadRequest()

        uploadRequest?.body = imageURL

        uploadRequest?.bucket = S3BucketName

        uploadRequest?.contentType = ".jpg"

        

        

        // upload

        

        let transferManager = AWSS3TransferManager.default()

        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in

            

            if let error = task.error {

                print("Upload failed : (\(error))")

            }

            

            if task.result != nil {

                

                let url = AWSS3.default().configuration.endpoint.url

                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)

                if  let absoluteString = publicURL?.absoluteString {

                    print("Uploaded to:\(absoluteString)")

//

//

                }

            }

            else {

                print("Unexpected empty result.")

            }

            return nil

        }

    }

    

    

    

   





    

    // Upload video from local path url

    func uploadVideo(videoUrl: URL, progress: progressBlock?, completion: completionBlock?) {

        let fileName = self.getUniqueFileName(fileUrl: videoUrl)

        self.uploadfile(fileUrl: videoUrl, fileName: fileName, contenType: "video", progress: progress, completion: completion)

    }

    

    // Upload auido from local path url

    func uploadAudio(audioUrl: URL, progress: progressBlock?, completion: completionBlock?) {

        let fileName = self.getUniqueFileName(fileUrl: audioUrl)

        self.uploadfile(fileUrl: audioUrl, fileName: fileName, contenType: "audio", progress: progress, completion: completion)

    }

    

    // Upload files like Text, Zip, etc from local path url

    func uploadOtherFile(fileUrl: URL, conentType: String, progress: progressBlock?, completion: completionBlock?) {

        let fileName = self.getUniqueFileName(fileUrl: fileUrl)

        self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: conentType, progress: progress, completion: completion)

    }

    

    // Get unique file name

    func getUniqueFileName(fileUrl: URL) -> String {

        let strExt: String = "." + (URL(fileURLWithPath: fileUrl.absoluteString).pathExtension)

        return (ProcessInfo.processInfo.globallyUniqueString + (strExt))

    }

    

    //MARK:- AWS file upload

   

    private func uploadfile(fileUrl: URL, fileName: String, contenType: String, progress: progressBlock?, completion: completionBlock?) {

        // Upload progress block

        

     

        let expression = AWSS3TransferUtilityUploadExpression()

        expression.progressBlock = {(task, awsProgress) in

            guard let uploadProgress = progress else { return }

            DispatchQueue.main.async {

                uploadProgress(awsProgress.fractionCompleted)

            }

        }

        // Completion block

        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?

        completionHandler = { (task, error) -> Void in

            DispatchQueue.main.async(execute: {

                if error == nil {

                    let url = AWSS3.default().configuration.endpoint.url

                    let publicURL = url?.appendingPathComponent(self.S3BucketName).appendingPathComponent(fileName)

                    print("Uploaded to:\(String(describing: publicURL))")

                    if let completionBlock = completion {

                        completionBlock(publicURL?.absoluteString, nil)

                    }

                } else {

                    if let completionBlock = completion {

                        completionBlock(nil, error)

                    }

                }

            })

        }

        // Start uploading using AWSS3TransferUtility

        

        let dateFormatter = DateFormatter()



        dateFormatter.dateFormat = "yyyy-mm-dd"



        let  currentDate =   dateFormatter.string(from: Date())

        

        

        let aws_file_path =  currentDate + "/" + fileName

        

        print("aws_file_pathaws",aws_file_path)



        

        let awsTransferUtility = AWSS3TransferUtility.default()

        awsTransferUtility.uploadFile(fileUrl, bucket: S3BucketName, key: aws_file_path, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in

            if let error = task.error {

                print("AWS error is: \(error.localizedDescription)")

            }

            if let _ = task.result {

                // your uploadTask

            }

            return nil

        }

    }

}
