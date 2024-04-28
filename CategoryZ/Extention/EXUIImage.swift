//
//  EXUIImage.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit.UIImage
import Kingfisher

extension UIImage {
    func blurCiMode(radius: CGFloat) -> UIImage {
        let context = CIContext()
        
        guard let ciImage = CIImage(image: self),
              let cmFilter = CIFilter(name: "CIAffineClamp"),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return self
        }
        
        cmFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        blurFilter.setValue(cmFilter.outputImage, forKey: kCIInputImageKey)
        
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let output = blurFilter.outputImage,
              let cgImage = context.createCGImage(output, from: ciImage.extent) else {
            return self
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func resizingImage(targetSize: CGSize) -> UIImage?{
        let widthScale = targetSize.width / self.size.width
        let heightScale = targetSize.height / self.size.height
        
        let minAbout = min(widthScale, heightScale)
        
        let scaledImageSize = CGSize(width: size.width * minAbout, height: size.height * minAbout)
        
        let render = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = render.image { [weak self] _ in
            guard let self else { return }
            draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
}

extension UIImageView {
    func downloadImage(imageUrl: String?, resizing: CGSize, _ defaultImage: UIImage? = nil) {

        let processor = DownsamplingImageProcessor(size: resizing)
        var scale: CGFloat = 0
        
        if let screenCurrent = UIScreen.current?.scale {
            
            scale = screenCurrent
        } else {
            scale = UIScreen.main.scale
        }
        
        guard let imageUrl else {
            if defaultImage != nil {
                image = defaultImage
            }
            NotificationCenter.default.post(name: .cantChageUrlImage, object: nil)
            return
        }
        
        kf.indicatorType = .activity
        
        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: [
            .processor(processor),
            .transition(.fade(1)),
            .requestModifier(KingFisherNet()),
            .scaleFactor(scale),
            .cacheOriginalImage
        ]) { imageResult in
            switch imageResult {
            case .success(let result):
                self.image = result.image
            case .failure(let error):
                break
            }
        }
    }
}

extension UIViewController {
    func downloadImage(imageUrl: String?, resizing: CGSize, complite: @escaping (Result<Data?,NetworkError>)-> Void ) {

        let processor = DownsamplingImageProcessor(size: resizing)
        var scale: CGFloat = 0
        
        if let screenCurrent = UIScreen.current?.scale {
            
            scale = screenCurrent
        } else {
            scale = UIScreen.main.scale
        }
        
        guard let imageUrl else {
            complite(.failure(.failMakeURLRequest))
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: [
            .processor(processor),
            .transition(.fade(1)),
            .requestModifier(KingFisherNet()),
            .scaleFactor(scale),
            .cacheOriginalImage
        ]) { imageResult in
            switch imageResult {
            case .success(let result):
                complite(.success(result.data()))
            case .failure(let error):
                // 바꿔야해
                print("이미지 로드 실패")
                // complite(.failure(.unknownError))
                break
            }
        }
    }
    func downloadImages(imageUrl: [String], resizing: CGSize, complete: @escaping (Result<[Data],NetworkError>)-> Void ) {

        let processor = DownsamplingImageProcessor(size: resizing)
       
        var successModels:[Data] = []
        let group = DispatchGroup()
        
        imageUrl.forEach { urlString in
            guard let url = URL(string: urlString) else {
                complete(.failure(.failMakeURLRequest))
                return
            }
            group.enter()
            
            KingfisherManager.shared.retrieveImage(with: url, options: [
                .processor(processor),
                .requestModifier(KingFisherNet()),
                .scaleFactor(UIScreen.main.scale)
            ]) { imageResult in
                defer { group.leave() }
                switch imageResult {
                case .success(let result):
                    if let imageData = result.image.jpegData(compressionQuality: 1.0) {
                        successModels.append(imageData)
                    }
                    
                case .failure(let error):
                    // 바꿔야해
                    print("이미지 로드 실패")
                    // complite(.failure(.unknownError))
                    break
                }
            }
        }
        
        group.notify(queue: .main) {
            if successModels.count == imageUrl.count {
                complete(.success(successModels))
            } else {
                complete(.failure(.imageUploadError(statusCode: 400, description: "현재 이미지 서비스에 문제가 있어요!")))
            }
        }
    }
}
