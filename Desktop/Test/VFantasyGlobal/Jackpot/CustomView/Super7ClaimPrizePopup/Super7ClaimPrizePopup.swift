
import UIKit

class Super7ClaimPrizePopup: UIView {
    
    @IBOutlet weak var firstNameTextField: IBDCTextField!
    @IBOutlet weak var lastNameTextField: IBDCTextField!
    @IBOutlet weak var emailTextField: IBDCTextField!
    @IBOutlet weak var phoneTextField: IBDCTextField!
    @IBOutlet weak var btnClaim: GradientButton!
    
    var onAction: BasePopupAction?
    var messageClaim = MessageValid()
    var claimModel: Super7ClaimModel = Super7ClaimModel()
    var rootVC: UIViewController!
    var teamID: Int = 0
    var real_round_id: Int = 0
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    // MARK: - Function
    func loadViewFromXIB() {
        let views = Bundle.sdkBundler()?.loadNibNamed(self.className, owner: self, options: nil)
        self.backgroundColor = .clear
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .white
            containerView.frame = self.bounds
            addSubview(containerView)
        }
        
        btnClaim.action = "Submit".localiz().uppercased()
        btnClaim.delegate = self
        
        firstNameTextField.placeholder = "first_name".localiz().upperFirstCharacter()
        firstNameTextField.font = UIFont(name: FontName.regular, size: 16.0)
        firstNameTextField.setColorPlaceHolder(color: UIColor(hex: 0x787C88))

        lastNameTextField.placeholder = "last_name".localiz().upperFirstCharacter()
        lastNameTextField.font = UIFont(name: FontName.regular, size: 16.0)
        lastNameTextField.setColorPlaceHolder(color: UIColor(hex: 0x787C88))

        emailTextField.placeholder = "email_placeholder".localiz().upperFirstCharacter()
        emailTextField.font = UIFont(name: FontName.regular, size: 16.0)
        emailTextField.setColorPlaceHolder(color: UIColor(hex: 0x787C88))
        
        phoneTextField.placeholder = "Phone number".localiz().upperFirstCharacter()
        phoneTextField.font = UIFont(name: FontName.regular, size: 16.0)
        phoneTextField.setColorPlaceHolder(color: UIColor(hex: 0x787C88))
        
        observeFirstName()
        observeLastName()
        observeEmail()
        observePhone()
        validationMessageIfNeed(message: MessageValid())
    }
    
    // observe email edit from UI and set text edit to login model.
    private func observeFirstName() {
        firstNameTextField.throttle(.editingChanged, interval: 0.1) { (textField:UITextField) in
            self.claimModel.firstName = textField.text!
        }
    }
    
    // observe password edit from UI and set text edit to login model.
    private func observeLastName() {
        lastNameTextField.throttle(.editingChanged, interval: 0.1) { (textField:UITextField) in
            self.claimModel.lastName = textField.text!
        }
    }
    
    // observe email edit from UI and set text edit to login model.
    private func observeEmail() {
        emailTextField.throttle(.editingChanged, interval: 0.1) { (textField:UITextField) in
            self.claimModel.email = textField.text!
        }
    }
    
    // observe password edit from UI and set text edit to login model.
    private func observePhone() {
        phoneTextField.throttle(.editingChanged, interval: 0.1) { (textField:UITextField) in
            self.claimModel.phone = textField.text!
        }
    }
    
    func validationMessageIfNeed(message:MessageValid) {
        if let text = message.firstName {
            textFieldChangeColor(color:text.isNotEmpty ? #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1) : nil, textField:firstNameTextField)
        } else {
            textFieldChangeColor(color: UIColor(hex: 0x787C88), textField:firstNameTextField)
        }
        
        if let text = message.lastName {
            textFieldChangeColor(color:text.isNotEmpty ? #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1) : nil, textField:lastNameTextField)
        } else {
            textFieldChangeColor(color: UIColor(hex: 0x787C88), textField:lastNameTextField)
        }
        
        if let text = message.email {
            textFieldChangeColor(color:text.isNotEmpty ? #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1) : nil, textField:emailTextField)
        } else {
            textFieldChangeColor(color: UIColor(hex: 0x787C88), textField:emailTextField)
        }
        
        if let text = message.phone {
            textFieldChangeColor(color:text.isNotEmpty ? #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1) : nil, textField:phoneTextField)
        } else {
            textFieldChangeColor(color: UIColor(hex: 0x787C88), textField:phoneTextField)
        }
    }
    
    func textFieldChangeColor(color:UIColor?, textField:IBDCTextField) {
        textField.setBolderColor(color: color)
        textField.setColorPlaceHolder(color: color)
    }
    
    func validAction() -> String? {
        var message: String?
        
        messageClaim = MessageValid()
        if claimModel.firstName.isEmpty {
            message = "required_fields".localiz()
            messageClaim.firstName = message
            return message
        }
        
        if claimModel.lastName.isEmpty {
            message = "required_fields".localiz()
            messageClaim.lastName = message
            return message
        }
        
        if claimModel.email.isEmpty {
            message = "you_must_fill_your_email_address".localiz()
            messageClaim.email = message
            return message
        }
        
        if !claimModel.email.isValidEmail() {
            message = "email_address_is_not_valid".localiz()
            messageClaim.email = message
            return message
        }
        
        if claimModel.phone.isEmpty {
            message = "required_fields".localiz()
            messageClaim.phone = message
            return message
        }
        
        return message
    }
}

extension Super7ClaimPrizePopup: GradientButtonDelegate {
    func onClick(_ sender: GradientButton) {
        let message = validAction()
        if message != nil {
            self.rootVC.showAlert(message: message)
            self.validationMessageIfNeed(message: messageClaim)
            return
        }
        self.rootVC.startAnimation()
        Super7Service().claimThePrize(self.teamID, self.real_round_id, claimModel) { response, status in
            self.rootVC.stopAnimation()
            guard let prizeData = response as? Super7ClaimPrizeData else { return }
            guard let _ = prizeData.response else { return }
            self.rootVC.showAlert(message: "Your submission to claim the prize is sent to the organizer. We will contact you soon.".localiz())
            if let onAction = self.onAction {
                onAction(true)
            }
        }
    }
}

extension Super7ClaimPrizePopup: BasePopupDataSource {
    func totalHeight() -> CGFloat {
        self.layoutIfNeeded()
        return self.btnClaim.frame.maxY + KEY_WINDOW_SAFE_AREA_INSETS.bottom  + 10.0
    }
    
    func dismissWhenTouchUpOutside() -> Bool {
        return true
    }
}

extension Super7ClaimPrizePopup: BasePopupKeyboardDataSource {
    func isOverWhenKeyboardShowing() -> Bool {
        return true
    }
}
