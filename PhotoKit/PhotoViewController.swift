//
//  PhotoViewController.swift
//  FirebaseApp
//
//  Created by SK on 23.01.2022.
//
import Photos
import UIKit
import FirebaseDatabase
import Firebase

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var storageManager = StorageManager()
    
    var imagePickerControllerTest = UIImagePickerController()
    
    let itemsPerRow: CGFloat = 3
    let sectionsInserts = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    
    var allMedia: PHFetchResult<PHAsset>?
    let scale = UIScreen.main.scale
    var thumbnailSize = CGSize.zero
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Mode {
        case view
        case select
    }
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                selectBarButton.title = "Select"
                navigationItem.leftBarButtonItem = nil
                collectionView.allowsMultipleSelection = false
            case .select:
                selectBarButton.title = "Cancel"
                navigationItem.leftBarButtonItem = sendBarButton
                collectionView.allowsMultipleSelection = true
            }
        }
    }
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(didSelectButtonClicked(_:)))
        return barButtonItem
    }()
    lazy var sendBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .organize , target: self, action: #selector(didSendButtonClicked(_:)))
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerControllerTest.delegate = self
        setupBarButtonItem()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.allMedia = PHAsset.fetchAssets(with: nil)
        self.collectionView.reloadData()
        self.thumbnailSize = CGSize(width: 1024 * self.scale, height: 1024 * self.scale)
    }
    
    private func setupBarButtonItem() {
        navigationItem.rightBarButtonItem = selectBarButton
    }
    
    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
    }
    @objc func didSendButtonClicked(_ sender: UIBarButtonItem) {
        self.imagePickerControllerTest.sourceType = .photoLibrary
        self.present(self.imagePickerControllerTest, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(image)
            storageManager.upload(image: image)
            
        }
        imagePickerControllerTest.dismiss(animated: true, completion: nil)
    }
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allMedia?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetsCollectionViewCell", for: indexPath) as! AssetsCollectionViewCell
        let asset = self.allMedia?[indexPath.item]
        LocalImageManager.shared.requestIamge(with: asset, thumbnailSize: self.thumbnailSize) { (image) in
            cell.configure(with: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            let item = self.allMedia?[indexPath.item]
        case .select:
            dictionarySelectedIndexPath[indexPath] = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mMode == .select {
            dictionarySelectedIndexPath[indexPath] = false
        }
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

class AssetsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var assetImageView: UIImageView!
    
    @IBOutlet weak var highlightIndicator: UIView!
    
    @IBOutlet weak var selectIndicator: UIImageView!
    
    override var isHighlighted: Bool {
        didSet {
            highlightIndicator.isHidden = !isHighlighted
        }
    }
    override var isSelected: Bool {
        didSet {
            highlightIndicator.isHidden = !isSelected
            selectIndicator.isHidden = !isSelected
        }
    }
    
    fileprivate let imageManager = PHImageManager()
    
    var representedAssetIdentifier: String?
    
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 300 * scale)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.assetImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with image: UIImage?) {
        self.assetImageView.image = image
    }
}

final class LocalImageManager {
    
    static var shared = LocalImageManager()
    
    fileprivate let imageManager = PHImageManager()
    
    var representedAssetIdentifier: String?
    
    func requestIamge(with asset: PHAsset?, thumbnailSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard let asset = asset else {
            completion(nil)
            return
        }
        self.representedAssetIdentifier = asset.localIdentifier
        self.imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
            if self.representedAssetIdentifier == asset.localIdentifier {
                completion(image)
            }
        })
    }
}
