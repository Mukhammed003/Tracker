//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.08.2025.
//

import UIKit

enum MenuAction {
    case edit
    case delete
}

final class TrackerCollectionViewCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    private static let identifier = Constants.trackerCollectionViewCellIdentifier
    
    private lazy var trackerView: UIView = makeTrackerView()
    private lazy var emojiLabel: UILabel = makeEmojiLabel()
    private lazy var trackerLabel: UILabel = makeTrackerLabel()
    private lazy var quantityView: UIView = makeQuantityView()
    private lazy var quantityLabel: UILabel = makeQuantityLabel()
    private lazy var quantityAddButton: UIButton = makeQuantityAddButton()
    
    private var trackerID: UInt?
    private var isCompleted: Bool = false
    private var completionHandler: ((UInt, Bool) -> Void)?
    private var menuHandler: ((UInt, MenuAction) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configure(
        tracker: Tracker,
        isCompleted: Bool,
        count: Int,
        completionHandler: @escaping ((UInt, Bool) -> Void),
        menuHandler: @escaping ((UInt, MenuAction) -> Void)
    ) {
        self.trackerID = tracker.id
        self.isCompleted = isCompleted
        self.completionHandler = completionHandler
        self.menuHandler = menuHandler
        
        trackerView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerLabel.text = tracker.name
        quantityLabel.text = "\(visualizeCountText(count: count))"
        
        visualizeQuantityAddButton()
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let trackerID = trackerID else { return nil }
        
        let textOfEditSection = NSLocalizedString("text_of_edit_section_in_context_menu_on_trackerCollectionViewCell", comment: "")
        let textOfEditDeleteSection = NSLocalizedString("text_of_delete_section_in_context_menu_on_trackerCollectionViewCell", comment: "")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            return UIMenu(children: [
                UIAction(title: textOfEditSection) { _ in
                    self.menuHandler?(trackerID, .edit)
                },
                UIAction(title: textOfEditDeleteSection, attributes: [.destructive]) { _ in
                    self.menuHandler?(trackerID, .delete)
                }
            ])
        }
    }
    
    @objc private func quantityAddButtonTapped() {
        
        print("Button cilcked")
        
        guard let trackerID = trackerID else { return }
        completionHandler?(trackerID, !isCompleted)
    }
    
    private func addSubviews() {
         [trackerView, quantityView].forEach {
             contentView.addSubview($0)
            }
        
        [emojiLabel, trackerLabel].forEach {
            trackerView.addSubview($0)
           }
        
        [quantityLabel, quantityAddButton].forEach {
            quantityView.addSubview($0)
           }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            trackerLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            trackerLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            
            quantityView.topAnchor.constraint(equalTo: trackerView.bottomAnchor),
            quantityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityView.heightAnchor.constraint(equalToConstant: 58),
            
            quantityLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 12),
            quantityLabel.topAnchor.constraint(equalTo: quantityView.topAnchor, constant: 16),
            quantityLabel.heightAnchor.constraint(equalToConstant: 18),
            
            quantityAddButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: -12),
            quantityAddButton.widthAnchor.constraint(equalToConstant: 34),
            quantityAddButton.heightAnchor.constraint(equalToConstant: 34),
            quantityAddButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 8),
            quantityAddButton.topAnchor.constraint(equalTo: quantityView.topAnchor, constant: 8)
        ])
    }
    
    private func makeTrackerView() -> UIView {
        let trackerView = UIView()
        trackerView.layer.cornerRadius = 16
        trackerView.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        trackerView.addInteraction(interaction)
        
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        
        return trackerView
    }
    
    private func makeEmojiLabel() -> UILabel {
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return emojiLabel
    }
    
    private func makeTrackerLabel() -> UILabel {
        let trackerLabel = UILabel()
        trackerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerLabel.textColor = .white
        trackerLabel.numberOfLines = 2
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return trackerLabel
    }
    
    private func makeQuantityView() -> UIView {
        let quantityView = UIView()
        quantityView.backgroundColor = .ypWhite
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        
        return quantityView
    }
    
    private func makeQuantityLabel() -> UILabel {
        let quantityLabel = UILabel()
        quantityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        quantityLabel.textColor = .ypBlack
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return quantityLabel
    }
    
    private func makeQuantityAddButton() -> UIButton {
        let quantityAddButton = UIButton(type: .system)
        quantityAddButton.layer.cornerRadius = 17
        quantityAddButton.addTarget(self, action: #selector(quantityAddButtonTapped), for: .touchUpInside)
        quantityAddButton.tintColor = .ypWhite
        quantityAddButton.translatesAutoresizingMaskIntoConstraints = false
        
        return quantityAddButton
    }
    
    private func visualizeQuantityAddButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        if isCompleted {
            quantityAddButton.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
            quantityAddButton.backgroundColor = trackerView.backgroundColor?.withAlphaComponent(0.3)
        } else {
            quantityAddButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
            quantityAddButton.backgroundColor = trackerView.backgroundColor
        }
    }
    
    private func visualizeCountText(count: Int) -> String {
        let numberOfDays = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Count of days when trecker is completed"),
            count)
        return numberOfDays
    }
}


