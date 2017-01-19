import Foundation
import SwiftCheck
import Form
import JSONObject
import Functional

struct ArbitraryPair<A: Arbitrary, B: Arbitrary>: Arbitrary {
	let left: A
	let right: B
	init(left: A, right: B) {
		self.left = left
		self.right = right
	}

	static var arbitrary: Gen<ArbitraryPair<A, B>> {
		return Gen<(A,B)>
			.zip(A.arbitrary, B.arbitrary)
			.map { ArbitraryPair(left: $0.0, right: $0.1) }
	}
}

extension FieldAction {
	public func isEqual(to other: FieldAction) -> (Value?) -> Bool {
		return { optValue in

			let storage1 = FormStorage()
			let storage2 = FormStorage()

			self.apply(value: optValue, storage: storage1)
			other.apply(value: optValue, storage: storage2)

			return storage1.hasSameFieldValuesAndHiddenFieldKeys(of: storage2)
		}
	}
}

extension FieldCondition {
    public func isEqual(to other: FieldCondition) -> (Value?) -> Bool {
        return { optValue in
            
            let storage1 = FormStorage()
            let storage2 = FormStorage()
            
            let check1 = self.check(value: optValue, storage: storage1)
            let check2 = other.check(value: optValue, storage: storage2)
            
            return (check1 && check2) || (!check1 && !check2)
        }
    }
}

extension FieldAction: Arbitrary {
    public static var arbitrary: Gen<FieldAction<Value>> {
        return Gen<(FieldKey,Bool)>
            .zip(FieldKey.arbitrary, Bool.arbitrary)
            .map { (key,hidden) in
                FieldAction { (optValue,storage) in
                    storage.set(value: optValue, at: key)
                    storage.set(hidden: hidden, at: key)
                }
        }
    }
}

//extension FieldCondition: Arbitrary {
//    public static var arbitrary: Gen<FieldCondition<Value>> {
//        return Gen<(FieldKey,Bool)>
//            .zip(FieldKey.arbitrary, Bool.arbitrary)
//            .map { (key,hidden) in
//                FieldCondition { (optValue,storage) in
//                    let optValue = storage.getValue(at: key)
//                    if optValue != nil { return true }
//                    else { return false }
//                }
//        }
//    }
//}

struct CoArbitraryOptionalOf<Value: Arbitrary & Hashable & CoArbitrary>: Hashable, CoArbitrary {
    let get: OptionalOf<Value>
    init(get: OptionalOf<Value>) {
        self.get = get
    }
    
    var hashValue: Int {
        return get.getOptional?.hashValue ?? 0
    }
    
    static func == (left: CoArbitraryOptionalOf, right: CoArbitraryOptionalOf) -> Bool {
        return left.get.getOptional == right.get.getOptional
    }
    
    static func coarbitrary<C>(_ x: CoArbitraryOptionalOf<Value>) -> ((Gen<C>) -> Gen<C>) {
        return { gen in
            if let value = x.get.getOptional {
                return gen |> Value.coarbitrary(value)
            } else {
                return gen.variant(0)
            }
        }
    }
}

struct ArbitraryFieldCondition<Value: FieldValue & Hashable & Arbitrary & CoArbitrary>: Arbitrary {
    
    let get: FieldCondition<Value>
    init(get: FieldCondition<Value>) {
        self.get = get
    }

    static var arbitrary: Gen<ArbitraryFieldCondition<Value>> {
        return ArrowOf<CoArbitraryOptionalOf<Value>,Bool>.arbitrary
            .map({ (arrow) -> FieldCondition<Value> in
                return FieldCondition<Value> { (optionalValue,_) in
                    arrow.getArrow(CoArbitraryOptionalOf(get: OptionalOf(optionalValue)))
                }
            })
            .map(ArbitraryFieldCondition<Value>.init)
    }
}

func optFieldValuesAreEqual(_ optFirst: FieldValue?, _ optSecond: FieldValue?) -> Bool {
	if optFirst == nil && optSecond == nil { return true }
	guard let first = optFirst, let second = optSecond else { return false }
	return first.isEqual(to: second)
}

extension Date: Arbitrary {
    public static var arbitrary: Gen<Date> {
        return Gen<Date>.pure(Date.init())
    }
}

struct ArbitraryFieldValue: Arbitrary, CustomStringConvertible {
    
    let get: FieldValue
    var description: String
    
    init(value: FieldValue) {
        self.get = value
        self.description = ""
    }
    
    static var arbitrary: Gen<ArbitraryFieldValue> {
        return Gen.one(of: [Int.arbitrary.map(ArbitraryFieldValue.init),
                            String.arbitrary.map(ArbitraryFieldValue.init),
                            Bool.arbitrary.map(ArbitraryFieldValue.init),
                            Date.arbitrary.map(ArbitraryFieldValue.init)])
    }
}
