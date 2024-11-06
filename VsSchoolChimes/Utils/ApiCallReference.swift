import UIKit

class CustomTextView: UIView, UITextViewDelegate {
    
    private let inputBackgroundView = UIView()
    private let invisibleTextView = UITextView()
    private let nameTextView = UITextView()
    private let separatorView = UIView()
    private let nameLabelTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Configure the background view for input layout
        inputBackgroundView.backgroundColor = UIColor.systemGray6
        inputBackgroundView.layer.cornerRadius = 10
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputBackgroundView)
        
        NSLayoutConstraint.activate([
            inputBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            inputBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            inputBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        // Configure the invisible TextView
        invisibleTextView.isHidden = true
        invisibleTextView.translatesAutoresizingMaskIntoConstraints = false
        inputBackgroundView.addSubview(invisibleTextView)
        
        NSLayoutConstraint.activate([
            invisibleTextView.topAnchor.constraint(equalTo: inputBackgroundView.topAnchor, constant: 5),
            invisibleTextView.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 40),
        ])
        
        // Configure the name TextView (input field)
        nameTextView.backgroundColor = .clear
        nameTextView.delegate = self
        nameTextView.text = "Enter your name"
        nameTextView.textColor = .lightGray
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        inputBackgroundView.addSubview(nameTextView)
        
        NSLayoutConstraint.activate([
            nameTextView.topAnchor.constraint(equalTo: invisibleTextView.bottomAnchor, constant: 5),
            nameTextView.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 30),
            nameTextView.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -10),
            nameTextView.bottomAnchor.constraint(equalTo: inputBackgroundView.bottomAnchor, constant: -10)
        ])
        
        // Configure the separator view
        separatorView.backgroundColor = UIColor.lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: inputBackgroundView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Configure the name label TextView
        nameLabelTextView.text = "Name"
        nameLabelTextView.isEditable = false
        nameLabelTextView.backgroundColor = .white
        nameLabelTextView.textColor = UIColor.systemBlue
        nameLabelTextView.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabelTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabelTextView)
        
        NSLayoutConstraint.activate([
            nameLabelTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            nameLabelTextView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: -10)
        ])
        
        // Finalize the container height by constraining the bottom
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: separatorView.bottomAnchor)
        ])
    }
    
    // UITextViewDelegate for Placeholder Behavior
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == nameTextView && textView.text == "Enter your name" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == nameTextView && textView.text.isEmpty {
            textView.text = "Enter your name"
            textView.textColor = .lightGray
        }
    }
}

