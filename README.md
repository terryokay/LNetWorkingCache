# LNetWorkingCache

封装AFN请求,可以设置不同缓存方式.
1.有缓存就先返回缓存，同步请求数据
2.忽略缓存，重新请求
3.有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
4.有缓存就用缓存，如果过期了就重新请求 没过期就不请求

LKCacheNetWorking.swift 中单例,然后调用相应GET,POST的方法,配置对应的参数即可.

下载后出现 .sh: Permission denied 报错的问题,请直接pod update

