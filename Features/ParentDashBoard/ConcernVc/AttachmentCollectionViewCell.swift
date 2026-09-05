import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    private var downloadTask: URLSessionDataTask?
    private var currentUrlString: String?
    
    // Shared simple memory cache to avoid redownloading images during scroll reuse
    private static let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel ongoing download and clear state
        downloadTask?.cancel()
        downloadTask = nil
        thumbnailImageView.image = nil
        currentUrlString = nil
    }
    
    private func setupUI() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.layer.masksToBounds = true
        
        // Add a subtle border or background color to make white images look neat
        thumbnailImageView.layer.borderWidth = 1.0
        thumbnailImageView.layer.borderColor = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1.0).cgColor
        thumbnailImageView.backgroundColor = UIColor(red: 243/255, green: 244/255, blue: 246/255, alpha: 1.0)
    }
    
    func configure(with urlString: String) {
        currentUrlString = urlString
        
        // 1. Check Image Cache
        let cacheKey = NSString(string: urlString)
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            thumbnailImageView.image = cachedImage
            return
        }
        
        // 2. Set placeholder while downloading
        if #available(iOS 13.0, *) {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .systemGray4
        }
        
        // 3. Validate URL
        guard let url = URL(string: urlString) else { return }
        
        // 4. Download Asynchronously
        downloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Check if download was cancelled or if cell was reused for a different URL
            if error != nil || self.currentUrlString != urlString {
                return
            }
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                // Store in cache
                Self.imageCache.setObject(downloadedImage, forKey: cacheKey)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if self.currentUrlString == urlString {
                        UIView.transition(with: self.thumbnailImageView,
                                          duration: 0.2,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                            self.thumbnailImageView.image = downloadedImage
                                          }, completion: nil)
                    }
                }
            }
        }
        
        downloadTask?.resume()
    }
}
