//
//  ViewController.swift
//  Pinterest Layout
//
//  Created by Yash Shah on 13/03/22.
//

import UIKit
import PINRemoteImage

class ViewController: UIViewController {
    
    private var imageObjects: [ImageObject]?
    private var pageIndex = 1
    
    private let collectionView: UICollectionView = {
        let pinterestLayout = PinterestLayout(withNumberOfColumns: 2,
                                              horizontalSpacing: 12,
                                              verticalSpacing: 12)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: pinterestLayout)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Pinterest Layout"
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        (collectionView.collectionViewLayout as? PinterestLayout)?.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(ImageCVCell.self, forCellWithReuseIdentifier: ImageCVCell.self.description())
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        getData()
    }
    
    private func getData() {
        RandomImagesAPI.shared.getRandomImages(pageIndex: pageIndex) { [weak self] imageObjects, error in
            guard let `self` = self,
                  let imageObjects = imageObjects else { return }
            self.pageIndex += 1
            if self.imageObjects == nil {
                self.imageObjects = []
            }
            self.imageObjects?.append(contentsOf: imageObjects)
            DispatchQueue.main.async {
                self.collectionView.reloadData()            }
        }
    }
}

extension ViewController: PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withCellWidth width: CGFloat) -> CGFloat {
        guard let imageObject = imageObjects?[indexPath.item],
              imageObject.height > 0 else { return .zero }
        let aspectRatio = CGFloat(imageObject.width) / CGFloat(imageObject.height)
        guard aspectRatio > 0 else { return .zero }
        return width / aspectRatio
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCVCell.self.description(), for: indexPath) as? ImageCVCell else { return UICollectionViewCell() }
        cell.setData(imageObject: imageObjects?[indexPath.item], withSize: (collectionView.collectionViewLayout as? PinterestLayout)?.sizeForItem(atIndexPath: indexPath))
        return cell
    }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Prefetch the images
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section == collectionView.numberOfSections - 1,
              indexPath.row >= collectionView.numberOfItems(inSection: indexPath.section) - 6 else { return }
        getData()
    }
}

