
import UIKit

class MemoPopUpViewController: UIViewController {

    @IBOutlet weak var memoBackView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveMemoButton: UIButton!

    @IBOutlet weak var descriptionLabel: UILabel!
    
    var delegate: PopupDelegate?
    
    var selectedMonth = Int()
    var selectedDay = Int()
    var memo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readyToMemo()
        
        setShadow()
        
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveMemoButtonAction(_ sender: Any) {
        delegate?.saveMemo(memo: memoTextView.text)
        dismiss(animated: true, completion: nil)
    }
    
    func readyToMemo() {
        memoTextView.text = memo
        memoTextView.becomeFirstResponder()
        descriptionLabel.text = "\(selectedDay)일 메모"
    }
    
    func setShadow() {
        memoBackView.layer.cornerRadius = 10
        memoBackView.layer.masksToBounds = true
        
        memoTextView.layer.cornerRadius = 2
        memoTextView.layer.masksToBounds = true
        
        saveMemoButton.layer.cornerRadius = 5
        saveMemoButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        saveMemoButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveMemoButton.layer.shadowOpacity = 1.0
        saveMemoButton.layer.shadowRadius = 1.0
    }
}

