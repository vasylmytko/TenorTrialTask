//
//  PaginatedFetchGIFsUseCaseTests.swift
//  TenorTrialTaskTests
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import XCTest
@testable import TenorTrialTask

class PaginatedFetchGIFsUseCaseTests: XCTestCase {
    
    func test_fetchGIFsWithSearchParameters_callsWrappeWithSameSearchParameters() {
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase()
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        sut.execute(searchParamaters: .stub, completion: { _ in })
        
        XCTAssertEqual(stubFetchGIFsUseCase.searchParameters, .stub)
    }
    
    func test_fetchGIFsSecondTimeWithSameParameters_callsWrappeeWithSameSearchParameters() {
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase()
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        
        sut.execute(searchParamaters: .stub, completion: { _ in })
        sut.execute(searchParamaters: .stub, completion: { _ in })
        
        let expectedSearchParameters = GIFSearchParameters(searchTerm: .stub, page: GIFsCollection.stub.next)
        XCTAssertEqual(stubFetchGIFsUseCase.searchParameters, expectedSearchParameters)
    }
    
    func test_fetchGIFsSecondTimeWithSameParameters_callsWrappeeWithNextPageSearchParameters() {
        let stubbedCollection = GIFsCollection.stub
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase(resultStub: .success(stubbedCollection))
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        let expectedSearchParameters = GIFSearchParameters(searchTerm: .stub, page: stubbedCollection.next)
        
        sut.execute(searchParamaters: .stub) { _ in }
        sut.execute(searchParamaters: .stub) { _ in }
        
        XCTAssertEqual(stubFetchGIFsUseCase.searchParameters, expectedSearchParameters)
    }
    
    func test_fetchGIFsSecondTimeWithNewSearchTerm_callsWrappeeWithSearchParametersForFirstPage() {
        let stubbedCollection = GIFsCollection.stub
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase(resultStub: .success(stubbedCollection))
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        let firstSearch = GIFSearchParameters(searchTerm: "first", page: nil)
        let secondSearch = GIFSearchParameters(searchTerm: "second", page: nil)
        let expectedSearchParameters = GIFSearchParameters(searchTerm: secondSearch.searchTerm, page: nil)
        
        sut.execute(searchParamaters: firstSearch) { _ in }
        sut.execute(searchParamaters: secondSearch) { _ in }
        
        XCTAssertEqual(stubFetchGIFsUseCase.searchParameters, expectedSearchParameters)
    }
    
    func test_fetchGIFsWithSearchParameters_receivesSuccessfulResult() {
        let expectedResult: Result<GIFsCollection, ErrorMessage> = .success(.stub)
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase(resultStub: expectedResult)
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        
        expectResult(expectedResult, sut: sut)
    }
    
    func test_fetchGIFsWithSearchParameters_receivesFailure() {
        let expectedResult: Result<GIFsCollection, ErrorMessage> = .failure(.stub)
        let stubFetchGIFsUseCase = StubFetchGIFsUseCase(resultStub: expectedResult)
        let sut = PaginatedFetchGIFsUseCase(fetchGIFsUseCase: stubFetchGIFsUseCase)
        
        expectResult(expectedResult, sut: sut)
    }
    
    private func expectResult(
        _ expectedResult: Result<GIFsCollection, ErrorMessage>,
        sut: PaginatedFetchGIFsUseCase,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        sut.execute(searchParamaters: .stub) { receivedResult in
            XCTAssertEqual(expectedResult, receivedResult, file: file, line: line)
        }
    }
}

private final class StubFetchGIFsUseCase: FetchGIFsUseCase {
    
    private let resultStub: Result<GIFsCollection, ErrorMessage>
    private(set) var searchParameters: GIFSearchParameters?
    
    init(resultStub: Result<GIFsCollection, ErrorMessage> = .success(.stub)) {
        self.resultStub = resultStub
    }
    
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
    ) {
        self.searchParameters = searchParamaters
        completion(resultStub)
    }
}

private extension GIFsCollection {
    static let stub: GIFsCollection = .init(
        gifs: [.stub],
        next: "2"
    )
}

private extension GIF {
    static let stub: GIF = .init(
        id: "1",
        url: .init(fileURLWithPath: "gifURL"),
        dimensions: [0, 0],
        isFavourite: false
    )
}

private extension GIFSearchParameters {
    static let stub = GIFSearchParameters(searchTerm: .stub, page: "1")
}

private extension String {
    static let stub = "hello"
}

extension ErrorMessage {
    static let stub = ErrorMessage("error")
}

extension GIFSearchParameters: Equatable {
    public static func == (lhs: GIFSearchParameters, rhs: GIFSearchParameters) -> Bool {
        return (lhs.searchTerm == rhs.searchTerm) && (lhs.page == rhs.page)
    }
}

extension GIFsCollection: Equatable {
    public static func == (lhs: GIFsCollection, rhs: GIFsCollection) -> Bool {
        return (lhs.gifs == rhs.gifs) && (lhs.next == rhs.next)
    }
}
