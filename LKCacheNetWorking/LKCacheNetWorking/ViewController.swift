//
//  ViewController.swift
//  LKCacheNetWorking
//
//  Created by hu yr on 2017/2/2.
//  Copyright © 2017年 terry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func post(_ sender: UIButton) {
    
        
//        LKCacheNetWorking.shared.
        
//        LKCacheNetWorking.shared.cacheSize()
        
        LKCacheNetWorking.shared.clearCache()
        
        
        
    }
    
    @IBAction func get(_ sender: UIButton) {
        
        
//        LKCacheNetWorking.shared.getWithCache(cacheType: NetWorkingCacheType.kCacheTypeReturnCacheDataThenLoad, urlString: "/api/Login/GetUser", parameters: ["userName":"18253140831","password":"111111"]) { (json) in
//            
//            
//            print("get请求的数据\(json)")
//            
//            
//        }
        
        LKCacheNetWorking.shared.getWithCache(cacheType: NetWorkingCacheType.kCacheTypeReturnCacheDataThenLoad, urlString: "api/UserCenter/GetUser/569", parameters: nil) { (json) in
            
            print("get请求的数据\(json)")
        }
        
//        LKCacheNetWorking.shared.getWithCache(cacheType: .kCacheTypeReturnCacheDataExpireThenLoad, urlString: "api/UserCenter/GetUser/569", parameters: nil) { (json) in
//            
//             print("get请求的数据\(json)")
//        }
        
        
//        LKCacheNetWorking.shared.getCache(cacheType: .kCacheTypeReloadIgnoringLocalCacheData, urlString: "api/APPShop/GetAPPShopInfo?SlideAdMenu=8&Columnd=2", parameters: nil) { (json) in
//            
//            print(json as Any)
//            
//            
//        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

