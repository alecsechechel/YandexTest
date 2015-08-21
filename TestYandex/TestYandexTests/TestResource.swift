//
//  TestResource.swift
//  TestYandex
//
//  Created by admin on 13.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import Foundation

import Moya
import UIKit

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

enum Yandex {
    case GetList
}

extension Yandex : MoyaTarget {
    var baseURL: NSURL { return NSURL(string: kURL)! }
    var path: String {
        switch self {
        case .GetList:
            return kList
        }
    }
    var method: Moya.Method {
        return .GET
    }
    var parameters: [String: AnyObject] {
        return [:]
    }
    var sampleData: NSData {
        return "GetList good".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}

let lazyEndpointClosure = { (target: Yandex) -> Endpoint<Yandex> in
    return Endpoint<Yandex>(URL: url(target), sampleResponse: .Closure({.Success(200, {target.sampleData})}), method: target.method, parameters: target.parameters)
}

let failureEndpointClosure = { (target: Yandex) -> Endpoint<Yandex> in
    let errorData = "Houston, we have a problem".dataUsingEncoding(NSUTF8StringEncoding)!
    return Endpoint<Yandex>(URL: url(target), sampleResponse: .Error(401, NSError(domain: "com.moya.error", code: 0, userInfo: nil), {errorData}), method: target.method, parameters: target.parameters)
}