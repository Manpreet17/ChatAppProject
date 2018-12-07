//
//  Extensions.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-27.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func imgLoadCacheOrUrlString(_ stringURL: String) {
        
        self.image = nil
    
        if let imgCached = imageCache.object(forKey: stringURL as AnyObject) as? UIImage {
            self.image = imgCached
            return
        }
        let urlImg = URL(string: stringURL)
        URLSession.shared.dataTask(with: urlImg!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            DispatchQueue.main.async(execute: {
                if let imgDownloadedFromURL = UIImage(data: data!) {
                    imageCache.setObject(imgDownloadedFromURL, forKey: stringURL as AnyObject)
                    self.image = imgDownloadedFromURL
                }
            })
        }).resume()
    }
}
extension UIView{
    func showBlurLoader(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        
        self.addSubview(blurEffectView)
    }
    
    func removeBluerLoader(){
        self.subviews.compactMap {  $0 as? UIVisualEffectView }.forEach {
            $0.removeFromSuperview()
        }
    }
}
extension UIViewController {
      func startSpin(onView : UIView) -> UIView {
        let startSpinView = UIView.init(frame: onView.bounds)
        startSpinView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = startSpinView.center
        DispatchQueue.main.async {
            startSpinView.addSubview(activityIndicator)
            onView.addSubview(startSpinView)
        }
        return startSpinView
    }
    
       func stopSpin(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

