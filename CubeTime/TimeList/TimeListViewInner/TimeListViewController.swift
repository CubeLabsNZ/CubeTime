import Foundation
import UIKit
import SwiftUI
import Combine


class TimeCardCell: UICollectionViewCell {
    lazy var timeCardView: TimeCardView = {
        return TimeCardView(frame: CGRect(origin: .zero, size: self.frame.size))
    }()
    
    var item: Solve!
    let label = TimeCardLabel()
    weak var viewController: TimeListViewController?
    var gesture: UITapGestureRecognizer!
    var switchedToStackView = false
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.backgroundColor = UIColor(named: isSelected ? "indent0" : "overlay0")!.cgColor
        
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        
        self.label.textAlignment = .center
        
        
        self.label.font = FontManager.fontFor(size: 17, weight: 650)
        self.label.isUserInteractionEnabled = false
        
        self.label.numberOfLines = 1
        self.label.minimumScaleFactor = 0.25
        self.label.adjustsFontSizeToFitWidth = true
        
        self.contentView.addSubview(label)
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        if self.isSelected && !switchedToStackView {
            switchedToStackView = true
            label.removeFromSuperview()
            self.contentView.addSubview(timeCardView)
            
            timeCardView.frame = contentView.bounds
            timeCardView.insertArrangedSubview(label, at: 1)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 1) { [weak self] in
            guard let self else { return }
            self.layer.backgroundColor = UIColor(named: self.isSelected ? "indent0" : "overlay0")!.cgColor
        }
        
        if switchedToStackView && (self.timeCardView.checkbox.isHidden != !self.isSelected) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 1) { [weak self] in
                guard let self else {return}
                self.timeCardView.checkbox.isHidden = !self.isSelected
            }
        }
    }
}

final class TimeListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Solve>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Solve>
    private let timeResuseIdentifier = "TimeCard"
    @Preference(\.promptDelete) private var promptDelete
    
    
    #warning("TODO: subscribe to changes of dynamic type?")
    private lazy var cardHeight: CGFloat = {
        if traitCollection.preferredContentSizeCategory > UIContentSizeCategory.extraLarge {
            return 60
        } else if traitCollection.preferredContentSizeCategory < UIContentSizeCategory.small {
            return 50
        } else {
            return 55
        }
    }()
    
    lazy private var columnCount: CGFloat = {
        if traitCollection.preferredContentSizeCategory > UIContentSizeCategory.extraLarge {
            return 2
        } else if traitCollection.preferredContentSizeCategory < UIContentSizeCategory.small {
            return 4
        } else {
            return 3
        }
    }()

    
    var isSelecting = false {
        didSet {
            if isSelecting == false {
                collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                    collectionView.deselectItem(at: indexPath, animated: true)
                    if let solve = dataSource.itemIdentifier(for: indexPath) { // For some reason .removeAll causes hang..
                        stopwatchManager.timeListSolvesSelected.remove(solve)
                    }
                }
            }
            
            collectionView.allowsSelection = isSelecting
            collectionView.allowsMultipleSelection = isSelecting
        }
    }
    
    let stopwatchManager: StopwatchManager
    let onClickSolve: (Solve) -> ()
    
    var subscribers: Set<AnyCancellable> = []
    var shownPhase: Int16? = nil
    
    lazy var dataSource = makeDataSource()
    
    init(stopwatchManager: StopwatchManager, onClickSolve: @escaping (Solve) -> ()) {
        self.stopwatchManager = stopwatchManager
        self.onClickSolve = onClickSolve
        
        
        let layout = UICollectionViewFlowLayout()
        
        super.init(collectionViewLayout: layout)
        
        stopwatchManager.$timeListSolvesFiltered
            .sink(receiveValue: { [weak self] i in
                self?.applySnapshot(i)
            })
            .store(in: &subscribers)
        
        stopwatchManager.$timeListShownPhase
            .sink(receiveValue: { [weak self] newValue in
                self?.shownPhase = newValue
                self?.collectionView.reloadData()
            })
            .store(in: &subscribers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleCellTap(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view as? TimeCardCell, !self.collectionView.allowsSelection {
            onClickSolve(view.item)
        }
    }
    
    func makeDataSource() -> DataSource {
        let solveCellRegistration = UICollectionView.CellRegistration<TimeCardCell, Solve> { [weak self] cell, _, item in
            guard let self else { return }
            
            if let multiphaseSolve = item as? MultiphaseSolve,
               let phase = shownPhase,
               let phases = multiphaseSolve.phases,
               let time = ([0] + phases).chunked().map({ $0[1] - $0[0] })[safe: Int(phase)] {
                cell.label.text = formatSolveTime(secs: time)
            } else {
                cell.label.text = item.timeText
            }
            cell.label.frame = CGRect(origin: .zero, size: cell.frame.size)
            
            cell.item = item
            cell.gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
            cell.gesture.cancelsTouchesInView = false
            cell.addGestureRecognizer(cell.gesture)
            cell.viewController = self
        }
        
        return DataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: solveCellRegistration, for: indexPath, item: item)
        }
    }
    
    func applyInitialSnapshots() {
        var categorySnapshot = Snapshot()
        
        categorySnapshot.appendSections([0])
        categorySnapshot.appendItems(stopwatchManager.timeListSolvesFiltered, toSection: 0)
        
        dataSource.apply(categorySnapshot, animatingDifferences: false)
    }
    
    func applySnapshot(_ newArg: [Solve]? = nil, animatingDifferences: Bool = true) {
        let new = newArg ?? stopwatchManager.timeListSolvesFiltered!
        var categorySnapshot = Snapshot()
        
        categorySnapshot.appendSections([0])
        categorySnapshot.appendItems(new, toSection: 0)
        
        dataSource.apply(categorySnapshot, animatingDifferences: animatingDifferences)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.layer.backgroundColor = UIColor.clear.cgColor
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsSelection = false
        self.collectionView.allowsMultipleSelection = false
        
        applyInitialSnapshots()
        
        stopwatchManager.timeListReloadSolve = { [weak self] solve in
            guard let self else { return }
            
            var categorySnapshot = Snapshot()
            
            
            categorySnapshot.appendSections([0])
            categorySnapshot.appendItems(self.stopwatchManager.timeListSolvesFiltered, toSection: 0)
            categorySnapshot.reconfigureItems([solve])
            
            self.dataSource.apply(categorySnapshot, animatingDifferences: false)
        }
        
        stopwatchManager.timeListSelectAll = { [weak self] in
            guard let self else { return }
            
            for solve in self.stopwatchManager.timeListSolvesFiltered {
                if let idxpath = self.dataSource.indexPath(for: solve) {
                    self.collectionView.selectItem(at: idxpath, animated: true, scrollPosition: [])
                    self.stopwatchManager.timeListSolvesSelected.insert(solve)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopwatchManager.timeListSolvesSelected.removeAll()
    }
    
    deinit {
        stopwatchManager.timeListReloadSolve = nil
        stopwatchManager.timeListSelectAll = nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopwatchManager.timeListSolvesFiltered.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let solve = dataSource.itemIdentifier(for: indexPath) else { return UIContextMenuConfiguration() }
        
        let copy = UIAction(title: NSLocalizedString("Copy", comment: "locale"), image: UIImage(systemName: "doc.on.doc")) { _ in
            copySolve(solve: solve)
        }
        
        let pen = Penalty(rawValue: solve.penalty)!
        let penNone = UIAction(title: NSLocalizedString("No Penalty", comment: "locale"), image: UIImage(systemName: "checkmark.circle"), state: pen == .none ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .none)
        }
        let penPlusTwo = UIAction(title: "+2", image: UIImage(named: "+2.label"), state: pen == .plustwo ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .plustwo)
        }
        let penDNF = UIAction(title: "DNF", image: UIImage(systemName: "xmark.circle"), state: pen == .dnf ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .dnf)
        }
        
        let penaltyMenu = UIMenu(title: NSLocalizedString("Penalty", comment: "locale"), image: UIImage(systemName: "exclamationmark.triangle"), options: .singleSelection, children: [penNone, penPlusTwo, penDNF])
        
        
        let sessions = (stopwatchManager.currentSession.sessionType == SessionType.playground.rawValue ?
            stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scrambleType)] :
            stopwatchManager.sessionsCanMoveTo)!
        
        let unpinnedidx = sessions.firstIndex(where: {!$0.pinned}) ?? sessions.count
        let pinned = sessions[0..<unpinnedidx]
        let unpinned = sessions[unpinnedidx..<sessions.count]
        
        let pinnedMenuItems = pinned.map { session in
            UIAction(title: session.name!, image: UIImage(systemName: SessionType(rawValue: session.sessionType)!.iconName())) {_ in
                self.stopwatchManager.moveSolve(solve: solve, to: session)
            }
        }
        
        let unpinnedMenuItems = unpinned.map { session in
            UIAction(title: session.name!, image: UIImage(systemName: SessionType(rawValue: session.sessionType)!.iconName())) {_ in
                self.stopwatchManager.moveSolve(solve: solve, to: session)
            }
        }
        
        var moveToChildren: [UIMenuElement] = [
            UIAction(title: NSLocalizedString("Only compatible sessions are shown", comment: "locale"), attributes: .disabled) {_ in}
        ]
        
        if pinnedMenuItems.count > 0 {
            moveToChildren.append(UIMenu(title: NSLocalizedString("Pinned Sessions", comment: "locale"), options: .displayInline, children: pinnedMenuItems))
        }
        
        if unpinnedMenuItems.count > 0 {
            moveToChildren.append(UIMenu(title: NSLocalizedString("Other Sessions", comment: "locale") , options: .displayInline, children: unpinnedMenuItems))
        }
        
        let moveToMenu = UIMenu(title: NSLocalizedString("Move To", comment: "locale"), image: UIImage(systemName: "arrow.up.right"), children: moveToChildren)
        
        let delete = UIMenu(options: [.destructive, .displayInline], children: [ // For empty divide line
            UIAction(title: NSLocalizedString("Delete", comment: "locale"), image: UIImage(systemName: "trash"), attributes: .destructive) {_ in
                
                if(self.promptDelete){
                    let alert = UIAlertController(title: NSLocalizedString("Confirm Delete", comment: "locale"), message: "Are you sure you want to delete this solve?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "locale"), style: .destructive, handler: { _ in
                        // Perform the delete action if confirmed
                        self.stopwatchManager.delete(solve: solve)
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "locale"), style: .cancel, handler: nil))
                    
                    if let viewController = self.navigationController?.visibleViewController{
                        viewController.present(alert, animated: true, completion: nil)
                    }
                }
                else{
                    self.stopwatchManager.delete(solve: solve)
                }
            }
        ])
        
        
        let menuConfig = UIMenu(children: [copy, penaltyMenu, moveToMenu, delete])
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: { _ in
            return menuConfig
        })
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelecting {
            self.stopwatchManager.timeListSolvesSelected.insert(self.stopwatchManager.timeListSolvesFiltered[indexPath.item])
        } else {
            onClickSolve(stopwatchManager.timeListSolvesFiltered[indexPath.item])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isSelecting {
            self.stopwatchManager.timeListSolvesSelected.remove(self.stopwatchManager.timeListSolvesFiltered[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - 32 - 10*(columnCount-1))/columnCount
        return CGSize(width: width.rounded(.down), height: cardHeight)
    }
}


struct TimeListInner: UIViewControllerRepresentable {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @Binding var isSelectMode: Bool
    @Binding var currentSolve: Solve?
    
    func makeUIViewController(context: Context) -> TimeListViewController {
        let timeListViewController = TimeListViewController(stopwatchManager: stopwatchManager, onClickSolve: { solve in
            currentSolve = solve
        })
        
        let size = timeListViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        timeListViewController.preferredContentSize = size
        timeListViewController.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 50 + 8, right: 0)
        
        return timeListViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        DispatchQueue.main.async {
            uiViewController.isSelecting = isSelectMode
        }
    }
}
