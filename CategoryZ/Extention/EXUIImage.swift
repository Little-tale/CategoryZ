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

/*
 회고
 */
extension UIImageView {
    func downloadImage(imageUrl: String) {
        let processor = DownsamplingImageProcessor(size: CGSize(width: 500, height: 500))
        var scale: CGFloat = 0
        
        if let test = UIScreen.current?.scale {
            scale = test
        } else {
            scale = UIScreen.main.scale
        }
        
        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: [
            .processor(processor),
            .requestModifier(KingFisherNet()),
            .scaleFactor(scale),
        ]) { imageResult in
            switch imageResult {
            case .success(let result):
                self.image = result.image
            case .failure(let error):
                print(error)
            }
        }
    }
}
