//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class SelectOfficeHoursViweController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    var appointments: [Appointment] = []
    var selectedAppointmentIndex: IndexPath?
    var contextCodes: [String]?

    let env = AppEnvironment.shared

    lazy var officeHours = env.subscribe(GetAppointmentGroups()) { [weak self] in
        self?.update()
    }

    static func create(contextCodes: [String]? = nil) -> SelectOfficeHoursViweController {
        let vc = loadFromStoryboard()
        vc.contextCodes = contextCodes
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Office Hours", comment: "")
        officeHours.refresh(force: true)
    }

    func update() {
        if officeHours.pending == false {
            print("sections: \(officeHours.count)")
            tableView.reloadData()
        }
    }
}

extension SelectOfficeHoursViweController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        officeHours.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        officeHours[section]?.appointments?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var text = ""
        let a = officeHours[indexPath.section]?.appointments?[indexPath.row]
        if let s = a?.startAt, let e = a?.endAt {
            text = "\(DateFormatter.localizedString(from: s, dateStyle: .none, timeStyle: .short)) - \(DateFormatter.localizedString(from: e, dateStyle: .none, timeStyle: .short))"
        }

        let cell: PlannerFilterCell = tableView.dequeue(for: indexPath)
        cell.accessibilityIdentifier = "SelectOfficeHours.section.\(indexPath.section).row.\(indexPath.row)"
        cell.accessibilityLabel = text
        cell.courseNameLabel.text = text
        cell.isSelected = indexPath == selectedAppointmentIndex
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        officeHours[section]?.title
    }
}
