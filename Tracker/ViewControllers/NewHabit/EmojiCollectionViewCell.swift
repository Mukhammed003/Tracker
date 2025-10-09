//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 22.09.2025.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private static let identifier = Constants.emojiCollectionViewCellIdentifier
    
    private lazy var emojiLabel: UILabel = makeEmojiLabel()
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .ypLightGray : .systemBackground
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configure(_ emoji: String) {
        emojiLabel.text = emoji
    }
    
    private func addSubviews() {
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layer.cornerRadius = 16
    }
    
    private func makeEmojiLabel() -> UILabel {
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        emojiLabel.textAlignment = .center
        emojiLabel.textColor = .black
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return emojiLabel
    }
}
