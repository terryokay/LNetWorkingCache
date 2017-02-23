//
//  LKCacheTool.swift
//  LKCacheNetWorking
//
//  Created by hu yr on 2017/2/2.
//  Copyright © 2017年 terry. All rights reserved.
//

import UIKit

class LKCacheTool: NSObject {

    
    
}

extension LKCacheTool{
    
    /// 缓存数据
    ///
    /// - Parameters:
    ///   - data: 需要缓存的二进制
    ///   - fileName: 缓存数据的文件名
    func cacheData(data:NSData, fileName:String)->(Void){
        
        let path = (kTmpPath as NSString).appendingPathComponent(fileName.md5())
        
        DispatchQueue.global().async {
            
            data.write(toFile: path, atomically: true)
            
        }
        
        print("缓存数据位置\(path)")
        
    }
    
    /// 取出缓存数据
    ///
    /// - Parameter fileName: 缓存数据的文件名
    /// - Returns: 缓存的二进制数据
    func getCacheData(fileName:String)->(NSData){
        
        let path = (kTmpPath as NSString).appendingPathComponent(fileName.md5())
        
        let data = NSData(contentsOfFile: path)
        
        if data != nil {
            
            return data!
            
        }else{
            
            return NSData()
        }
        
        
        
        
    }
    
    
    
    
}

extension LKCacheTool{
    
    
    //获取沙盒缓存数据大小
    func getSize()->(UInt){
        
        
        var sizeNumber:UInt = 0
        
        let fileEnumerator = FileManager.default.enumerator(atPath: kTmpPath)
        
        for fileName in fileEnumerator! {
            
            let filePath = (kTmpPath as NSString).appendingPathComponent(fileName as! String)
            
            let attrs = (try? FileManager.default.attributesOfItem(atPath: filePath)) ?? [:]
            
            sizeNumber = (attrs[FileAttributeKey.size] as! UInt) + sizeNumber//B字节
            
        }
        
        return sizeNumber / (1024*1024)
        
        
        
        
        
    }
    //清除本地沙盒的缓存数据
    func clearCache(){
        
        
        let fm = FileManager.default
        
        let fileNameArr = (try? fm.contentsOfDirectory(atPath: kTmpPath))
        
        guard let fileArr = fileNameArr else {
            return
        }
        
        for filenameStr in fileArr{
            
            let filePath = (kTmpPath as NSString).appendingPathComponent(filenameStr)
            
            
            (try? fm.removeItem(atPath: filePath))
            
        }
        
        
        
        
    }
    
    
}
extension LKCacheTool{
    
    /// 判断缓存文件是否过期
    ///
    /// - Parameter fileName: 文件名
    /// - Returns: 判断缓存文件是否过期
    func isExpire(fileName:String) -> (Bool){
        let path = (kTmpPath as NSString).appendingPathComponent(fileName.md5())
        
        let fm = FileManager.default
        
        
        let attributesDict = (try? fm.attributesOfItem(atPath: path)) ?? [:]
        
        let modificationDate = attributesDict[FileAttributeKey.modificationDate] as? Date
        
        
        guard let fileModificationTimeInterVal = modificationDate?.timeIntervalSince1970 else{
            
            return false
        }
        
        
        let nowTimeInterVal = Date(timeIntervalSinceNow: 0).timeIntervalSince1970
        
        return ((nowTimeInterVal - fileModificationTimeInterVal) > kCache_Expire_Time)
        
        
        
        
        
        
    }
    
    
    
}
///MD5 加密
extension String{
    func md5() ->String!{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
}
