import Foundation
import UIKit
import SwiftUI
import Combine

class MyCell : UICollectionViewCell {
    let label = UILabel()

    required init?(coder: NSCoder) {
        fatalError("nope!")
    }
    
    override init(frame: CGRect) {
        NSLog("MYCELL INIT: x \(frame.minX), y \(frame.minY)")
        super.init(frame: frame)
        // create a new label and add it to the cell's content view
//        let label = UILabel(frame: cell.contentView.bounds)
        label.frame = CGRect(origin: .zero, size: frame.size)
        label.textAlignment = .center
//        let solve = stopwatchManager.timeListSolvesFiltered[indexPath.item]
//        label.text = solve.timeText
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.isUserInteractionEnabled = false
        contentView.addSubview(label)

        // configure the cell's appearance (optional)
        layer.backgroundColor = UIColor(named: isSelected ? "indent0" : "overlay0")!.cgColor
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        NSLog("CELL UPDATE CONFIGURATIon")
        layer.backgroundColor = UIColor(named: isSelected ? "indent0" : "overlay0")!.cgColor
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
//            collectionView.allowsSelection = mySelecting
            // Clear selection
            collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                collectionView.deselectItem(at: indexPath, animated: true)
                deselect(indexPath: indexPath)
            }
            NSLog("DIDSET mySelecting to \(mySelecting)")
            collectionView.allowsMultipleSelection = mySelecting
        }
    }
    
    let stopwatchManager: StopwatchManager
    let onClickSolve: (Solves) -> ()
    
    var subscriber: AnyCancellable?
    var subscriber2: AnyCancellable?
    
    lazy var dataSource = makeDataSource()
    
    init(stopwatchManager: StopwatchManager, onClickSolve: @escaping (Solves) -> ()) {
        self.stopwatchManager = stopwatchManager
        self.onClickSolve = onClickSolve
        
        
        let layout = UICollectionViewFlowLayout()
        
        super.init(collectionViewLayout: layout)
        
        subscriber = stopwatchManager.$timeListSolvesFiltered
            .sink(receiveValue: { [weak self] i in
                NSLog("timelistsolvesfiltered cahnges")
                self?.applySnapshot()
            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let solveCellRegistration = UICollectionView.CellRegistration<MyCell, Solves> { cell, _, item in
        // 3
        cell.label.text = item.timeText
        NSLog("DID cell something")
    }
    
    func makeDataSource() -> DataSource {
        // 1
        return DataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            // 2
            return collectionView.dequeueConfiguredReusableCell(
                using: self.solveCellRegistration, for: indexPath, item: item)
        }
    }
    
    func applyInitialSnapshots() {
        var categorySnapshot = Snapshot()
        
        categorySnapshot.appendSections([0])
        categorySnapshot.appendItems(stopwatchManager.timeListSolvesFiltered, toSection: 0)
        
        dataSource.apply(categorySnapshot, animatingDifferences: false)
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var categorySnapshot = Snapshot()
        
        categorySnapshot.appendSections([0])
        categorySnapshot.appendItems(stopwatchManager.timeListSolvesFiltered, toSection: 0)
        
        dataSource.apply(categorySnapshot, animatingDifferences: animatingDifferences)
    }
    
    override func viewDidLoad() {
        NSLog("VIEWDID LOAD TIMELISTINNER")
        super.viewDidLoad()
        self.collectionView.layer.backgroundColor = UIColor.clear.cgColor
        
//        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: timeResuseIdentifier)
        self.collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsSelection = true
        self.collectionView.allowsMultipleSelection = false
        applyInitialSnapshots()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopwatchManager.timeListSolvesFiltered.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
            print("Action 1 tapped for cell \(indexPath)")
        }
        
        
        let penNone = UIAction(title: "No Penalty", image: UIImage(systemName: "checkmark.circle")) { _ in
            print("no pen tapped for cell \(indexPath)")
        }
        let penPlusTwo = UIAction(title: "+2", image: UIImage(named: "+2.label")) { _ in
            print("+2 tapped for cell \(indexPath)")
        }
        let penDNF = UIAction(title: "DNF", image: UIImage(systemName: "xmark.circle")) { _ in
            print("DNF tapped for cell \(indexPath)")
        }
        
        let penaltyMenu = UIMenu(title: "Penalty", image: UIImage(systemName: "exclamationmark.triangle"), children: [penNone, penPlusTwo, penDNF])
        
        
        let menuConfig = UIMenu(children: [copy, penaltyMenu])
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: { _ in
            return menuConfig
        })
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mySelecting {
            stopwatchManager.timeListSolvesSelected.insert(stopwatchManager.timeListSolvesFiltered[indexPath.item])
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.backgroundColor = UIColor(named: "indent0")?.cgColor
            NSLog("SELECTED: \(collectionView.indexPathsForSelectedItems)")
        } else {
            onClickSolve(stopwatchManager.timeListSolvesFiltered[indexPath.item])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mySelecting {
            deselect(indexPath: indexPath)
            NSLog("DESELETED")
        }
    }
    
    func deselect(indexPath: IndexPath) {
        stopwatchManager.timeListSolvesSelected.remove(stopwatchManager.timeListSolvesFiltered[indexPath.item])
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor(named: "overlay0")?.cgColor
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
