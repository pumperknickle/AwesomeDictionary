import Foundation
import Nimble
import Quick
import Bedrock
@testable import AwesomeDictionary

final class MappingSpec: QuickSpec {
    override func spec() {
        let newMap = Mapping<String, [[String]]>()
        let key1 = "foo"
        let value1 = [["fooValue"]]
        let key2 = "bar"
        let value2 = [["barValue"]]
        let key3 = "foobar"
        let value3 = [["boofar"]]
        let key4 = "foobar1"
        let value4 = [["fooBar"]]
        describe("setup maps") {
            let map1 = newMap.setting(key: key1, value: value1).setting(key: key3, value: value3).setting(key: key2, value: value2)
            let map2 = newMap.setting(key: key2, value: value2).setting(key: key1, value: value1).setting(key: key3, value: value3)
            let map3 = newMap.setting(key: key3, value: value3).setting(key: key2, value: value2).setting(key: key1, value: value1)
            let data1 = try! JSONEncoder().encode(map1)
            let data2 = try! JSONEncoder().encode(map2)
            let data3 = try! JSONEncoder().encode(map3)
            it("should be able to retrieve data") {
                expect(map1[key1]).toNot(beNil())
                expect(map1[key1]).to(equal(value1))
                expect(map2[key2]).toNot(beNil())
                expect(map2[key2]!).to(equal(value2))
            }
            it("should be able to get all keys") {
                expect(map1.keys().count).to(equal(3))
                expect(map1.keys()).to(contain(key1))
                expect(map1.keys()).to(contain(key2))
                expect(map1.keys()).to(contain(key3))
            }
            it("should be able to get all values") {
                expect(map1.values().count).to(equal(3))
                expect(map1.values()).to(contain(value1))
                expect(map1.values()).to(contain(value2))
                expect(map1.values()).to(contain(value3))
            }
            it("should be equal bit for bit") {
                expect(data1).to(equal(data2))
                expect(data2).to(equal(data3))
            }
            let map4 = newMap.setting(key: key4, value: value4)
            let map5 = map1.setting(key: key4, value: value4)
            let combined = map4.overwrite(with: map1)
            let data4 = try! JSONEncoder().encode(combined)
            let data5 = try! JSONEncoder().encode(map5)
            it("overwriting should equal") {
                expect(combined[key4]!).to(equal(value4))
                expect(data4).to(equal(data5))
            }
            let map6 = map5.deleting(key: key4)
            let data6 = try! JSONEncoder().encode(map6)
            it("should delete correctly") {
                expect(data1).to(equal(data6))
            }
			it("should get first correctly") {
				expect(newMap.first()).to(beNil())
				expect(map1.first()).toNot(beNil())
				expect([key1, key2, key3]).to(contain([map1.first()!.0]))
				expect([value1, value2, value3]).to(contain([map1.first()!.1]))
			}
			let map7 = newMap.setting(key: key1, value: value1).setting(key: key3, value: value3).setting(key: key4, value: value4)
			let map8 = newMap.setting(key: key2, value: value2).setting(key: key1, value: value2)
			it("should overwrite correctly") {
				let overwritten = map7.overwrite(with: map8)
				expect(overwritten.keys()).to(contain([key1, key2, key3, key4]))
				expect(overwritten.values()).to(contain([value2, value3, value4]))
				expect(overwritten.values()).toNot(contain([value1]))
			}
            let map9 = newMap.setting(key: key1, value: value1).setting(key: key2, value: value2)
            let map10 = newMap.setting(key: key1, value: value3)
            let map11 = newMap.setting(key: key2, value: value4)
            it("should add arrays in values") {
                let overwritten = map9.merge(with: map10, combine: +)
                expect(overwritten.keys()).to(contain([key1, key2]))
                expect(overwritten[key1]).toNot(beNil())
                expect(overwritten[key1]).to(contain([value1.first!, value3.first!]))
                expect(overwritten[key1]!.count).to(equal(2))
                let overwritten2 = overwritten.merge(with: map11, combine: +)
                expect(overwritten2.keys()).to(contain([key1, key2]))
                expect(overwritten2[key2]).toNot(beNil())
                expect(overwritten2[key2]).to(contain([value2.first!, value4.first!]))
                expect(overwritten2[key2]!.count).to(equal(2))
            }
            it("should keep original map same if merging with empty") {
                let combinedWithNothing = map9.merge(with: newMap, combine: +)
                expect(combinedWithNothing).to(equal(map9))
                let overwritten = newMap.merge(with: map9, combine: +)
                expect(overwritten).to(equal(map9))
            }
        }
    }
}
