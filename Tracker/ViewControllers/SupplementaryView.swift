//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 01.09.2025.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    private var leadingConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        let constraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        leadingConstraint = constraint
        
        NSLayoutConstraint.activate([
            constraint,
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configure(title: String, leadingInset: CGFloat) {
        titleLabel.text = title
        leadingConstraint?.constant = leadingInset
    }
}
