
import Foundation
import KRProgressHUD
class BookSlotsForStudentRequest{

    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        KRProgressHUD.show()
        print("get_url()",get_url())
        BaseRequest.raw_post(url: get_url(), param: param).success {

            (res) in
            completion_handler (res as! String)
        }
    }




    private static func get_url() -> String {

        return String (format:  "%@/ptm-schedule/booking-slots-for-student",StaffConstantFile.SmsBaseUrl as! CVarArg )

    }
   



}
