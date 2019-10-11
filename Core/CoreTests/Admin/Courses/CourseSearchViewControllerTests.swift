//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core
import XCTest

@available(iOS 13.0, *)
class CourseSearchViewControllerTests: CoreTestCase {
    var viewController: CourseSearchViewController!

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [])
        viewController = CourseSearchViewController.create(env: environment, accountID: "1")
        viewController.throttle.delay = 0
    }

    override func tearDown() {
        drainMainQueue()
        super.tearDown()
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testViewDidLoad() throws {
        let courses: [APICourse] = [.make(
            name: "Course One",
            term: APICourse.Term(id: "1", name: "Term 1", start_at: nil, end_at: nil),
            teachers: [
                APICourse.Teacher(id: "1", display_name: "One"),
                APICourse.Teacher(id: "2", display_name: "Two"),
                APICourse.Teacher(id: "3", display_name: "Three")
            ]
        )]
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: courses)
        load()
        drainMainQueue()
        XCTAssertEqual(viewController.title, "Courses")
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        let cell = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CourseSearchCell)
        XCTAssertEqual(cell.courseNameLabel.text, "Course One")
        XCTAssertEqual(cell.teachersLabel.text, "One, Two, + 1 other")
        XCTAssertEqual(cell.termLabel.text, "Term 1")
        XCTAssertTrue(viewController.tableView.tableFooterView?.isHidden == true)
        XCTAssertEqual(viewController.tableView.contentInset.bottom, -viewController.tableFooterHeight)
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertNil(viewController.emptyView.bodyText)
    }

    func testSearchBarTextDidChange() throws {
        let result = APICourse.make(
            name: "Intro to Geometry",
            term: APICourse.Term(id: "1", name: "Term 1", start_at: nil, end_at: nil),
            teachers: [
                APICourse.Teacher(id: "1", display_name: "One"),
                APICourse.Teacher(id: "2", display_name: "Two"),
                APICourse.Teacher(id: "3", display_name: "Three"),
                APICourse.Teacher(id: "3", display_name: "Four")
            ]
        )
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: "intro", searchBy: .course), value: [result])
        load()
        viewController.searchBar.text = "intro"
        viewController.searchBar(viewController.searchBar, textDidChange: "intro")
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        let cell = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CourseSearchCell)
        XCTAssertEqual(cell.courseNameLabel.text, "Intro to Geometry")
        XCTAssertEqual(cell.teachersLabel.text, "One, Two, + 2 others")
        XCTAssertTrue(viewController.emptyView.isHidden)
    }

    func testSearchRequestEmpty() {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: "fail", searchBy: .course), value: [])
        load()
        viewController.searchBar.text = "fail"
        viewController.searchBar(viewController.searchBar, textDidChange: "fail")
        drainMainQueue()
        XCTAssertFalse(viewController.emptyView.isHidden)
    }

    func testSearchRequestError() throws {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: "fail", searchBy: .course), error: NSError.instructureError("Something went wrong"))
        load()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        window.rootViewController = viewController
        viewController.searchBar.text = "fail"
        viewController.searchBar(viewController.searchBar, textDidChange: "fail")
        drainMainQueue()
        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.message, "Something went wrong")
        XCTAssertTrue(viewController.emptyView.isHidden)
    }

    func testSearchRequestCancelled() throws {
        let cancelled = NSError(domain: "", code: NSURLErrorCancelled, userInfo: nil)
        let task = api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), error: cancelled)
        task.paused = true
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.loadingIndicator.isAnimating)
        task.paused = false
        drainMainQueue()
        XCTAssertFalse(viewController.loadingIndicator.isAnimating)
        XCTAssertNil(viewController.presentedViewController)
    }

    func testSearchRequestLoadingIndicator() {
        let task = api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [])
        task.paused = true
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.loadingIndicator.isAnimating)
        XCTAssertTrue(viewController.emptyView.isHidden)
        task.paused = false
        drainMainQueue()
        XCTAssertFalse(viewController.loadingIndicator.isAnimating)
        XCTAssertFalse(viewController.emptyView.isHidden)
    }

    func testGetNextPage() {
        let next = "https://canvas.instructure.com/api/v1/accounts/1/courses?page=2"
        let first = GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course)
        api.mock(first, value: [.make(id: "1", name: "One")], response: HTTPURLResponse(next: next))
        let nextRequest = GetNextRequest<[APICourse]>(path: next)
        let task = api.mock(nextRequest, value: [.make(id: "2", name: "Two")], response: HTTPURLResponse(next: next))
        task.paused = true
        load()
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        scrollView.contentSize = CGSize(width: 100, height: 300)
        scrollView.contentOffset.y = 150
        viewController.scrollViewDidScroll(scrollView)
        XCTAssert(viewController.tableView.tableFooterView?.isHidden == false)
        XCTAssertEqual(viewController.tableView.contentInset.bottom, 0)
        task.paused = false
        drainMainQueue()
        XCTAssert(viewController.tableView.tableFooterView?.isHidden == true)
        XCTAssertEqual(viewController.tableView.contentInset.bottom, -viewController.tableFooterHeight)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertNotNil(viewController.nextPage)
    }

    func testGetNextPageError() throws {
        let next = "https://canvas.instructure.com/api/v1/accounts/1/courses?page=2"
        let first = GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course)
        api.mock(first, value: [.make(id: "1", name: "One")], response: HTTPURLResponse(next: next))
        let nextRequest = GetNextRequest<[APICourse]>(path: next)
        api.mock(nextRequest, error: NSError.instructureError("Oops"))
        load()
        drainMainQueue()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        window.rootViewController = viewController
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        scrollView.contentSize = CGSize(width: 100, height: 300)
        scrollView.contentOffset.y = 150
        viewController.scrollViewDidScroll(scrollView)
        drainMainQueue()
        let alert = try XCTUnwrap(viewController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.message, "Oops")
    }

    func testSearchByDidChange() {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .teacher), value: [.make(id: "1")])
        load()
        viewController.searchBySegmentedControl.selectedSegmentIndex = CourseSearchViewController.SearchBy.teachers.rawValue
        viewController.searchBySegmentedControl.sendActions(for: .valueChanged)
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(viewController.searchBar.placeholder, "Search courses by teacher...")

        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [.make(id: "1")])
        viewController.searchBySegmentedControl.selectedSegmentIndex = CourseSearchViewController.SearchBy.courses.rawValue
        viewController.searchBySegmentedControl.sendActions(for: .valueChanged)
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(viewController.searchBar.placeholder, "Search courses...")
    }

    func testSelectCourse() {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [.make(id: "1")])
        load()
        drainMainQueue()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(router.lastRoutedTo(.course("1")))
    }

    func testMinimumCharacterSearchLabel() {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [])
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: "abc", searchBy: .course), value: [])
        load()

        viewController.searchBar.text = ""
        viewController.searchBar(viewController.searchBar, textDidChange: "")
        drainMainQueue()
        XCTAssertTrue(viewController.minimumSearchLabel.isHidden)

        viewController.searchBar.text = "a"
        viewController.searchBar(viewController.searchBar, textDidChange: "a")
        drainMainQueue()
        XCTAssertFalse(viewController.minimumSearchLabel.isHidden)

        viewController.searchBar.text = "ab"
        viewController.searchBar(viewController.searchBar, textDidChange: "ab")
        drainMainQueue()
        XCTAssertFalse(viewController.minimumSearchLabel.isHidden)

        viewController.searchBar.text = "abc"
        viewController.searchBar(viewController.searchBar, textDidChange: "abc")
        drainMainQueue()
        XCTAssertTrue(viewController.minimumSearchLabel.isHidden)
    }

    func testViewWillAppearDeselectSelectedRow() {
        api.mock(GetAccountCoursesRequest(accountID: "1", searchTerm: nil, searchBy: .course), value: [.make(id: "1")])
        load()
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        XCTAssertNotNil(viewController.tableView.indexPathForSelectedRow)
        viewController.viewWillAppear(false)
        XCTAssertNil(viewController.tableView.indexPathForSelectedRow)
    }
}