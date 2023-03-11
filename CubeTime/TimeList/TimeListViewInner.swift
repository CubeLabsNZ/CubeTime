import Foundation
import UIKit
import SwiftUI
import Combine

class MyCell : UICollectionViewCell {
    let label = UILabel()
    var item: Solves!
    weak var viewController: TimeListViewController?
    var gesture: UITapGestureRecognizer!
    
    required init?(coder: NSCoder) {
        fatalError("nope!")
    }
    
    override init(frame: CGRect) {
        NSLog("CELL INIT: x \(frame.minX), y \(frame.minY)")
        super.init(frame: frame)
        label.frame = CGRect(origin: .zero, size: frame.size)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.isUserInteractionEnabled = false
        contentView.addSubview(label)

        layer.backgroundColor = UIColor(named: isSelected ? "indent0" : "overlay0")!.cgColor
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 1) {
            self.layer.backgroundColor = UIColor(named: self.isSelected ? "indent0" : "overlay0")!.cgColor
        }
    }
    
    deinit {
        NSLog("CELL DEINITIALISED: x: \(frame.minX), y: \(frame.minY)")
    }
}

final class TimeListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Solves>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Solves>
    private let timeResuseIdentifier = "TimeCard"
    
    private var cardHeight: CGFloat {
        if traitCollection.preferredContentSizeCategory > UIContentSizeCategory.extraLarge {
            return 60
        } else if traitCollection.preferredContentSizeCategory < UIContentSizeCategory.small {
            return 50
        } else {
            return 55
        }
    }
    private var columnCount: Int {
        if traitCollection.preferredContentSizeCategory > UIContentSizeCategory.extraLarge {
            return 2
        } else if traitCollection.preferredContentSizeCategory < UIContentSizeCategory.small {
            return 4
        } else {
            return 3
        }
    }

    
    var mySelecting = false {
        didSet {
            // Clear selection
            if mySelecting == false {
                collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                    collectionView.deselectItem(at: indexPath, animated: true)
                    if let solve = dataSource.itemIdentifier(for: indexPath) { // For some reason .removeAll causes hang..
                        stopwatchManager.timeListSolvesSelected.remove(solve)
                    }
                }
            }
            NSLog("DIDSET mySelecting to \(mySelecting)")
            collectionView.allowsSelection = mySelecting
            collectionView.allowsMultipleSelection = mySelecting
        }
    }
    
    let stopwatchManager: StopwatchManager
    let onClickSolve: (Solves) -> ()
    
    var subscriber: AnyCancellable?
//    var subscriber2: AnyCancellable?
    
    lazy var dataSource = makeDataSource()
    
    init(stopwatchManager: StopwatchManager, onClickSolve: @escaping (Solves) -> ()) {
        self.stopwatchManager = stopwatchManager
        self.onClickSolve = onClickSolve
        
        
        let layout = UICollectionViewFlowLayout()
        
        super.init(collectionViewLayout: layout)
        
        subscriber = stopwatchManager.$timeListSolvesFiltered
            .sink(receiveValue: { [weak self] i in
                NSLog("Recieved value timelistsolvesfiltersd")
                self?.applySnapshot(i)
            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleCellTap(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view as? MyCell, !self.collectionView.allowsSelection {
            onClickSolve(view.item)
        }
    }
    
    func makeDataSource() -> DataSource {
        let solveCellRegistration = UICollectionView.CellRegistration<MyCell, Solves> { [weak self] cell, _, item in
            guard let self else { return }
            
            cell.label.text = item.timeText
            cell.item = item
            cell.gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCellTap(_:)))
            cell.gesture.cancelsTouchesInView = false
            cell.addGestureRecognizer(cell.gesture)
            cell.viewController = self
            NSLog("DID cell something")
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
    
    func applySnapshot(_ newArg: [Solves]? = nil, animatingDifferences: Bool = true) {
        let new = newArg ?? stopwatchManager.timeListSolvesFiltered!
        var categorySnapshot = Snapshot()
        
        categorySnapshot.appendSections([0])
        categorySnapshot.appendItems(new, toSection: 0)
        
        dataSource.apply(categorySnapshot, animatingDifferences: animatingDifferences)
    }
    
    override func viewDidLoad() {
        NSLog("VIEWDID LOAD TIMELISTINNER")
        super.viewDidLoad()
        self.collectionView.layer.backgroundColor = UIColor.clear.cgColor
        
//        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: timeResuseIdentifier)
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
            
            for idxpath in self.collectionView.indexPathsForVisibleItems {
                self.collectionView.selectItem(at: idxpath, animated: true, scrollPosition: [])
                if let solve = self.dataSource.itemIdentifier(for: idxpath) {
                    self.stopwatchManager.timeListSolvesSelected.insert(solve)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        print("DISAPPEAR CALLED")
    }
    
    deinit {
        print("DEININT CALLED")
        stopwatchManager.timeListReloadSolve = nil
        stopwatchManager.timeListSelectAll = nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopwatchManager.timeListSolvesFiltered.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        NSLog("called contextmenuitem")
        guard let solve = dataSource.itemIdentifier(for: indexPath) else { return UIContextMenuConfiguration() }
        
        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
            copySolve(solve: solve)
        }
        
        let pen = Penalty(rawValue: solve.penalty)!
        let penNone = UIAction(title: "No Penalty", image: UIImage(systemName: "checkmark.circle"), state: pen == .none ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .none)
        }
        let penPlusTwo = UIAction(title: "+2", image: UIImage(named: "+2.label"), state: pen == .plustwo ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .plustwo)
        }
        let penDNF = UIAction(title: "DNF", image: UIImage(systemName: "xmark.circle"), state: pen == .dnf ? .on : .off) { _ in
            self.stopwatchManager.changePen(solve: solve, pen: .dnf)
        }
        
        let penaltyMenu = UIMenu(title: "Penalty", image: UIImage(systemName: "exclamationmark.triangle"), options: .singleSelection, children: [penNone, penPlusTwo, penDNF])
        
        
        let sessions = (stopwatchManager.currentSession.session_type == SessionType.playground.rawValue ?
            stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scramble_type)] :
            stopwatchManager.sessionsCanMoveTo)!
        
        let unpinnedidx = sessions.firstIndex(where: {!$0.pinned}) ?? sessions.count
        let pinned = sessions[0..<unpinnedidx]
        let unpinned = sessions[unpinnedidx..<sessions.count]
        
        let pinnedMenuItems = pinned.map { session in
            UIAction(title: session.name!, image: UIImage(systemName: iconNamesForType[SessionType(rawValue:session.session_type)!]!)) {_ in
                self.stopwatchManager.moveSolve(solve: solve, to: session)
            }
        }
        
        let unpinnedMenuItems = unpinned.map { session in
            UIAction(title: session.name!, image: UIImage(systemName: iconNamesForType[SessionType(rawValue:session.session_type)!]!)) {_ in
                self.stopwatchManager.moveSolve(solve: solve, to: session)
            }
        }
        
        var moveToChildren: [UIMenuElement] = [
            UIAction(title: "Only compatible sessions are shown", attributes: .disabled) {_ in}
        ]
        
        if pinnedMenuItems.count > 0 {
            moveToChildren.append(UIMenu(title: "Pinned Sessions", options: .displayInline, children: pinnedMenuItems))
        }
        
        if unpinnedMenuItems.count > 0 {
            moveToChildren.append(UIMenu(title: "Other Sessions", options: .displayInline, children: unpinnedMenuItems))
        }
        
        let moveToMenu = UIMenu(title: "Move To", image: UIImage(systemName: "arrow.up.right"), children: moveToChildren)
        
        let delete = UIMenu(options: [.destructive, .displayInline], children: [ // For empty divide line
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) {_ in
                self.stopwatchManager.delete(solve: solve)
            }
        ])
        
        let menuConfig = UIMenu(children: [copy, penaltyMenu, moveToMenu, delete])
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: { _ in
            return menuConfig
        })
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mySelecting {
//            DispatchQueue.main.async {
                self.stopwatchManager.timeListSolvesSelected.insert(self.stopwatchManager.timeListSolvesFiltered[indexPath.item])
//            }
        } else {
            onClickSolve(stopwatchManager.timeListSolvesFiltered[indexPath.item])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mySelecting {
//            DispatchQueue.main.async {
                self.stopwatchManager.timeListSolvesSelected.remove(self.stopwatchManager.timeListSolvesFiltered[indexPath.item])
//            }
            NSLog("DESELETED")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32 - 10*2)/3
        return CGSize(width: width, height: cardHeight)
//        return CGSize(width: 100, height: 100)

    }
}


struct TimeListInner: UIViewControllerRepresentable {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @Binding var isSelectMode: Bool
    @Binding var currentSolve: Solves?
    
    func makeUIViewController(context: Context) -> TimeListViewController {
        let vc = TimeListViewController(stopwatchManager: stopwatchManager, onClickSolve: { solve in
            currentSolve = solve
        })
        let size = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        vc.preferredContentSize = size
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.mySelecting = isSelectMode
    }
}
