import Foundation
import UIKit
import SwiftUI

final class TimeListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let timeResuseIdentifier = "TimeCard"
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        NSLog("VIEWDID LOAD TIMELISTINNER")
        super.viewDidLoad()
        self.collectionView.layer.backgroundColor = UIColor.clear.cgColor
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: timeResuseIdentifier)
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timeResuseIdentifier, for: indexPath)
        
        // remove any existing labels from the cell's content view
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // create a new label and add it to the cell's content view
        let label = UILabel(frame: cell.contentView.bounds)
        label.textAlignment = .center
        label.text = "\(indexPath.item)"
        cell.contentView.addSubview(label)
        
        // configure the cell's appearance (optional)
        cell.backgroundColor = .white
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftAndRightPaddings: CGFloat = 45.0
        let numberOfItemsPerRow: CGFloat = 3.0

        let width = (collectionView.frame.width-leftAndRightPaddings)/numberOfItemsPerRow
        return CGSize(width: width, height: width)
//        return CGSize(width: 100, height: 100)

    }
}


struct TimeListInner: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = TimeListViewController()
        let size = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        vc.preferredContentSize = size
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
