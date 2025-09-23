//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 22.09.2025.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    private static let identifier = Constants.colorCollectionViewCellIdentifier
    
    private lazy var colorView: UIView = makeColorView()
    private lazy var backgroundViewForBorder: UIView = makeBackgroundView()
    
    override var isSelected: Bool {
        didSet {
            backgroundViewForBorder.layer.borderColor = isSelected
            ? colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            : UIColor.systemBackground.cgColor
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
    
    func configure(_ color: UIColor) {
        colorView.backgroundColor = color
    }
    
    private func addSubviews() {
        contentView.addSubview(backgroundViewForBorder)
        contentView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundViewForBorder.widthAnchor.constraint(equalToConstant: 52),
            backgroundViewForBorder.heightAnchor.constraint(equalToConstant: 52),
            backgroundViewForBorder.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundViewForBorder.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func makeColorView() -> UIView {
        let colorView = createUIView()
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        return colorView
    }
    
    private func makeBackgroundView() -> UIView {
        let backgroundViewForBorder = createUIView()
        backgroundViewForBorder.layer.cornerRadius = 10
        backgroundViewForBorder.backgroundColor = .systemBackground
        backgroundViewForBorder.layer.borderWidth = 3
        backgroundViewForBorder.layer.borderColor = UIColor.systemBackground.cgColor
        backgroundViewForBorder.translatesAutoresizingMaskIntoConstraints = false
        
        return backgroundViewForBorder
    }
    
    private func createUIView() -> UIView {
        let uIView = UIView()
        
        return uIView
    }
}
