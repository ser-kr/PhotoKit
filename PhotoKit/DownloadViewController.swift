//
//  ColViewController.swift
//  PhotoKit
//
//  Created by SK on 23.01.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class DownloadViewController: UIViewController {
    
    var storageManager = StorageManager()
    var items = Array<UIImage>()
    let itemsPerRow: CGFloat = 3
    let sectionsInserts = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Task {
            let itemTemp = try! await storageManager.listAllFiles()
            self.items = itemTemp
            print("Controller items count:",items.count)
            self.loadView()
            
        }
    }
}
extension DownloadViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        print("cell run1")
        if let cell = cell as? DownloadViewCell {
            cell.imageViewInCell.image = items[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = sectionsInserts.top * (itemsPerRow + 1)
        let aviableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = aviableWidth / itemsPerRow
        return CGSize (width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionsInserts
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionsInserts.top
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionsInserts.top
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
}
