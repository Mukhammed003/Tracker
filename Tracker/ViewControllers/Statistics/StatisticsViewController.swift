//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit
import SwiftUICore

final class StatisticsViewController: UIViewController {
    
    private let gradientColors: [UIColor] = [
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1),
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1),
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
    ]
    
    private lazy var mainStack = UIStackView()
    private lazy var bestPeriod: (view: GradientBorderView, valueLabel: UILabel) =
        makeStatisticBlock(valueText: "0", descriptionKey: "text_of_bestPeriodLabel_in_statistcs_page", colors: gradientColors)
    private lazy var perfectDays: (view: GradientBorderView, valueLabel: UILabel) =
        makeStatisticBlock(valueText: "0", descriptionKey: "text_of_perfectDaysLabel_in_statistcs_page", colors: gradientColors)
    private lazy var completedTrackers: (view: GradientBorderView, valueLabel: UILabel) =
        makeStatisticBlock(valueText: "0", descriptionKey: "text_of_completedTrackersLabel_in_statistcs_page", colors: gradientColors)
    private lazy var averageValueBlock: (view: GradientBorderView, valueLabel: UILabel) =
        makeStatisticBlock(valueText: "0", descriptionKey: "text_of_averageValueLabel_in_statistcs_page", colors: gradientColors)
    
    // nothing toAnalyze view
    private lazy var nothingToAnalyzeView: UIView = makeNothingToAnalyzeView()
    private lazy var nothingToAnalyzeImage: UIImageView = makeNothingToAnalyzeImage()
    private lazy var nothingToAnalyzeLabel: UILabel = makeNothingToAnalyzeLabel()
    
    private let storage = Storage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavBar()
        setupStatisticsStack()
        setupNothingToAnalyzeView()
        
        showNeedScreen()
    }
    
    private func loadDataForStatistics() {
        bestPeriod.valueLabel.text = "\(Int(storage.loadBestPeriodValue()))"
        perfectDays.valueLabel.text = "\(Int(storage.loadPerfectDaysValue()))"
        completedTrackers.valueLabel.text = "\(Int(storage.loadCompletedTrackersValue()))"
        averageValueBlock.valueLabel.text = "\(Int(storage.loadAverageValue().rounded()))"
    }
    
    private func showNeedScreen() {
        if checkIsExisteAnyDataToAnalyze() {
            nothingToAnalyzeView.isHidden = true
            mainStack.isHidden = false
            loadDataForStatistics()
        } else {
            nothingToAnalyzeView.isHidden = false
            mainStack.isHidden = true
        }
    }
    
    private func checkIsExisteAnyDataToAnalyze() -> Bool {
        let completedTrackers = storage.loadCompletedTrackersValue()
        
        return completedTrackers.isEqual(to: 0) ? false : true
    }
    
    private func setupNavBar() {
        let titleOfNavBarOnStatisticsPage = NSLocalizedString("header_of_statistics_page", comment: "")
        
        title = titleOfNavBarOnStatisticsPage
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupStatisticsStack() {
        mainStack = UIStackView(arrangedSubviews: [
            bestPeriod.view,
            perfectDays.view,
            completedTrackers.view,
            averageValueBlock.view
        ])
    
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.distribution = .fillEqually
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStack.heightAnchor.constraint(equalToConstant: 90 * 4 + 12 * 3) // 4 блока + 3 промежутка
        ])
    }
    
    private func makeStatisticBlock(valueText: String, descriptionKey: String, colors: [UIColor]) -> (view: GradientBorderView, valueLabel: UILabel) {
        let containerView = GradientBorderView()
        containerView.colors = colors
        containerView.lineWidth = 1
        containerView.cornerRadiusValue = 16
        containerView.backgroundColor = .ypWhite
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = createUILabel(
            textOfLabel: valueText,
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 34,
            weightOfLabel: .bold
        )

        let descriptionLabel = createUILabel(
            textOfLabel: NSLocalizedString(descriptionKey, comment: ""),
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 12,
            weightOfLabel: .medium
        )

        containerView.addSubview(valueLabel)
        containerView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            valueLabel.heightAnchor.constraint(equalToConstant: 41),

            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])

        return (containerView, valueLabel)
    }
    
    private func setupNothingToAnalyzeView() {
        nothingToAnalyzeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nothingToAnalyzeView)
        
        nothingToAnalyzeView.addSubview(nothingToAnalyzeImage)
        nothingToAnalyzeView.addSubview(nothingToAnalyzeLabel)
        
        NSLayoutConstraint.activate([
            nothingToAnalyzeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nothingToAnalyzeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nothingToAnalyzeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nothingToAnalyzeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nothingToAnalyzeImage.heightAnchor.constraint(equalToConstant: 80),
            nothingToAnalyzeImage.widthAnchor.constraint(equalToConstant: 80),
            nothingToAnalyzeImage.centerXAnchor.constraint(equalTo: nothingToAnalyzeView.centerXAnchor),
            nothingToAnalyzeImage.centerYAnchor.constraint(equalTo: nothingToAnalyzeView.centerYAnchor),
            
            nothingToAnalyzeLabel.leadingAnchor.constraint(equalTo: nothingToAnalyzeView.leadingAnchor, constant: 16),
            nothingToAnalyzeLabel.topAnchor.constraint(equalTo: nothingToAnalyzeImage.bottomAnchor, constant: 8),
            nothingToAnalyzeLabel.trailingAnchor.constraint(equalTo: nothingToAnalyzeView.trailingAnchor, constant: -16)
        ])
    }
    
    private func makeNothingToAnalyzeImage() -> UIImageView {
        let nothingToanalyzeImage = UIImage(resource: .nothingToAnalyze)
        let nothingToAnalyzeImageView = UIImageView(image: nothingToanalyzeImage)
        nothingToAnalyzeImageView.clipsToBounds = true
        
        nothingToAnalyzeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return nothingToAnalyzeImageView
    }
    
    private func makeNothingToAnalyzeLabel() -> UILabel {
        let textOfNothingToAnalyzeLabel = NSLocalizedString("text_of_nothingToAnalyzeLabel_on_statistics_page", comment: "")
        
        let nothingToAnalyzeLabel = createUILabel(
            textOfLabel: textOfNothingToAnalyzeLabel,
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 12,
            weightOfLabel: .medium)
        
        nothingToAnalyzeLabel.textAlignment = .center
        
        return nothingToAnalyzeLabel
    }
    
    private func makeNothingToAnalyzeView() -> UIView {
        let nothingToAnalyzeView = UIView()
        
        return nothingToAnalyzeView
    }
    
    private func createUILabel(textOfLabel exampleText: String, letterSpacing kern: CGFloat, colorOfLabel foregroundColor: UIColor, fontSizeOfLabel fontSize: CGFloat, weightOfLabel weight: UIFont.Weight) -> UILabel {
        let exampleLabel = UILabel()
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSAttributedString(
            string: exampleText,
            attributes: [
                .kern: kern,
                .foregroundColor: foregroundColor,
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight)
            ]
        )
        exampleLabel.attributedText = attributedString
        
        return exampleLabel
    }
}
