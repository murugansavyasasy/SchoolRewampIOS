import UIKit

protocol DeleteConcerndata: AnyObject{
    
    func deleteConcernData(index: Int)
    func AknowledgeConcernData(index: Int,Aknowledgediscreption : String,Is_viewAknowledgemeny : Bool)
    
    func addactionconcerndata(index: Int,Is_viewAction : Bool)
}
class ConcernTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var actionTakenDescreptionLbl: UILabel!
    @IBOutlet weak var actionAttachmentView: UIView!
    @IBOutlet weak var parantAttachmentView: UIView!
    @IBOutlet weak var actionImgCoutBtn: UIButton!
    @IBOutlet weak var actionImg3: UIImageView!
    @IBOutlet weak var actionImg2: UIImageView!
    @IBOutlet weak var actionImg1: UIImageView!
    @IBOutlet weak var imgCountBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    // Outlets
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentDetailsLabel: UILabel!
    @IBOutlet weak var statusPillView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var categoryTagContainer: UIView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var parentAttachmentsStack: UIStackView!
    @IBOutlet weak var noParentAttachmentsLabel: UILabel!
    @IBOutlet weak var parentCollectionView: UICollectionView!
    
    @IBOutlet weak var actionAttachmentsStack: UIStackView!
    @IBOutlet weak var noActionAttachmentsLabel: UILabel!
    @IBOutlet weak var actionCollectionView: UICollectionView!
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var actionDetailsContainer: UIView!
    @IBOutlet weak var acknowledgedByValueLabel: UILabel!
    @IBOutlet weak var acknowledgedOnValueLabel: UILabel!
    @IBOutlet weak var actionTakenValueLabel: UILabel!
    @IBOutlet weak var actionByValueLabel: UILabel!
    
    @IBOutlet weak var raisedOnLabel: UILabel!
    @IBOutlet weak var acknowledgeButton: UIButton!
    @IBOutlet weak var actionTakenButton: UIButton!
    @IBOutlet weak var bottomButtonsStackView: UIStackView!
    // State
    private var parentAttachments: [FilePath] = []
    private var actionAttachments: [FilePath] = []
    var loginasTye : Int?
    weak var viewController: UIViewController?
    weak var deleteDelegate: DeleteConcerndata?
    var AknowledgeDiscription : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()

        removeButton.isHidden = false
        bottomButtonsStackView.isHidden = false

        dividerView.isHidden = false
        actionDetailsContainer.isHidden = false

        acknowledgeButton.layer.borderWidth = 0
        actionTakenButton.layer.borderWidth = 0

        acknowledgeButton.layer.borderColor = nil
        actionTakenButton.layer.borderColor = nil

        acknowledgeButton.setTitle(nil, for: .normal)
        actionTakenButton.setTitle(nil, for: .normal)

        [img1, img2, img3].forEach {
            $0?.image = nil
            $0?.isHidden = true
        }

        [actionImg1, actionImg2, actionImg3].forEach {
            $0?.image = nil
            $0?.isHidden = true
        }

        imgCountBtn.isHidden = true
        actionImgCoutBtn.isHidden = true
    }
    
    @IBAction func deleteBtnAct(_ sender: UIButton) {
        
        deleteDelegate?.deleteConcernData(index: sender.tag)
    }
    
    
    @IBAction func actionTakenBtn(_ sender: UIButton) {
        if sender.currentTitle == "Action Taken" {
            print("Action Taken button clicked")
            deleteDelegate?.addactionconcerndata(index: sender.tag, Is_viewAction: false)
        }
        
        else{
            deleteDelegate?.addactionconcerndata(index: sender.tag, Is_viewAction: true)
        }
        
    }
    
    
    func aknowlegeFlow(index:Index){
        
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Add aknowledgement discreption",
            message: "\n\n\n",
            preferredStyle: .alert
        )
        
        let textView = UITextView(
            frame: CGRect(x: 15, y: 50, width: 240, height: 80)
        )
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
        alert.view.addSubview(textView)
        
        // Cancel
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        // OK
        alert.addAction(UIAlertAction(
            title: "Confirm",
            style: .default
        ) { _ in
            
            let actionText = textView.text ?? ""
            
            print("Action Taken:", actionText)
            self.AknowledgeDiscription = actionText
            
            self.deleteDelegate?.AknowledgeConcernData(index:index, Aknowledgediscreption: actionText, Is_viewAknowledgemeny: false)
            // API call here
        })
        
        viewController.present(alert, animated: true)
    }
    
    
    @IBAction func acknowledgeBtnAct(_ sender: UIButton) {
        if sender.currentTitle == "Acknowledged"{
            aknowlegeFlow(index: sender.tag)
        }else{
            
            deleteDelegate?.AknowledgeConcernData(index: sender.tag, Aknowledgediscreption: "", Is_viewAknowledgemeny: true)
        }
        
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        [img1, img2, img3].forEach {
            setBorderAndCornerRadius(for: $0!, cornerRadius:($0?.frame.width ?? 0)/2)
        }
        
        [actionImg1, actionImg2, actionImg3].forEach {
            setBorderAndCornerRadius(for: $0!, cornerRadius:($0?.frame.width ?? 0)/2)
        }
        // Style card view
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1.0).cgColor
        
        // Card shadow
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.05
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainerView.layer.shadowRadius = 8
        cardContainerView.layer.masksToBounds = false
        
        // Avatar circle
        avatarContainerView.layer.cornerRadius = 24
        avatarContainerView.layer.masksToBounds = true
        avatarContainerView.backgroundColor = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1.0) // Violet
        
        // Status badge pill
        statusPillView.layer.cornerRadius = 12
        statusPillView.layer.masksToBounds = true
        
        // Category Tag
        categoryTagContainer.layer.cornerRadius = 8
        categoryTagContainer.layer.masksToBounds = true
        categoryTagContainer.backgroundColor = UIColor(red: 239/255, green: 246/255, blue: 255/255, alpha: 1.0) // Light Blue
        
        // Action details box
        actionDetailsContainer.layer.cornerRadius = 12
        actionDetailsContainer.layer.masksToBounds = true
        actionDetailsContainer.layer.borderWidth = 1
        actionDetailsContainer.layer.borderColor = UIColor(red: 243/255, green: 244/255, blue: 246/255, alpha: 1.0).cgColor
        actionDetailsContainer.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 251/255, alpha: 1.0)
        
        // Remove button header (circular background)
        removeButton.layer.cornerRadius = 18
        removeButton.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            let trashImage = UIImage(systemName: "trash.fill")
            removeButton.setImage(trashImage, for: .normal)
        }
        // Bottom Buttons Style
        acknowledgeButton.layer.cornerRadius = 12
        acknowledgeButton.layer.masksToBounds = true
        
        actionTakenButton.layer.cornerRadius = 12
        actionTakenButton.layer.masksToBounds = true
        
        let parentAttach = UITapGestureRecognizer(target: self, action: #selector(parentAttachmentClik))
        parantAttachmentView.addGestureRecognizer(parentAttach)
        let actionAttach = UITapGestureRecognizer(target: self, action: #selector(actionTakenAttachmentClik))
        actionAttachmentView.addGestureRecognizer(actionAttach)
        if #available(iOS 13.0, *) {
            let checkmark = UIImage(systemName: "checkmark")
            acknowledgeButton.setImage(checkmark, for: .normal)
            
            let docIcon = UIImage(systemName: "doc.text")
            actionTakenButton.setImage(docIcon, for: .normal)
        }
    }
    
    
    
    
    @IBAction func parentAttachmentClik() {
        if parentAttachments.count != 0 {
            guard let viewcontoller  = viewController else { return }
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = parentAttachments
            imageVC.modalPresentationStyle = .fullScreen
            viewcontoller.present(imageVC, animated: true)
        }
       
        
    }
    
    @IBAction func actionTakenAttachmentClik() {
        if actionAttachments.count != 0 {
            guard let viewcontoller  = viewController else { return }
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = actionAttachments
            imageVC.modalPresentationStyle = .fullScreen
            viewcontoller.present(imageVC, animated: true)
        }
    }
    
    func configureButtons(
        isAcknowledged: Bool,
        isAction: Bool
    ) {

        if isAcknowledged {

            acknowledgeButton.setTitle(
                "Acknowledged",
                for: .normal
            )

            acknowledgeButton.backgroundColor = .systemGreen
            acknowledgeButton.setTitleColor(.white, for: .normal)
            acknowledgeButton.layer.borderWidth = 0

        } else {

            acknowledgeButton.setTitle(
                "View Acknowledge",
                for: .normal
            )

            acknowledgeButton.backgroundColor = .white
            acknowledgeButton.setTitleColor(.systemBlue, for: .normal)
            acknowledgeButton.layer.borderWidth = 1
            acknowledgeButton.layer.borderColor = UIColor.systemBlue.cgColor
        }


        if isAction {

            actionTakenButton.setTitle(
                "Action Taken",
                for: .normal
            )

            actionTakenButton.backgroundColor = .systemOrange
            actionTakenButton.setTitleColor(.white, for: .normal)
            actionTakenButton.layer.borderWidth = 0

        } else {

            actionTakenButton.setTitle(
                "View Action Taken",
                for: .normal
            )

            actionTakenButton.backgroundColor = .white
            actionTakenButton.setTitleColor(.systemOrange, for: .normal)
            actionTakenButton.layer.borderWidth = 1
            actionTakenButton.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
    
    
    
    func configure(with concern: Concern) {
        initialsLabel.text = concern.initials
        studentNameLabel.text = concern.studentName
        studentDetailsLabel.text = concern.classAndSection
        categoryNameLabel.text = concern.typeName
        descriptionLabel.text = concern.description
        raisedOnLabel.text = "Raised on \(concern.formattedRaisedOn)"
        
        parentAttachments = concern.filePath
        actionAttachments = concern.actionFilePath
        configureButtons(isAcknowledged: concern.is_acknowledged,isAction: concern.is_action)
        actionTakenDescreptionLbl.text = concern.acknowledgement
        if loginasTye == 1 {
            removeButton.isHidden = true
        } else {
            removeButton.isHidden = concern.can_delete == false
            
        }
        
        if #available(iOS 13.0, *) {
            categoryIconImageView.image = UIImage(systemName: "graduationcap.fill")
            categoryIconImageView.tintColor = UIColor(red: 29/255, green: 78/255, blue: 216/255, alpha: 1.0)
        }
        
        // Status Badging
        switch concern.status {
        case .pending:
            statusLabel.text = "PENDING"
            statusLabel.textColor = UIColor(red: 217/255, green: 119/255, blue: 6/255, alpha: 1.0)
            statusPillView.backgroundColor = UIColor(red: 254/255, green: 243/255, blue: 199/255, alpha: 1.0)
            
            // Pending has no action details. Hide the Action Details container.
            dividerView.isHidden = true
            actionDetailsContainer.isHidden = true
            if loginasTye == 1{
                bottomButtonsStackView.isHidden = false
            }else{
                bottomButtonsStackView.isHidden = true
            }
           
        case .acknowledged:
            statusLabel.text = "ACKNOWLEDGED"
            statusLabel.textColor = UIColor(red: 29/255, green: 78/255, blue: 216/255, alpha: 1.0)
            statusPillView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1.0)
            
            // Show action details card
            dividerView.isHidden = false
           
            actionDetailsContainer.isHidden = true
            // Populate Action Details grid
            acknowledgedByValueLabel.text = concern.acknowledgedBy.isEmpty ? "--" : concern.acknowledgedBy.capitalized
            acknowledgedOnValueLabel.text = concern.formattedAcknowledgedOn
            
            let actionTextVal = concern.actionTaken.trimmingCharacters(in: .whitespacesAndNewlines)
            actionTakenValueLabel.text = actionTextVal.isEmpty ? "--" : actionTextVal.capitalized
            
            let actionByNameVal = concern.formattedActionByName
            actionByValueLabel.text = actionByNameVal.isEmpty ? concern.formattedActionByDate : actionByNameVal
            bottomButtonsStackView.isHidden = false
        case .actiontaken:
            statusLabel.text = "ACTION TAKEN"
            
            statusLabel.textColor = UIColor(
                red: 22/255,
                green: 163/255,
                blue: 74/255,
                alpha: 1.0
            )

            statusPillView.backgroundColor = UIColor(
                red: 220/255,
                green: 252/255,
                blue: 231/255,
                alpha: 1.0
            )
            
            // Show action details card
            dividerView.isHidden = false
           
            actionDetailsContainer.isHidden = true
            // Populate Action Details grid
            acknowledgedByValueLabel.text = concern.acknowledgedBy.isEmpty ? "--" : concern.acknowledgedBy.capitalized
            acknowledgedOnValueLabel.text = concern.formattedAcknowledgedOn
            
            let actionTextVal = concern.actionTaken.trimmingCharacters(in: .whitespacesAndNewlines)
            actionTakenValueLabel.text = actionTextVal.isEmpty ? "--" : actionTextVal.capitalized
            
            let actionByNameVal = concern.formattedActionByName
            actionByValueLabel.text = actionByNameVal.isEmpty ? concern.formattedActionByDate : actionByNameVal
            bottomButtonsStackView.isHidden = false
            
        }
    }
    
}
