//
//  YandexAPI.swift
//  TestYandex
//
//  Created by admin on 12.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import Foundation
import Moya
import Alamofire

//MARK: - Provider setup
//let t = MoyaProvider<Yandex>(manager: Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Accept-Language": "RU"])
let YandexProvider = MoyaProvider<Yandex>()


//MARK: - Provider support
private extension String {
    var URLEscapedStirng : String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public enum Yandex {
    case GetList
}

extension Yandex : MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: kURL)! }
    public var path: String {
        switch self {
        case .GetList:
            return kList
        }
    }
    public var method: Moya.Method {
        return .GET
    }
    public var parameters: [String: AnyObject] {
        return [:]
    }
    public var sampleData: NSData {
        return "GetList good".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}

