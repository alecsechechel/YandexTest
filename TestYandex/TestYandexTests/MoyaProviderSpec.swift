import Quick
import Moya
import Nimble
import Alamofire

class MoyaProviderSpec: QuickSpec {
    override func spec() {
        describe("valid endpoints") {
            describe("with stubbed responses") {
                describe("a provider", {
                    var provider: MoyaProvider<Yandex>!
                    beforeEach {
                        provider = MoyaProvider<Yandex>(stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    }
                    
                    it("returns stubbed data for GetList request") {
                        var message: String?
                        
                        let target: Yandex = .GetList
                        provider.request(target) { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                            }
                        }
                        
                        let sampleData = target.sampleData as NSData
                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                    }
                    
                    it("returns a cancellable object when a request is made") {
                        let target: Yandex = .GetList
                        let cancellable: Cancellable = provider.request(target) { (_, _, _, _) in }
                        
                        expect(cancellable).toNot(beNil())

                    }

                    it("uses the Alamofire.Manager.sharedInstance by default") {
                        expect(provider.manager).to(beIdenticalTo(Alamofire.Manager.sharedInstance))
                    }

                    it("accepts a custom Alamofire.Manager") {
                        let manager = Manager()
                        let provider = MoyaProvider<Yandex>(manager: manager)

                        expect(provider.manager).to(beIdenticalTo(manager))
                    }
                })

                it("notifies at the beginning of network requests") {
                    var called = false
                    var provider = MoyaProvider<Yandex>(stubBehavior: MoyaProvider.ImmediateStubbingBehaviour, networkActivityClosure: { (change) -> () in
                        if change == .Began {
                            called = true
                        }
                    })

                    let target: Yandex = .GetList
                    provider.request(target) { (data, statusCode, response, error) in }

                    expect(called) == true
                }

                it("notifies at the end of network requests") {
                    var called = false
                    var provider = MoyaProvider<Yandex>(stubBehavior: MoyaProvider.ImmediateStubbingBehaviour, networkActivityClosure: { (change) -> () in
                        if change == .Ended {
                            called = true
                        }
                    })

                    let target: Yandex = .GetList
                    provider.request(target) { (data, statusCode, response, error) in }
                    
                    expect(called) == true
                }

                describe("a provider with lazy data", { () -> () in
                    var provider: MoyaProvider<Yandex>!
                    beforeEach {
                        provider = MoyaProvider<Yandex>(endpointClosure: lazyEndpointClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    }

                    it("returns stubbed data for getList request") {
                        var message: String?

                        let target: Yandex = .GetList
                        provider.request(target) { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                            }
                        }

                        let sampleData = target.sampleData as NSData
                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                    }
                })

                it("delays execution when appropriate") {
                    let provider = MoyaProvider<Yandex>(stubBehavior: MoyaProvider.DelayedStubbingBehaviour(2))

                    let startDate = NSDate()
                    var endDate: NSDate?
                    let target: Yandex = .GetList
                    waitUntil(timeout: 3) { done in
                        provider.request(target) { (data, statusCode, response, error) in
                            endDate = NSDate()
                            done()
                        }
                        return
                    }

                    expect{
                        return endDate?.timeIntervalSinceDate(startDate)
                    }.to( beGreaterThanOrEqualTo(NSTimeInterval(2)) )
                }

                describe("a provider with a custom endpoint resolver") { () -> () in
                    var provider: MoyaProvider<Yandex>!
                    var executed = false
                    let newSampleResponse = "New Sample Response"
                    
                    beforeEach {
                        executed = false
                        let endpointResolution = { (endpoint: Endpoint<Yandex>) -> (NSURLRequest) in
                            executed = true
                            return endpoint.urlRequest
                        }
                        provider = MoyaProvider<Yandex>(endpointResolver: endpointResolution, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    }
                    
                    it("executes the endpoint resolver") {
                        let target: Yandex = .GetList
                        provider.request(target, completion: { (data, statusCode, response, error) in })
                        
                        let sampleData = target.sampleData as NSData
                        expect(executed).to(beTruthy())
                    }
                }
            }
        }
    }
}
