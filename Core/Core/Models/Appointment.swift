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

public final class Appointment: NSManagedObject, WriteableModel {
    public typealias JSON = APIAppointment
    @NSManaged public var id: String
    @NSManaged public var startAt: Date?
    @NSManaged public var endAt: Date?

    public static func save(_ item: APIAppointment, in context: NSManagedObjectContext) -> Appointment {
        let id = item.id.value
        let model: Appointment = context.first(where: #keyPath(Appointment.id), equals: id) ?? context.insert()

        model.id = id
        model.startAt = item.start_at
        model.endAt = item.end_at

        return model
    }
}
