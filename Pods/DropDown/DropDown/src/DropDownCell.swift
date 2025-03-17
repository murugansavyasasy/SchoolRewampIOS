//
//  DropDownCellTableViewCell.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

open class DropDownCell: UITableViewCell {
		
	//UI
    @IBOutlet weak var imgBtn: UIImageView!
    @IBOutlet weak var listNameBtn: UIButton!
    @IBOutlet open weak var optionLabel: UILabel!
	
	var selectedBackgroundColor: UIColor?
    var highlightTextColor: UIColor?
    var normalTextColor: UIColor?
    var url:String? = nil

}

//MARK: - UI

extension DropDownCell {
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		print(url)
		backgroundColor = .clear
        imgBtn.layer.cornerRadius = imgBtn.frame.width/2
	}
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Image load error:", error.localizedDescription)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imgBtn.image = image
                }
            } else {
                print("Failed to decode image data")
            }
        }
        task.resume()
    }


	override open var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override open var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override open func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [weak self] in
			guard let `self` = self else { return }

			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
                    self.optionLabel.textColor = self.highlightTextColor
                    self.listNameBtn.tintColor = self.highlightTextColor
				} else {
					self.backgroundColor = .clear
                    self.optionLabel.textColor = self.normalTextColor
                    self.listNameBtn.tintColor = self.normalTextColor
				}
			}
		}
		
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}

		accessibilityTraits = selected ? .selected : .none
	}
	
}
