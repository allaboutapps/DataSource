import Foundation
import XCTest

@testable import DataSource

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
        var tableView: UITableView!
        
        lazy var dataSource: DataSource = {
            DataSource(cellDescriptors: [MockCell.descriptor])
        }()
    }
    
    var state: State!
    
    private lazy var dataSource: DataSource = {
        DataSource(cellDescriptors: [])
    }()
    
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
            .createTableView(state: state)
            .setupTableView(state: state)
        
        await when
            .setMockCells(state: state)
        
        await then
            .selectCellAt(50, state: state)
            .emptyTableView(state: state)
    }
    
    func testElementRemoved() async {
        await given
            .createTableView(state: state)
            .setupTableView(state: state)
        
        await when
            .setMockCells(state: state)
        
        await then
            .selectCellAt(50, state: state)
            .removeItemsFromSection(state: state)
    }
}

extension Given {
    @discardableResult @MainActor
    func createTableView(state: ConcurrentReloadSelectTest.State) -> Given {
        state.tableView = UITableView()
        return self
    }
    
    @discardableResult @MainActor
    func setupTableView(state: ConcurrentReloadSelectTest.State) -> Given {
        state.tableView.delegate = state.dataSource
        state.tableView.dataSource = state.dataSource
        return self
    }
}

extension When {
    @discardableResult
    func setMockCells(state: ConcurrentReloadSelectTest.State) async -> When {
        let section = Section(items: [MockCellViewModel].init(repeating: .init(), count: 100))
        state.dataSource.sections = [section]
        state.dataSource.reloadData(state.tableView, animated: true)
        return self
    }
}

extension Then {
    @discardableResult
    func selectCellAt(_ index: Int, state: ConcurrentReloadSelectTest.State) async -> Then {
        await state.tableView.selectRow(at: .init(row: index, section: 0), animated: true, scrollPosition: .none)
        return self
    }
    
    @discardableResult
    func emptyTableView(state: ConcurrentReloadSelectTest.State) async -> Then {
        state.dataSource.sections = []
        state.dataSource.reloadData(state.tableView, animated: true)
        return self
    }
    
    @discardableResult
    func removeItemsFromSection(state: ConcurrentReloadSelectTest.State) async -> Then {
        state.dataSource.sections = [Section(items: [Section(items: [MockCellViewModel()])])]
        state.dataSource.reloadData(state.tableView, animated: true)
        return self
    }
}

class MockCell: UITableViewCell, AutoRegisterCell {
    public func configure(viewModel: MockCellViewModel) { }
    
    static var descriptor: CellDescriptor<MockCellViewModel, MockCell> {
        return CellDescriptor().configure { viewModel, cell, _ in
            cell.configure(viewModel: viewModel)
        }
    }
}

class MockCellViewModel {}
