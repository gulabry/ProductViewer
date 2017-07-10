//
//  ProductsTests.swift
//  ProductsTests
//
//  Created by Bryan Gula on 7/9/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import XCTest
@testable import Products

class ProductsTests: XCTestCase {
    
    var mainVC : ViewController?
    
    override func setUp() {
        super.setUp()

        mainVC = ViewController()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoadMainView() {
        XCTAssertNotNil(mainVC!, "Main product view is nil")
    }
    
    func testLoadFixtureData() {
        
        Product.loadProducts(success: { (products) in
            
            XCTAssertNotNil(products, "The products aren't loading from the fixture")
            XCTAssert(products.count == 1)
            
        }) { (error) in
            XCTFail("error parsing json")
        }
    }
    
    func testLoadProductThumbnailImage() {
        
        Product.loadProducts(success: { (products) in
            
            let product = products.first!
            
            for image in product.images {
                
                if image.type == .thumbnail {
                    
                    Product.downloadImage(fromURL: image.url, success: { (image) in
                        
                        XCTAssertNotNil(image, "thumbnail image is nil")
                        
                    }, failure: { (error) in
                        XCTFail("error loading thumbnail image")
                    })
                }
            }
        }) { (error) in
            XCTFail("error parsing json")
        }
    }
    
    func testLoadProductFeatureImage() {
        Product.loadProducts(success: { (products) in
            
            let product = products.first!
            
            for image in product.images {
                
                if image.type == .primary {
                    
                    Product.downloadImage(fromURL: image.url, success: { (image) in
                        
                        XCTAssertNotNil(image, "primary image is nil")
                        
                    }, failure: { (error) in
                        XCTFail("error loading thumbnail image")
                    })
                }
            }
        }) { (error) in
            XCTFail("error parsing json")
        }
    }
}
