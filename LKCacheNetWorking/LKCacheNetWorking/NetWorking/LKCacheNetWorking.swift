//
//  LKCacheNetWorking.swift
//  LKCacheNetWorking
//
//  Created by hu yr on 2017/2/2.
//  Copyright © 2017年 terry. All rights reserved.
//

import UIKit
import AFNetworking

enum NetWorkingCacheType{
    
    case kCacheTypeReturnCacheDataThenLoad ///< 有缓存就先返回缓存，同步请求数据
    case kCacheTypeReloadIgnoringLocalCacheData ///< 忽略缓存，重新请求
    
    
    //case kCacheTypeReturnCacheDataElseLoad ///< 有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    case kCacheTypeReturnCacheDataDontLoad ///< 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
    case kCacheTypeReturnCacheDataExpireThenLoad ///< 有缓存就用缓存，如果过期了就重新请求 没过期就不请求
    
}


class LKCacheNetWorking: NSObject {
    
    // 静态区 / 常量 / 闭包 /
    //在第一次访问时, 执行闭包, 并且将结果保存在 shared 常量中
    static let shared = { () -> LKCacheNetWorking in
        
        // 实例化对象
        let instance = LKCacheNetWorking()
        
        //返回对象
        return instance
    }()
    
    ///清除缓存
    func clearCache(){
        
        
        LKCacheTool().clearCache()
        
    }
    
    /// 缓存大小
    ///
    /// - Returns: 缓存大小
    func cacheSize()->(UInt){
        
        
        let size = LKCacheTool().getSize()
        
//        print(size)
        return size
        
    }
    
    
    ///普通的get请求
    func get(urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> () ){
        
        
        getRequest(cacheType: NetWorkingCacheType.kCacheTypeReloadIgnoringLocalCacheData, urlString: urlString, parameters: parameters, completion: completion)
    }
    
    ///带有缓存get请求
    func getWithCache(cacheType:NetWorkingCacheType,urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> ()){
        
        getRequest(cacheType: cacheType, urlString: urlString, parameters: parameters, completion: completion)
    }
    
    
    
    ///真正的get请求方法
    fileprivate func getRequest(cacheType:NetWorkingCacheType,urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> ()){
        
        
        let manager = self.sessionManager()
        
        let httpStr = kAPI_URL.appending(urlString)
        
        //获取缓存
        let cache = getCache(cacheType: cacheType, urlString: urlString, parameters: parameters, success: completion)
        
        let fileName = cache.fileName
        
        if cache.result {
            return
        }
        
        let success = { (task: URLSessionDataTask, json: Any?) -> () in
            
            guard let json = json else{
                
                return
            }
            
            let data = (try? JSONSerialization.data(withJSONObject: json, options: [])) ?? Data()
            
            //把请求成功获取的数据,用NSData的形式存储到
            LKCacheTool().cacheData(data: data as NSData, fileName: fileName!)
            
            completion(json)
            
        }
        let failure = { (task: URLSessionDataTask?, error:Error) -> () in
            
            print("网络请求错误 \(error)")
            completion(nil)
            
        }
        
        //AFN的请求
        manager.get(httpStr, parameters: parameters, progress: nil, success: success, failure: failure)
        
        
        
    }
    
    
    
    
    
    
    ///普通的post请求
    func post(urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> () ){
        
        postRequest(cacheType: NetWorkingCacheType.kCacheTypeReloadIgnoringLocalCacheData, urlString: urlString, parameters: parameters, completion: completion)
        
        
    }
    ///可以设置缓存的post
    func postWithCache(cacheType:NetWorkingCacheType,urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> ()){
        
        postRequest(cacheType: cacheType, urlString: urlString, parameters: parameters, completion: completion)
    }
    
    ///真正post的请求方法
    fileprivate func postRequest(cacheType:NetWorkingCacheType,urlString:String,parameters : Any?,completion: @escaping (_ json: Any?) -> ()){
        
        
        let manager = self.sessionManager()
        
        let httpStr = kAPI_URL.appending(urlString)
        
        //获取缓存
        let cache = getCache(cacheType: cacheType, urlString: urlString, parameters: parameters, success: completion)
        
        let fileName = cache.fileName
    
        if cache.result {
            return
        }
        
        let success = { (task: URLSessionDataTask, json: Any?) -> () in
            
            guard let json = json else{
                
                return
            }
            
            let data = (try? JSONSerialization.data(withJSONObject: json, options: [])) ?? Data()
            
            //把请求成功获取的数据,用NSData的形式存储到
            LKCacheTool().cacheData(data: data as NSData, fileName: fileName!)
            
            completion(json)
            
        }
        let failure = { (task: URLSessionDataTask?, error:Error) -> () in
        
            print("网络请求错误 \(error)")
            completion(nil)
        
        }
        
        
        //AFN的请求
        manager .post(httpStr, parameters: parameters, progress: nil, success: success, failure: failure)
        
        
        
        
        
        
    }
    
    fileprivate func getCache(cacheType:NetWorkingCacheType,urlString:String,parameters : Any?,success:@escaping (_ json: Any?) -> ()) -> (LKCache){
        
        //根据 请求的URL和参数生成 文件名称
        let fileName = getFileName(url: urlString, params: parameters)
        //根据文件名 去获取缓存
        let data = LKCacheTool().getCacheData(fileName: fileName)
        
        let cache = LKCache()
        cache.fileName = fileName
        
        
        if data.length > 0 {
            
            let json = (try? JSONSerialization.jsonObject(with: data as Data, options: [])) ?? Any.self
            
            if cacheType == NetWorkingCacheType.kCacheTypeReloadIgnoringLocalCacheData {
                
                
                
            }else if cacheType == NetWorkingCacheType.kCacheTypeReturnCacheDataDontLoad{
                
                success(json)//先用缓存
                
                cache.result = true//不再请求
                
            }else if cacheType == NetWorkingCacheType.kCacheTypeReturnCacheDataThenLoad{
                
                success(json)//先用缓存,再请求
                
                
            }else if cacheType == NetWorkingCacheType.kCacheTypeReturnCacheDataExpireThenLoad{
                
                if !LKCacheTool().isExpire(fileName: fileName) {
                    
                    //没有过期的情况
                    success(json)
                    
                    cache.result = true
                }else{
                    //过期的情况
//                    print("过期了")
                    
                }
            }
            
            
        }else{
            //没有缓存,后面需要继续请求
            
            
            cache.result = false
            
            
            
        }
        return cache
    }
    ///根据请求地址和参数生成文件名称
    fileprivate func getFileName(url:String,params:Any?) -> (String){
        
        var mStr = url
        
        if params != nil {
            
            let data = (try? JSONSerialization.data(withJSONObject: params!, options: [])) ?? Data()
            
            let str = String(data: data, encoding: .utf8) ?? ""
            
             mStr = mStr.appending(str)
        }
        
        return mStr
        
        
    }
    
    ///设置请求的对象
    fileprivate func sessionManager()->(AFHTTPSessionManager){
        
        let manager = AFHTTPSessionManager()
        
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        
        manager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "application/json","text/json","text/javascript","text/html","text/plain")
        
        manager.requestSerializer.timeoutInterval = 15
        
        return manager
        
    }
    

}
class LKCache: NSObject {
    
    var fileName:String? = nil
    
    
    var result:Bool = false
    
    override init() {
        
        
        super.init()
    }
    
}
