@testable import DataSource
import Foundation
import XCTest

public extension XCTestCase {
    var given: Given { Given() }
    var when: When { When() }
    var then: Then { Then() }
}

public struct Given {}
public struct When {}
public struct Then {}

class ConcurrentReloadSelectTest: XCTestCase {
    class State {
        let tableView = UITableView()

        lazy var dataSource: DataSource = {
            DataSource(cellDescriptors: [
                MockCell.descriptor
                    .didSelect { [weak self] viewModel, _ in
                        self?.selectedViewModel = viewModel
                        return .deselect
                    },
            ])
        }()

        var selectedViewModel: MockCellViewModel?
    }

    var state: State!

    override func setUp() {
        super.setUp()
        state = State()
    }

    override func tearDown() {
        state = nil
        super.tearDown()
    }

    func testSectionRemoved() async {
        await given
            .setupTableView(state: state)

        await when
            .populateData(state: state, numberOfRows: 100)
            .emptyTableView(state: state)
            .selectCellAt(150, state: state)
        
        await then
            .nothingSelected(state: state)
    }
    
    func testSelection() async {
        await given
            .setupTableView(state: state)

        await when
            .populateData(state: state, numberOfRows: 100)
            .selectCellAt(50, state: state)
        
        then
            .selectedId(state: state, id: 50)
    }

    func testElementRemoved() async {
        await given
            .setupTableView(state: state)

        await when
            .populateData(state: state, numberOfRows: 100)
            .selectCellAt(50, state: state)
            .removeItemsFromSection(state: state)
    
        then
            .selectedId(state: state, id: 50)
    }
}

extension Given {

    @discardableResult
    @MainActor
    func setupTableView(state: ConcurrentReloadSelectTest.State) -> Given {
        state.tableView.delegate = state.dataSource
        state.tableView.dataSource = state.dataSource
        return self
    }
}

extension When {

    @discardableResult
    @MainActor
    func populateData(state: ConcurrentReloadSelectTest.State, numberOfRows: Int)  -> Self {
        let items = Array(0..<numberOfRows).map { MockCellViewModel(id: $0)}
        let section = Section(items: items)
        state.dataSource.sections = [section]
        state.dataSource.reloadData(state.tableView, animated: false)
        return self
    }

    @discardableResult
    @MainActor
    func selectCellAt(_ index: Int, state: ConcurrentReloadSelectTest.State)  -> Self {
        state.dataSource.tableView(state.tableView, didSelectRowAt: .init(row: index, section: 0))
        return self
    }

    @discardableResult
    @MainActor
    func emptyTableView(state: ConcurrentReloadSelectTest.State) async -> Self {
        state.dataSource.sections = []
        state.dataSource.reloadData(state.tableView, animated: false)
        return self
    }

    @discardableResult
    @MainActor
    func removeItemsFromSection(state: ConcurrentReloadSelectTest.State) async -> Self {
        state.dataSource.sections = [Section(items: [Section(items: [MockCellViewModel(id: 0)])])]
        state.dataSource.reloadData(state.tableView, animated: false)
        return self
    }
}

extension Then {
    @discardableResult
    func nothingSelected(state: ConcurrentReloadSelectTest.State) async -> Self {
        XCTAssertNil(state.selectedViewModel, "nothing should be selected but element with id \(state.selectedViewModel!.id) was selected")
        return self
    }
    
    @discardableResult
    func selectedId(state: ConcurrentReloadSelectTest.State, id: Int) -> Self {
        do {
            let selectedId = try XCTUnwrap(state.selectedViewModel?.id, "there should have been a selection")
            XCTAssertEqual(selectedId, id, "mismatch on id selection: selected \(selectedId) but should have been \(id)")
        } catch {
            XCTFail("unwrap of selected cell failed")
        }
        return self
    }
}

class MockCell: UITableViewCell, AutoRegisterCell {
    public func configure(viewModel _: MockCellViewModel) {}

    static var descriptor: CellDescriptor<MockCellViewModel, MockCell> {
        return CellDescriptor().configure { viewModel, cell, _ in
            cell.configure(viewModel: viewModel)
        }
    }
}

class MockCellViewModel {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
}
