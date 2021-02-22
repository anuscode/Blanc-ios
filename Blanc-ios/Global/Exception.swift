import Foundation
import RxSwift

enum Result:String{
    case Success(string),
    case Fail(string)
}

class Exception {
    
    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<Exceptional>.create(bufferSize: 1)

}
