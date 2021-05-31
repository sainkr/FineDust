import UIKit
import RxCocoa
import RxSwift

var relay = PublishRelay<Int>()

relay.subscribe(onNext:{
    print("들어온 값 : \($0)")
})

var k = relay.map{
    $0 / 2
}

k.subscribe(onNext:{
    print("k .. : \($0)")
})

Observable.range(start: 2, count: 9)
    // .bind(to: relay)
    .subscribe(onNext:{
        relay.accept($0)
    })
  

