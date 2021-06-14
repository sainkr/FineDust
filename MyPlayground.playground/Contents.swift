import UIKit
import RxCocoa
import RxSwift
import MapKit


Observable.of(1,1,10,20,20,30,30)
    .distinctUntilChanged()
    .subscribe(onNext: { value in print(value)})
