//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit

private class Placeholder {}

public extension Bundle {
    @objc static let core = Bundle(for: Placeholder.self)

    static let studentBundleID = "com.eskwelabs.icanvas"
    static let teacherBundleID = "com.eskwelabs.ios.teacher"
    static let parentBundleID = "com.eskwelabs.parentapp"

    static let coreBundleID = "com.eskwelabs.core"

    static let studentUITestsBundleID = "com.eskwelabs.StudentUITests.xctrunner"
    static let teacherUITestsBundleID = "com.eskwelabs.TeacherUITests.xctrunner"
    static let parentUITestsBundleID = "com.eskwelabs.ParentUITests.xctrunner"

    static let studentE2ETestsBundleID = "com.eskwelabs.StudentE2ETests.xctrunner"
    static let teacherE2ETestsBundleID = "com.eskwelabs.TeacherE2ETests.xctrunner"
    static let parentE2ETestsBundleID = "com.eskwelabs.ParentE2ETests.xctrunner"

    func appGroupID(bundleID: String? = nil) -> String? {
        if (bundleID ?? bundleIdentifier)?.hasPrefix(Bundle.studentBundleID) == true {
            return "group.\(Bundle.studentBundleID)"
        }
        return nil
    }

    var isStudentApp: Bool { bundleIdentifier == Bundle.studentBundleID || isStudentTestsRunner }
    var isTeacherApp: Bool { bundleIdentifier == Bundle.teacherBundleID || isTeacherTestsRunner }
    var isParentApp: Bool { bundleIdentifier == Bundle.parentBundleID || isParentTestsRunner }
    var isStudentTestsRunner: Bool { [Bundle.studentUITestsBundleID, Bundle.studentE2ETestsBundleID].contains(bundleIdentifier) }
    var isTeacherTestsRunner: Bool { [Bundle.teacherUITestsBundleID, Bundle.teacherE2ETestsBundleID].contains(bundleIdentifier) }
    var isParentTestsRunner: Bool { [Bundle.parentUITestsBundleID, Bundle.parentE2ETestsBundleID].contains(bundleIdentifier) }
    var testTargetBundleID: String? {
        if isStudentTestsRunner {
            return Bundle.studentBundleID
        } else if isTeacherTestsRunner {
            return Bundle.teacherBundleID
        } else if isParentTestsRunner {
            return Bundle.parentBundleID
        } else {
            return bundleIdentifier
        }
    }
    static var isExtension: Bool { Bundle.main.bundleURL.pathExtension == "appex" }
}
