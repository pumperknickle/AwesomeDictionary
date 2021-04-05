import Foundation
import Nimble
import Quick
import Bedrock
@testable import AwesomeDictionary

final class SetSpec: QuickSpec {
    override func spec() {
        let newSet = TrieBasedSet<String>()
        let key1 = "foo"
        let key2 = "bar"
        let key3 = "foobar"
        let key4 = "foobar1"
        describe("setup maps") {
            let set1 = newSet.adding(key1)
            let set2 = set1.adding(key2)
            let set3 = set2.adding(key3)
            let set4 = set3.adding(key4)
            it("should successfully add keys to set") {
                expect(newSet.contains(key1)).to(beFalse())
                expect(set1.contains(key1)).to(beTrue())
                expect(set2.contains(key2)).to(beTrue())
                expect(set3.contains(key3)).to(beTrue())
                expect(set4.contains(key4)).to(beTrue())
            }
        }
    }
}
