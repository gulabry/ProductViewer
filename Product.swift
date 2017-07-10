//
//  Product.swift
//  Products
//
//  Created by Bryan Gula on 7/9/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import Foundation
import UIKit

struct Product {
    
    var primaryTitle : String
    var secondaryTitle : String
    var images : [ProductImage]
    var color : UIColor
    var price : Price
    
    static func loadProducts(success: @escaping ([Product]) -> Void, failure: @escaping (Any) -> Void) {
        
        if let path = Bundle.main.path(forResource: "/productList", ofType: "json") {
            do {
                
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                var products = [Product]()
                
                if let resultJson = (jsonObj as! [String: Any])["results"] as? [[String: Any]]  {
                    if let productJson = resultJson[0]["products"] {
        
                        for p in productJson as! [[String: Any]] {
                            
                            let name1 = p["name1"] as! String
                            let name2 = p["name2"] as! String
                            
                            
                            //  Build Product Images
                            //
                            
                            var pImages = [ProductImage]()
                            
                            for i in p["images"] as! [[String:Any]] {
                                
                                let alt = i["alt"] as! String
                                let imageUrlString = i["path"] as! String
                                let sortOrder = i["sortOrder"] as! Int
                                let type = i["type"] as! String
                                
                                let image = ProductImage(name: alt, url: URL(string: imageUrlString)!, type: (type == "primary") ? .primary : .thumbnail, sortOrder: sortOrder)
                                
                                pImages.append(image)
                            }
                            
                            //  Build Color
                            //
                            
                            let pColor = Product.hexStringToUIColor(hex: p["style"] as! String)
                            
                            //  Build Price
                            //
                            
                            let priceJson = p["prices"] as! [String:Any]
                            
                            let currencyCode = priceJson["currencyCode"] as! String
                            let currentRetail = priceJson["currentRetail"] as! String
                            let list = priceJson["list"] as! String
                            let sale = priceJson["sale"] as! String
                            
                            let pPrice = Price(currencyCode: currencyCode, currentRetail: Double(currentRetail)!, listPriceString: list, salePriceString: sale)
                            
                            //  Build Product
                            //
                            
                            let product = Product(primaryTitle: name1, secondaryTitle: name2, images: pImages, color: pColor, price: pPrice)
                            
                            products.append(product)
                        }
                        
                        success(products)
                    }
                }

            } catch let error {
                print(error.localizedDescription)
                failure(error)
            }
            
        } else {
            failure("Invalid filename/path.")
        }
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func downloadImage(fromURL url: URL, success: @escaping (UIImage) -> Void, failure: @escaping (Error) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                failure(error!)
            }
            
            success(UIImage(data: data!)!)
            
        }).resume()
    }
}

struct ProductImage {
    var name : String
    var url : URL
    var type : ImageType
    var sortOrder : Int
}

struct Price {
    var currencyCode : String
    var currentRetail : Double
    var listPriceString : String
    var salePriceString : String
    
    static func getSymbolForCurrencyCode(code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
}

enum ImageType {
    case primary
    case thumbnail
}
