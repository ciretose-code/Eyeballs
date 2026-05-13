import Foundation
import Testing
@testable import Eyeballs

@Suite("Release Check Tests")
struct ReleaseCheckManagerTests {

    @Test("App release version appends build number to short version")
    func appReleaseVersionUsesBuildNumber() {
        let version = AppReleaseVersion(shortVersion: "1.1", buildVersion: "5")

        #expect(version?.displayString == "1.1.5")
    }

    @Test("Release versions compare numerically")
    func releaseVersionsCompareNumerically() {
        let currentVersion = ReleaseVersion(string: "v1.1.5")
        let olderVersion = ReleaseVersion(string: "1.1.4")
        let shorterVersion = ReleaseVersion(string: "1.1")

        #expect(currentVersion != nil)
        #expect(olderVersion != nil)
        #expect(shorterVersion != nil)
        #expect(currentVersion! > olderVersion!)
        #expect(currentVersion! > shorterVersion!)
    }

    @Test("Update check reports available release")
    func updateAvailable() async throws {
        let currentVersion = try #require(AppReleaseVersion(shortVersion: "1.1", buildVersion: "4"))
        let checker = GitHubReleaseChecker(
            currentVersion: currentVersion,
            fetcher: MockReleaseFetcher(json: """
            {
              "tag_name": "v1.1.5",
              "html_url": "https://github.com/ciretose-code/Eyeballs/releases/tag/v1.1.5"
            }
            """)
        )

        let outcome = try await checker.checkForUpdates()

        #expect(outcome == .updateAvailable(
            currentVersion: "1.1.4",
            latestVersion: "1.1.5",
            releasePage: URL(string: "https://github.com/ciretose-code/Eyeballs/releases/tag/v1.1.5")!
        ))
    }

    @Test("Update check reports current version when already up to date")
    func updateNotNeeded() async throws {
        let currentVersion = try #require(AppReleaseVersion(shortVersion: "1.1", buildVersion: "5"))
        let checker = GitHubReleaseChecker(
            currentVersion: currentVersion,
            fetcher: MockReleaseFetcher(json: """
            {
              "tag_name": "v1.1.5",
              "html_url": "https://github.com/ciretose-code/Eyeballs/releases/tag/v1.1.5"
            }
            """)
        )

        let outcome = try await checker.checkForUpdates()

        #expect(outcome == .upToDate(currentVersion: "1.1.5"))
    }

    @Test("Update check fails for invalid release tag")
    func invalidReleaseTag() async {
        let currentVersion = AppReleaseVersion(shortVersion: "1.1", buildVersion: "5")
        let checker = GitHubReleaseChecker(
            currentVersion: currentVersion!,
            fetcher: MockReleaseFetcher(json: """
            {
              "tag_name": "latest",
              "html_url": "https://github.com/ciretose-code/Eyeballs/releases/tag/latest"
            }
            """)
        )

        await #expect(throws: ReleaseCheckError.invalidReleaseVersion("latest")) {
            try await checker.checkForUpdates()
        }
    }
}

private final class MockReleaseFetcher: ReleaseFetching {
    private let data: Data
    private let response: URLResponse

    init(json: String, statusCode: Int = 200) {
        self.data = Data(json.utf8)
        self.response = HTTPURLResponse(
            url: URL(string: "https://api.github.com/repos/ciretose-code/Eyeballs/releases/latest")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        (data, response)
    }
}
