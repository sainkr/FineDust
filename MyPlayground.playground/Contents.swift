import UIKit
import RxCocoa
import RxSwift
import MapKit

func date(_ currentDate: Date)-> Date{
  let formatter = DateFormatter()
  formatter.dateFormat = "mm"
  let currentMinute = Int(formatter.string(from: Date()))!
  return Calendar.current.date(byAdding: .minute, value: 63 - currentMinute, to: currentDate)!
}

print(Date())
print(date(Date()))
