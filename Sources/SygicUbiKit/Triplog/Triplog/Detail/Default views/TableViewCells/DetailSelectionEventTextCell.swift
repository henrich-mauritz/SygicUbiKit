import UIKit

class DetailSelectionEventTextCell: BasicTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        leftLabel.font = .itemTitleFont()
        leftLabel.numberOfLines = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
