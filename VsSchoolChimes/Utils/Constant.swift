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
//    static let Language = "Language"
    static let Language = "Language"
   
    
}




class AwsCredentials {

    

    

    static var bucketNameIndia = "schoolchimes-files-india"

    

    static var bucketNameBangkok = "schoolchimes-files-bangkok"

    

    static var UploadProfileBucket = "schoolchimes-student-images"

    static var uploadprofileBrowes = "schoolchimes-docs"

    static var CognitoPoolID =     "ap-south-1:a8650d2e-79d6-4668-85db-110e9917583f"

   

    

}


struct DateFormatters {
    static let MMDDYYYY = "MM/dd/yyyy"
    static let MMMDDYYYY = "MMM dd, yyyy"
    static let MMYYYY = "MM/yyyy"
    static let YYYYMMDD = "yyyy-MM-dd"
    static let MMMDD = "MMM dd"
}
