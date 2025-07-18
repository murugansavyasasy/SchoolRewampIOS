//
//  ViewProgressVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/07/25.
//

import UIKit
import WebKit

class ViewProgressVC: UIViewController {

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var dowloadBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    var examId: String?
    var urlString: String?
    var backBtnTitle:String?
    private var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        webView.navigationDelegate = self
        markListApi(exam_id: examId ?? "")
        BackBtn.applyBackButton()
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        BackBtn.setTitle(backBtnTitle ?? "", for: .normal)
        dowloadBtn.layer.cornerRadius = 10
    }

    func markListApi(exam_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_get_progress_card,
            parameters: ["exam_id": exam_id],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status ?? false{
                        self?.urlString = response.data?.first
                        self?.loadRequestedURL()
                    }else{
                        
                    }
                case .failure(let error):
                    print("API Error:", error)
                    self?.showError("Failed to fetch URL from server")
                }
            }
        }
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadRequestedURL() {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            showError("Invalid or empty URL")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func dowloadBtn(_ sender: UIButton) {
        guard let fileURL = urlString, let filename = getFileName(from: fileURL) else {
            print("❌ Invalid file URL or file name")
            sender.isEnabled = true
            return
        }
        let downloader = FileDownloader()
        downloader.downloadFile(
            from: fileURL,
            folderName: "Document",
            fileName: filename
        ) { result in
            DispatchQueue.main.async { [self] in
                sender.isEnabled = true
                switch result {
                case .success(let filePath):
                    CustomAlert.showAlertWithOkAction(
                        title:"",
                        message: "\(filename) Downloaded successfully ✅",
                        on: self)
                case .failure(let error):
                    CustomAlert.showAlertWithOkAction(
                        title:"",
                        message: "\(filename) Download Failed ❌",
                        on: self)
                }
            }
        }
    }
    func getFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent
    }
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ViewProgressVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError("Failed to load page")
    }
}
