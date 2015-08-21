import UIKit
import Moya
import Quick
import Nimble
import OHHTTPStubs

class MoyaProviderIntegrationTests: QuickSpec {
    override func spec() {
        let listMessage = NSString(data: Yandex.GetList.sampleData, encoding: NSUTF8StringEncoding)

        beforeEach { () -> () in
            println(kList)
            OHHTTPStubs.stubRequestsPassingTest({$0.URL!.path == kList}) { _ in
                return OHHTTPStubsResponse(data: Yandex.GetList.sampleData, statusCode: 200, headers: nil)
            }
        }

        afterEach { () -> () in
            OHHTTPStubs.removeAllStubs()
        }

        describe("valid endpoints") {
            describe("with live data") {
                describe("a provider") { () -> () in
                    var provider: MoyaProvider<Yandex>!
                    beforeEach {
                        provider = MoyaProvider<Yandex>()
                        return
                    }
                    
                    it("returns real data for GetList request") {
                        var message: String?
                        
                        let target: Yandex = .GetList
                        println(target.baseURL.path!)
                        println(target.baseURL)
                        provider.request(target) { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                            }
                        }
                        
                        expect{message}.toEventually( equal(listMessage) )
                    }

                    
                    it("returns an error when cancelled") {
                        var receivedError: NSError?
                        
                        let target: Yandex = .GetList
                        let token = provider.request(target) { (data, statusCode, response, error) in
                            receivedError = error
                            expect(receivedError).toEventuallyNot(beNil() )
                        }
                        token.cancel()
                        
                        expect(receivedError).toEventuallyNot(beNil() )
                    }
                }

                describe("a provider with network activity closures") {
                    it("notifies at the beginning of network requests") {
                        var called = false
                        var provider = MoyaProvider<Yandex>(networkActivityClosure: { (change) -> () in
                            if change == .Began {
                                called = true
                            }
                        })

                        let target: Yandex = .GetList
                        provider.request(target) { (data, statusCode, response, error) in }

                        expect(called).toEventually( beTrue() )
                    }

                    it("notifies at the end of network requests") {
                        var called = false
                        var provider = MoyaProvider<Yandex>(networkActivityClosure: { (change) -> () in
                            if change == .Ended {
                                called = true
                            }
                        })

                        let target: Yandex = .GetList
                        provider.request(target) { (data, statusCode, response, error) in }

                        expect(called).toEventually( beTrue() )
                    }
                }
            }
        }
    }
}
