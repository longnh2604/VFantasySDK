
import UIKit

protocol Super7WinnersPopupDelegate {
    func onChooseTeam(_ team: MyTeamData)
}

class Super7WinnersPopup: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var tbvListHeightConstant: NSLayoutConstraint!
    
    var delegate: Super7WinnersPopupDelegate?
    var onAction: BasePopupAction?
    
    var winners: [MyTeamData] = [] {
        didSet {
            self.lblTitle.text = String(format: "%d winners".localiz(), winners.count)
            let maxItems: CGFloat = winners.count > 5 ? CGFloat(5.5) : CGFloat(winners.count)
            let height = maxItems * Super7WinnerCell.heightCell
            self.tbvListHeightConstant.constant = height
            self.tbvList.reloadData()
            self.tbvList.isScrollEnabled = winners.count > 5
        }
    }
    
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
        self.tbvList.register(UINib(nibName: Super7WinnerCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: Super7WinnerCell.identifierCell)
    }
}

extension Super7WinnersPopup: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.winners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Super7WinnerCell.identifierCell) as? Super7WinnerCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.winner = self.winners[indexPath.row]
        cell.lineView.isHidden = indexPath.row == self.winners.count - 1
        return cell
    }
}

extension Super7WinnersPopup: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Super7WinnerCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onAction = self.onAction {
            onAction(true)
        }
        let winner = self.winners[indexPath.row]
        self.delegate?.onChooseTeam(winner)
    }
}


extension Super7WinnersPopup: BasePopupDataSource {
    func totalHeight() -> CGFloat {
        self.tbvList.layoutIfNeeded()
        return self.tbvList.frame.maxY + KEY_WINDOW_SAFE_AREA_INSETS.bottom + 16.0
    }
    
    func dismissWhenTouchUpOutside() -> Bool {
        return true
    }
}
