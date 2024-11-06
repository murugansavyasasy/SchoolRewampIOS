//
//  Constant.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation





struct DefaultsKeys {
    static let countryId = "countryId"
    static let LoginId = "LoginId"
    
    
}




class AwsCredentials {

    

    

    static var bucketNameIndia = "schoolchimes-files-india"

    

    static var bucketNameBangkok = "schoolchimes-files-bangkok"

    

    static var UploadProfileBucket = "schoolchimes-student-images"

    static var uploadprofileBrowes = "schoolchimes-docs"

    static var CognitoPoolID = "ap-south-1:5358f3d7-ec74-4bf5-8b69-df26a06ebd6a"

   

    

}


struct DateFormatters {
    static let MMDDYYYY = "MM/dd/yyyy"
    static let MMMDDYYYY = "MMM dd, yyyy"
    static let MMYYYY = "MM/yyyy"
    static let YYYYMMDD = "yyyy-MM-dd"
    static let MMMDD = "MMM dd"
}
