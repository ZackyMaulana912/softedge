import Testing

struct AppVersionTests {
    @Test(arguments: [
        ("0.1.0", "0.1.1"),
        ("0.9.0", "0.10.0"),
        ("0.1.1", "0.2"),
        ("1.0", "1.0.1"),
        ("v0.1.0", "0.2.0"),
    ])
    func olderComesFirst(older: String, newer: String) throws {
        let a = try #require(AppVersion(older))
        let b = try #require(AppVersion(newer))
        #expect(a < b)
        #expect(!(b < a))
        #expect(a != b)
    }

    @Test(arguments: [
        ("0.2", "0.2.0"),
        ("v0.1.1", "0.1.1"),
        ("V2", "2.0.0"),
    ])
    func sameVersionWrittenDifferently(first: String, second: String) throws {
        let a = try #require(AppVersion(first))
        let b = try #require(AppVersion(second))
        #expect(a == b)
        #expect(!(a < b) && !(b < a))
    }

    @Test(arguments: ["", "v", "1..2", "1.x", "1.-1", "beta", "1.0-beta"])
    func rejectsText(text: String) {
        #expect(AppVersion(text) == nil)
    }

    @Test func printsWithoutPrefix() {
        #expect(AppVersion("v0.10.3")?.description == "0.10.3")
    }
}
