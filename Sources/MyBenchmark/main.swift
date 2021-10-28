import CollectionsBenchmark
import AwesomeDictionary
import Bedrock

var benchmark = Benchmark(title: "Dictionary Benchmark")

benchmark.add(
  title: "Setting, deleting, contains",
  input: ([Int]).self
) { input in
//    var ds = input.reduce(MappingAlt<String, String>()) { result, entry in
//        return result.setting(key: "\(entry)", value: "\(entry)")
//    }
  return { timer in
      let uniqueInput = Set(input)
      let container = input.reduce(MappingAlt<String, String>()) { result, entry in
          return result.setting(key: "\(entry)", value: "\(entry)")
      }
      let check1 = !input.map { container.contains("\($0)") }.contains(false)
      let deleting = input.reduce(container) { result, entry in
          return result.deleting(key: "\(entry)")
      }
      let check2 = !input.map { deleting.contains("\($0)") }.contains(true)
      print(input.count)
      precondition(true)
//    for value in input {
//        ds = ds.deleting(key: "\(value)")
//        if (ds.contains("\(value)")) {
//            print("value: \(value)")
//            print(ds.deleting(key: "\(value)").elements())
//            print("error") }
//        precondition(true)
//    }
  }
}
//
//benchmark.add(
//  title: "Merging",
//  input: ([Int], [Int]).self
//) { input, secondInput in
//    var ds = input.reduce(MappingAlt<String, String>()) { result, entry in
//        return result.setting(key: "\(entry)", value: "\(entry)")
//    }
//    let di = secondInput.reduce(MappingAlt<String, String>()) { result, entry in
//        return result.setting(key: "\(entry)", value: "\(entry)")
//    }
//    let dn = di.overwrite(with: ds)
//    if dn.contains("") { }
//  return { timer in
//    for value in input {
//        ds = ds.deleting(key: "\(value)")
//        precondition(!ds.contains("\(value)"))
//    }
//
//  }
//}

benchmark.main()
