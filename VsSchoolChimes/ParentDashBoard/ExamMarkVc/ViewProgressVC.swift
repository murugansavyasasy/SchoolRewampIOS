//
//  ViewProgressVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/07/25.
//

import UIKit
import WebKit

class ViewProgressVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var examId: String?
    var urlString: String?
    private var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        webView.navigationDelegate = self
        markListApi(exam_id: examId ?? "")
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
