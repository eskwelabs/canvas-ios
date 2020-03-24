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

public class GetAppointmentGroups: CollectionUseCase {
    public typealias Model = AppointmentGroup

    public var cacheKey: String? {
        "get-appointment-groups"
    }

    public var scope: Scope {
//        var predicate = NSPredicate(format: "%@ <= %K AND %K < %@",
//            startDate as NSDate, #keyPath(Plannable.date),
//            #keyPath(Plannable.date), endDate as NSDate
//        )
//        if let userID = userID {
//            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
//                NSPredicate(key: #keyPath(Plannable.userID), equals: userID),
//                predicate,
//            ])
//        }
//        let order = [
//            NSSortDescriptor(key: #keyPath(Plannable.date), ascending: true),
//            NSSortDescriptor(key: #keyPath(Plannable.title), ascending: true, naturally: true),
//        ]
//        return Scope(predicate: predicate, order: order)
        return .all(orderBy: #keyPath(AppointmentGroup.id))
    }

    public var request: GetAppointmentGroupsRequest {
        return GetAppointmentGroupsRequest(includes: [GetAppointmentGroupsRequest.Include.appointments])
    }
}
