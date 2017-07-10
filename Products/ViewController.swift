//
//  ViewController.swift
//  Products
//
//  Created by Bryan Gula on 7/9/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var products = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self

        setupProducts()
    }

    func setupProducts() {
        
        Product.loadProducts(success: { (products) in
            
            //  Reload Collection View now that products are ready
            self.products = products
            self.collectionView.reloadData()
            
        }) { (err) in
            
            print(err)
        }
    }
    
    //  MARK - CollectionView Data Source Methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        
        let product = products[indexPath.section]
        
        cell.titleLabel.text = product.primaryTitle
        cell.subtitleLabel.text = product.secondaryTitle
        
        if let currencySymbol = Price.getSymbolForCurrencyCode(code: product.price.currencyCode) {
            cell.priceLabel.text = "Sale Price: \(currencySymbol)\(product.price.salePriceString)"
            cell.listPriceLabel.text = "List Price: \(currencySymbol)\(product.price.listPriceString)"

        }
        
        cell.backgroundColor = product.color
        
        cell.imageActivityIndicatorView.startAnimating()
        
        for image in product.images {
            
            if image.type == .thumbnail {
                
                Product.downloadImage(fromURL: image.url, success: { (image) in
                    
                    DispatchQueue.main.async {
                        cell.previewImageView.image = image
                        cell.imageActivityIndicatorView.stopAnimating()
                        cell.imageActivityIndicatorView.isHidden = true
                    }
                    
                }, failure: { (error) in
                    print(error)
                })
            }
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    //  MARK - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPhotos", sender: indexPath)
    }
    
    //  MARK - CollectionViewFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 1.2, height: collectionView.frame.size.width / 2 - 10)
    }
    
    //  MARK - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            
            let showDetail = segue.destination as! DetailProductImageViewController
            let product = self.products[(sender as! IndexPath).section]
            showDetail.product = product
            
        }
    }
}

class ProductCell : UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var imageActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var listPriceLabel: UILabel!
}

