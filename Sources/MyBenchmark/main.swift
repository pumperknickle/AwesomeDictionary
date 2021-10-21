import CollectionsBenchmark
import AwesomeDictionary
import Bedrock

var benchmark = Benchmark(title: "Dictionary Benchmark")

benchmark.add(
  title: "Setting, deleting, contains",
  input: ([Int]).self
) { input in
    var ds = input.reduce(Mapping<String, String>()) { result, entry in
        return result.setting(key: "\(entry)", value: "\(entry)")
    }
  return { timer in
    for value in input {
        ds = ds.deleting(key: "\(value)")
        precondition(!ds.contains("\(value)"))
    }
  }
}

benchmark.add(
  title: "Merging",
  input: ([Int], [Int]).self
) { input, secondInput in
    var ds = input.reduce(Mapping<String, String>()) { result, entry in
        return result.setting(key: "\(entry)", value: "\(entry)")
    }
    let di = secondInput.reduce(Mapping<String, String>()) { result, entry in
        return result.setting(key: "\(entry)", value: "\(entry)")
    }
    let dn = di.overwrite(with: ds)
    if dn.contains("") { }
  return { timer in
    for value in input {
        ds = ds.deleting(key: "\(value)")
        precondition(!ds.contains("\(value)"))
    }

  }
}

benchmark.main()
