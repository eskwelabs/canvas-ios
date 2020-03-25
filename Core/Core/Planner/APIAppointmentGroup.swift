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

public struct APIAppointment: Codable, Equatable {
    let id: ID
    let start_at: Date
    let end_at: Date
}

public struct APIAppointmentGroup: Codable, Equatable {
    let id: ID
    let title: String
    let start_at: Date?
    let end_at: Date?
    let description: String?
    let location_name: String?
    let location_address: String?
    let participant_count: Int?
    // The start and end times of slots reserved by the current user as well as the
    // id of the calendar event for the reservation (see include[] argument)
    // let reserved_times: [{"id":987,"start_at":"2012-07-20T15:00:00-06:00","end_at":"2012-07-20T15:00:00-06:00"}],
    // The context codes (i.e. courses) this appointment group belongs to. Only
    // people in these courses will be eligible to sign up.
    let context_codes: [String]?
    // The sub-context codes (i.e. course sections and group categories) this
    // appointment group is restricted to
    let sub_context_codes: [String]?  //[course_section_234],
    // Current state of the appointment group ('pending', 'active' or 'deleted').
    // 'pending' indicates that it has not been published yet and is invisible to
    // participants.
    let workflow_state: String //"active",
    // Boolean indicating whether the current user needs to sign up for this
    // appointment group (i.e. it's reservable and the
    // min_appointments_per_participant limit has not been met by this user).
    let requiring_action: Bool?
    // Number of time slots in this appointment group
    let  appointments_count: Int?
    // Calendar Events representing the time slots (see include[] argument) Refer to
    // the Calendar Events API for more information
    let appointments: [APIAppointment]?
    // Newly created time slots (same format as appointments above). Only returned
    // in Create/Update responses where new time slots have been added
    //    let new_appointments: [],
    // Maximum number of time slots a user may register for, or null if no limit
    let max_appointments_per_participant: Int?
    // Minimum number of time slots a user must register for. If not set, users do
    // not need to sign up for any time slots
    let min_appointments_per_participant: Int?
    // Maximum number of participants that may register for each time slot, or null
    // if no limit
    let participants_per_appointment: Int?
    // 'private' means participants cannot see who has signed up for a particular
    // time slot, 'protected' means that they can
    let participant_visibility: String?  //"private",
    // Indicates how participants sign up for the appointment group, either as
    // individuals ('User') or in student groups ('Group'). Related to
    // sub_context_codes (i.e. 'Group' signups always have a single group category)
    let participant_type: String? //"User",
    // URL for this appointment group (to update, delete, etc.)
    let url: URL?
    // URL for a user to view this appointment group
    let html_url: URL?
//    let created_at: Date?
//    let updated_at: Date?
}


#if DEBUG

extension APIAppointment {
    public static func make(
        id: ID = "1",
        start_at: Date = Clock.now.addDays(1),
        end_at: Date = Clock.now.addDays(1).addMinutes(15)
    ) -> APIAppointment {
        return APIAppointment(id: id, start_at: start_at, end_at: end_at)
    }
}

extension APIAppointmentGroup {
    public static func make(
        id: ID = "1",
        title: String = "title",
        html_url: URL? = nil,
        appointments: [APIAppointment]? = [.make()]
    ) -> APIAppointmentGroup {
        return APIAppointmentGroup(id: id,
                                   title: title,
                                   start_at: nil,
                                   end_at: nil,
                                   description: nil,
                                   location_name: nil,
                                   location_address: nil, 
                                   participant_count: nil,
                                   context_codes: nil,
                                   sub_context_codes: nil,
                                   workflow_state: "active",
                                   requiring_action: nil,
                                   appointments_count: nil,
                                   appointments: appointments,
                                   max_appointments_per_participant: nil,
                                   min_appointments_per_participant: nil,
                                   participants_per_appointment: nil,
                                   participant_visibility: nil,
                                   participant_type: "USER",
                                   url: nil,
                                   html_url: html_url)
    }
}

#endif


//  https://canvas.instructure.com/doc/api/appointment_groups.html#method.appointment_groups.next_appointment
public struct GetAppointmentGroupsRequest: APIRequestable {
    public typealias Response = [APIAppointmentGroup]
    public var path: String = "appointment_groups"

    public enum Include: String {
        case appointments, child_events, participant_count, reserved_times, all_context_codes
    }

    var includes: [Include]
    var contextCodes: [String]?

    public init(includes: [Include] = [.appointments], contextCodes: [String]? = nil) {
        self.includes = includes
        self.contextCodes = contextCodes
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(includes.map { $0.rawValue }),
        ]

        if let contextCodes = contextCodes {
            query.append( .array("context_codes", contextCodes) )
        }

        return query
    }
}

//  https://canvas.instructure.com/doc/api/appointment_groups.html#method.appointment_groups.next_appointment
public struct GetNextAppointmentRequest: APIRequestable {
    public typealias Response = [APICalendarEvent]
    public var path: String = "appointment_groups/next_appointment"
}
