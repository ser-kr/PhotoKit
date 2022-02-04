//
//  ViewController.swift
//  PhotoKit
//
//  Created by SK on 21.01.2022.
//
import Photos
import UIKit
import Firebase
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //let storage = Storage.storage()
    var imagePickerController = UIImagePickerController()
    var storageManager = StorageManager()
    
    var allMedia: PHFetchResult<PHAsset>?
    let scale = UIScreen.main.scale
    var thumbnailSize = CGSize.zero
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func uploadImage(_ sender: UIButton) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        imagePickerController.delegate = self
        
        self.allMedia = PHAsset.fetchAssets(with: nil)
        self.collectionView.reloadData()
        self.thumbnailSize = CGSize(width: 1024 * self.scale, height: 1024 * self.scale)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image:", image)
            storageManager.upload(image: image)
            
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    //    func upload(image: UIImage) {
    //        let storageRef = storage.reference().
    //    }
    
    
    
    //    func uploadToCloud(fileURL: URL) {
    //
    //        let data = Data()
    //        let storageRef = storage.reference()
    //        let localFile = fileURL
    //        let photoRef = storageRef.child("UploadOne")
    //        let uploadTask = photoRef.putFile(from: localFile, metadata: nil) { (metadata, err) in
    //            guard let metadata = metadata else {
    //                print(err?.localizedDescription)
    //                return
    //            }
    //            print("Photo upload")
    //        }
    //    }
    
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class AssetsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var assetImageView: UIImageView!
    fileprivate let imageManager = PHImageManager()
    
    var representedAssetIdentifier: String?
    
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
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

