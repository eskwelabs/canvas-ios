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

import Foundation
import CoreData

public final class AppointmentGroup: NSManagedObject, WriteableModel {
    public typealias JSON = APIAppointmentGroup
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var htmlURL: URL?
    @NSManaged public var appointmentsRaw: NSOrderedSet?

    var appointments: [Appointment]? {
        get { appointmentsRaw?.array as? [Appointment] }
        set { appointmentsRaw = newValue.map { NSOrderedSet(array: $0) } }
    }

    public static func save(_ item: APIAppointmentGroup, in context: NSManagedObjectContext) -> AppointmentGroup {
        let id = item.id.value
        let model: AppointmentGroup = context.first(where: #keyPath(AppointmentGroup.id), equals: id) ?? context.insert()

        model.id = id
        model.title = item.title
        model.htmlURL = item.html_url

        model.appointments = item.appointments?.map {
            Appointment.save($0, in: context)
        }

        return model
    }
}
