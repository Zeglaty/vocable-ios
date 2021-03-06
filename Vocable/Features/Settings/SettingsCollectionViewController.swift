//
//  SettingsViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import MessageUI

class SettingsCollectionViewController: UICollectionViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet private var headerView: UINavigationItem!

    private weak var composeVC: MFMailComposeViewController?

    // Contact Developers + Privact Policy + Version Number
    private let externalLinksItemCount = 3

    private enum SettingsItem: String, Hashable {
        var title: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }

        var isFeatureEnabled: Bool {
            let debugFeatures: [SettingsItem] = [.categories, .timingSensitivity,
                                                 .resetAppSettings, .pidTuner]
            if debugFeatures.contains(self) {
                return AppConfig.showDebugOptions
            }
            return true
        }

        case editMySayings = "Edit My Sayings"
        case categories = "Categories"
        case timingSensitivity = "Timing and Sensitivity"
        case resetAppSettings = "Reset App Settings"
        case selectionMode = "Selection Mode"
        case privacyPolicy = "Privacy Policy"
        case contactDevs = "Contact Developers"
        case pidTuner = "Tune Cursor"
        case versionNum
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SettingsItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    private var versionAndBuildNumber: String {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(versionNumber)-\(buildNumber)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    func setupNavigationBar() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .collectionViewBackgroundColor
        let textAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.defaultTextColor, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        barAppearance.largeTitleTextAttributes = textAttr
        barAppearance.titleTextAttributes = textAttr
        navigationItem.standardAppearance = barAppearance
        navigationItem.largeTitleDisplayMode = .always

        let dismissBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark.circle")!, style: .plain, target: self, action: #selector(dismissVC))
        dismissBarButton.tintColor = .defaultTextColor

        navigationItem.rightBarButtonItem = dismissBarButton
    }

    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SettingsFooterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsFooterCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsToggleCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsCollectionViewCell")

        updateDataSource()

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SettingsItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.editMySayings,
                              .categories,
                              .timingSensitivity,
                              .resetAppSettings,
                              .selectionMode,
                              .pidTuner,
                              .privacyPolicy,
                              .contactDevs].filter({$0.isFeatureEnabled}))
        snapshot.appendItems([.versionNum])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }

    func createLayout() -> UICollectionViewLayout {
        if case .compact = self.traitCollection.horizontalSizeClass, case .regular = self.traitCollection.verticalSizeClass {
            return compactWidthLayout()
        } else {
            return defaultLayout()
        }
    }

    private func compactWidthLayout() -> UICollectionViewLayout {
        let internalLinksItemCount = dataSource.snapshot().itemIdentifiers.count - externalLinksItemCount

        let settingsButtonItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        settingsButtonItem.contentInsets = .init(top: 4, leading: 0, bottom: 4, trailing: 0)

        let internalLinksGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(CGFloat(internalLinksItemCount) / 9))
        let internalLinksGroup = NSCollectionLayoutGroup.vertical(layoutSize: internalLinksGroupSize, subitem: settingsButtonItem, count: internalLinksItemCount)

        let externalLinksGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(2 / 9))
        let externalLinksGroup = NSCollectionLayoutGroup.vertical(layoutSize: externalLinksGroupSize, subitem: settingsButtonItem, count: 2)
        externalLinksGroup.edgeSpacing = .init(leading: nil, top: .fixed(24), trailing: nil, bottom: nil)

        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/7))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)

        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.8))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: [internalLinksGroup, externalLinksGroup, versionItem])

        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func defaultLayout() -> UICollectionViewLayout {
        let internalLinksItemCount = dataSource.snapshot().itemIdentifiers.count - externalLinksItemCount
        let numOfRows = CGFloat(ceil(Double(internalLinksItemCount) / 2.0))
        let isEvenNumOfItems = internalLinksItemCount.isMultiple(of: 2)
        let columnCount = 2

        let settingsButtonItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1.0)))
        settingsButtonItem.contentInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)

        let internalLinkRowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                              heightDimension: .fractionalHeight(1.0))
        let internalLinkRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: internalLinkRowGroupSize,
                                                                      subitem: settingsButtonItem,
                                                                      count: columnCount)

        let internalLinkContainerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .fractionalHeight((numOfRows == 1 ? numOfRows : numOfRows - 1) / 5))
        let internalLinkContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: internalLinkContainerGroupSize,
                                                                          subitem: internalLinkRowGroup,
                                                                          count: numOfRows == 1 ? Int(numOfRows) : Int(numOfRows - 1))

        let internalLinkLastRowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(isEvenNumOfItems ? 1.0 : 0.5),
                                                                  heightDimension: .fractionalHeight(1 / 5))
        let internalLinkLastRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: internalLinkLastRowGroupSize, subitem: settingsButtonItem, count: isEvenNumOfItems ? 2 : 1)
        internalLinkLastRowGroup.edgeSpacing = .init(leading: nil, top: nil, trailing: nil, bottom: .fixed(24))

        let externalLinkContainerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1 / 5))
        let externalLinkContainerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: externalLinkContainerGroupSize, subitem: settingsButtonItem, count: 2)

        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(80.0 / 834.0))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)

        // If there is one row, only contain last row group in the subitems
        let settingsPageSubItems = (numOfRows == 1) ? [internalLinkLastRowGroup, externalLinkContainerGroup, versionItem]
            : [internalLinkContainerGroup, internalLinkLastRowGroup, externalLinkContainerGroup, versionItem]
        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: settingsPageSubItems)

        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    // MARK: UICollectionViewController

    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SettingsItem) -> UICollectionViewCell {
        switch item {
        case .editMySayings, .categories, .timingSensitivity, .resetAppSettings, .selectionMode:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage(systemName: "chevron.right"))
            return cell
        case .privacyPolicy, .contactDevs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage(systemName: "arrow.up.right"))
            return cell
        case .versionNum:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsFooterCollectionViewCell
            cell.setup(versionLabel: versionAndBuildNumber)
            return cell
        case .pidTuner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage())
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .privacyPolicy:
            let alertString = NSLocalizedString("You're about to be taken outside of the Vocable app. You may lose head tracking control.",
                                                comment: "You're about to be taken outside of the Vocable app. You may lose head tracking control alert message")
            let alertViewController = GazeableAlertViewController(alertTitle: alertString)

            alertViewController.addAction(GazeableAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert action title")))
            alertViewController.addAction(GazeableAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm alert action title"), handler: self.presentPrivacyAlert))
            present(alertViewController, animated: true)

        case .editMySayings:
            if let vc = self.storyboard?.instantiateViewController(identifier: "MySayings") {
                show(vc, sender: nil)
            }
        case .selectionMode:
            presentSelectionModeViewController()
        case .contactDevs:
            let alertString = NSLocalizedString("You're about to be taken outside of the Vocable app. You may lose head tracking control.",
                                                comment: "You're about to be taken outside of the Vocable app. You may lose head tracking control alert message")
            let alertViewController = GazeableAlertViewController(alertTitle: alertString)

            alertViewController.addAction(GazeableAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert action title")))
            alertViewController.addAction(GazeableAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm alert action title"), handler: self.presentEmail))
            present(alertViewController, animated: true)

        case .pidTuner:
            guard let gazeWindow = view.window as? HeadGazeWindow else { return }
            for child in gazeWindow.rootViewController?.children ?? [] {
                if let child = child as? UIHeadGazeViewController {
                    child.pidInterpolator.pidSmoothingInterpolator.pulse.showTunningView(minimumValue: -1.0, maximumValue: 1.0)
                    gazeWindow.cursorView?.isDebugCursorHidden = false
                }
            }
        default:
            break
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .versionNum:
            return false
        case .pidTuner:
            return AppConfig.isHeadTrackingEnabled
        default:
            return true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .versionNum:
            return false
        case .pidTuner:
            return AppConfig.isHeadTrackingEnabled
        default:
            return true
        }
    }

    private func toggleHeadTracking() {
        AppConfig.isHeadTrackingEnabled.toggle()
    }

    // MARK: Presentations

    private func presentPrivacyAlert() {
        let url = URL(string: "https://vocable.app/privacy.html")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func presentEmail() {

        guard MFMailComposeViewController.canSendMail() else {
            NSLog("Mail composer failed to send mail", [])
            return
        }

        guard composeVC == nil else {
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["vocable@willowtreeapps.com"])
        composeVC.setSubject("Feedback for Vocable v\(versionAndBuildNumber)")
        self.composeVC = composeVC

        self.present(composeVC, animated: true)
    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func presentSelectionModeViewController() {
        let storyboard = UIStoryboard(name: "SelectionMode", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
