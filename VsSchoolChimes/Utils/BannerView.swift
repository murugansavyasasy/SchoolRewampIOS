import UIKit
import WebKit

class BannerView: UICollectionReusableView {
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.clipsToBounds = true
        webView.layer.cornerRadius = 10
        return webView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            webView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func loadURL(_ urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            webView.loadHTMLString("<html><body><p>No content</p></body></html>", baseURL: nil)
            return
        }
        webView.load(URLRequest(url: url))
    }
}
