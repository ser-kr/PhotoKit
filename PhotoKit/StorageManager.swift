//
//  StorageManager.swift
//  PhotoKit
//
//  Created by SK on 24.01.2022.
//

import Foundation
import Firebase
import UIKit

public class StorageManager {
    let storage = Storage.storage()
    
    func upload(image: UIImage) {
        let currentDateTime = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHH:mm"
                    let currentDateTimeString = formatter.string(from: currentDateTime)
        
        let storageRef = storage.reference().child("images/\(currentDateTimeString).jpg")
        let data = image.jpegData(compressionQuality: 0.2)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading file", error)
                }
                if let metadata = metadata {
                    print("Metadata:", metadata)
                }
            }
        }
    }
    func listAllFiles() async throws -> [UIImage] {
        var images: [UIImage] = []
        let storageRef = storage.reference().child("images")
        let result = try await storageRef.listAll()
        print("List all", result.items)
        for item in result.items {
            let data = try await item.getData(maxSize: 1 * 1024 * 1024)
            let image = UIImage(data: data)
            images.append(image!)
        }
        print("images count", images.count)
        return images
    }
}

extension StorageReference {
    func listAll() async throws -> StorageListResult {
        try await withCheckedThrowingContinuation  { continuation in
            
            listAll   { result, error in
                if error == nil {
                    continuation.resume(with: .success(result))
                } else {
                    continuation.resume(with: .failure(error!))
                }
            }
        }
    }
}

extension StorageReference {
    func getData(maxSize size: Int64) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            getData(maxSize: size) { data, error in
                if error == nil {
                    continuation.resume(with: .success(data!))
                } else {
                    continuation.resume(with: .failure(error!))
                }
            }
        }
    }
}
