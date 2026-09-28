import Foundation
import XCTest
import Acknowledgements
import AcknowledgementsGen
@testable import AcknowledgementsCLI

final class MultiInputTests: XCTestCase {
    func testNamedInputsMergeInOrderAndDeduplicateByRepositoryOrName() async throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = directory.appendingPathComponent("first.resolved")
        let second = directory.appendingPathComponent("second.resolved")
        let output = directory.appendingPathComponent("acknowledgements.plist")
        try writePins([
            ("alpha", "https://example.com/alpha"),
            ("LocalTool", "http://[bad")
        ], to: first)
        try writePins([
            ("alpha-renamed", "https://example.com/alpha"),
            ("localtool", "http://[bad"),
            ("beta", "https://example.com/beta")
        ], to: second)

        var command = try AcknowledgementsCLI.parse([
            "--input", first.path, "--input", second.path, "--output", output.path
        ])
        try await command.run()

        XCTAssertEqual(Acknowledgement.acknowledgements(path: output).map(\.name), ["alpha", "LocalTool", "beta"])
    }

    func testNamedSingleInputAndLegacyPositionalForm() async throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("one.resolved")
        try writePins([("one", "https://example.com/one")], to: input)

        for arguments in [
            ["--input", input.path, "--output", directory.appendingPathComponent("named.plist").path],
            [input.path, directory.appendingPathComponent("legacy.plist").path]
        ] {
            var command = try AcknowledgementsCLI.parse(arguments)
            try await command.run()
            XCTAssertEqual(Acknowledgement.acknowledgements(path: URL(fileURLWithPath: arguments.last!)).map(\.name), ["one"])
        }
    }

    func testMissingAndMixedArgumentsAreRejected() throws {
        XCTAssertThrowsError(try AcknowledgementsCLI.parse(["--output", "/tmp/out.plist"]))
        XCTAssertThrowsError(try AcknowledgementsCLI.parse(["--input", "/tmp/in.resolved"]))
        XCTAssertThrowsError(try AcknowledgementsCLI.parse(["/tmp/in.resolved", "--output", "/tmp/out.plist"]))
        XCTAssertThrowsError(try AcknowledgementsCLI.parse(["--input", "/tmp/in.resolved", "/tmp/out.plist"]))
    }

    func testInvalidLaterInputDoesNotWriteOutput() async throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("valid.resolved")
        let invalid = directory.appendingPathComponent("invalid.resolved")
        let output = directory.appendingPathComponent("result.plist")
        try writePins([("one", "https://example.com/one")], to: input)
        try Data("invalid json".utf8).write(to: invalid)

        let generator = AcknowledgementsGenerator(inputs: [input, invalid], output: output, skipPrivate: false, token: nil)
        do {
            try await generator.run()
            XCTFail("Expected malformed input to fail")
        } catch {
            XCTAssertFalse(FileManager.default.fileExists(atPath: output.path))
        }
    }

    func testUnreadableLaterInputDoesNotWriteOutput() async throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("valid.resolved")
        let missing = directory.appendingPathComponent("missing.resolved")
        let output = directory.appendingPathComponent("result.plist")
        try writePins([("one", "https://example.com/one")], to: input)

        let generator = AcknowledgementsGenerator(inputs: [input, missing], output: output, skipPrivate: false, token: nil)
        do {
            try await generator.run()
            XCTFail("Expected missing input to fail")
        } catch {
            XCTAssertFalse(FileManager.default.fileExists(atPath: output.path))
        }
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func writePins(_ pins: [(String, String)], to url: URL) throws {
        let payload: [String: Any] = [
            "version": 3,
            "pins": pins.map { ["identity": $0.0, "location": $0.1] }
        ]
        try JSONSerialization.data(withJSONObject: payload).write(to: url)
    }
}
