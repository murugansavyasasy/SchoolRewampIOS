//////
//////  common_apiCall.swift
//////  School Chimes
//////
//////  Created by SARANRAJ SHANMUGAM on 05/06/25.
//////
////
////import Foundation
////
//class  common_apiCall {
////    
////    
//    func sendAttachment(
//        with uploadedFiles: [[String: String]],
//        iframe: String,
//        filesize: String,
//        baseURl: String,
//        array_selectedId : [String],
//        target_type : Int,
//        selectedAcadimicYearId : Int,
//        subjectId: String, onComplete : (Send_AttachmentResponse) -> Void
//    ) {
//        
//        
//        var parameters: [String: Any] = [
//            SendAttachmentStringFile.file_path: uploadedFiles,
//            SendAttachmentStringFile.iframe: iframe,
//            SendAttachmentStringFile.file_size: filesize,
//            SendAttachmentStringFile.target_code: array_selectedId,
//            SendAttachmentStringFile.target_type: target_type,
//            SendAttachmentStringFile.academic_year_id: selectedAcadimicYearId
//        ]
//        
//        
//        
//        // Conditionally add value
//        if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
//            parameters[UploadMessageKeys.subjectId] = subjectId
//        }
//        
//        
//        Common_request_params.merge(parameters) { (_, new) in new }
//        print("📤 Sending parameters: \(parameters)")
//        
//        APIService.shared.makeApi(
//            url: baseURl,
//            parameters: Common_request_params,
//            type: ApitTypeSringFile.POST,
//            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
//        ) { [self] (result: Result<Send_AttachmentResponse, Error>) in
//            switch result {
//            case .success(let successMessage):
//                onComplete(successMessage)
////                if successMessage.status == true {
////                    DispatchQueue.main.async {
////                        CustomAlert.showAlertWithOkAction(
////                            title: successMessage.status ? AlertstringFile.Success : AlertstringFile.Alert_title,
////                            message: successMessage.message,
////                            on: self
////                        ) {
////                            self.gotoDashboard()
////                        }
////                    }
////                }else {
////                    
////                    DispatchQueue.main.async {
////                        CustomAlert
////                            .showAlertWithOkAction(
////                                title: AlertstringFile.Alert_title,
////                                message: successMessage.message,
////                                on: self
////                            ) {
////                                self.gotoDashboard()
////                            }
////                    }
////                }
////                
//                
//            case .failure(let error):
//                print("❌ API error: \(error.localizedDescription)")
//                // Optional: Add alert for failure
//            }
//        }
//        
//    }
//    
//
//    
//    
//    
//    
//    
//}
