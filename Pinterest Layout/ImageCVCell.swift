//
//  ImageCVCell.swift
//  Pinterest Layout
//
//  Created by Yash Shah on 13/03/22.
//

import Foundation
import UIKit
import PINRemoteImage

public final class ImageCVCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
    public func setData(imageObject: ImageObject?, withSize size: CGSize?) {
        guard var urlString = imageObject?.download_url else { return }
        if let size = size {
            if let heightIndex = urlString.lastIndex(of: "/") {
                urlString = String(urlString.prefix(upTo: heightIndex))
            }
            if let widthIndex = urlString.lastIndex(of: "/") {
                urlString = String(urlString.prefix(upTo: widthIndex))
            }
            urlString.append(contentsOf: "/\(Int(size.width))/\(Int(size.height))")
        }
        guard let url = URL(string: urlString) else { return }
        imageView.pin_setImage(from: url, placeholderImage: UIImage(named: "placeholder-image"))
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
