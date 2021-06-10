import UIKit
import RxCocoa
import RxSwift

var result: [Int] = []

Observable.from([1,2])
    .subscribe(onNext:{ z in
        result.append(z)
    })

print(result)
