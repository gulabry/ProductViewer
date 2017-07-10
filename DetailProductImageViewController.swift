//
//  DetailProductImageViewController.swift
//  Products
//
//  Created by Bryan Gula on 7/9/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import UIKit

class DetailProductImageViewController: UIViewController {
    
    var product : Product?
    
    @IBOutlet var detailPhotoView: UIImageView!
    @IBOutlet var detailPhotoLoadingActivityView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let product = self.product {
            
            view.backgroundColor = product.color
            
            detailPhotoLoadingActivityView.startAnimating()
            for image in product.images {
                
                if image.type == .primary {
                    
                    Product.downloadImage(fromURL: image.url, success: { (image) in
                        
                        DispatchQueue.main.async {
                            self.detailPhotoView.image = image
                            self.detailPhotoLoadingActivityView.stopAnimating()
                            self.detailPhotoLoadingActivityView.isHidden = true
                        }
                        
                    }, failure: { (error) in
                        print(error)
                    })
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
