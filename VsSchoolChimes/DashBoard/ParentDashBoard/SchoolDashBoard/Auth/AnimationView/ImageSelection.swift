////
////  AnimatView.swift
////  VsSchoolChimes
////
////  Created by admin on 28/11/24.
////
//

import Foundation
import UIKit

class ImageSelection:UIView{

    
    
    
    @IBOutlet weak var imageCollectionview: UICollectionView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = loadViewFromNib() else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
    }
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "ImageSelection", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
    }
    func registerCell(){
        imageCollectionview.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        imageCollectionview.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
    }
    
}

