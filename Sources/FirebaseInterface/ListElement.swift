//
//  ListElement.swift
//  
//
//  Created by Steven on 03.07.22.
//

import Foundation
import StrafenProjectTypes

/// Element of a database list, e.g. `Person`, `ReasonTemplate` or `Fine`.
internal protocol ListElement: Identifiable where ID: RawRepresentable, ID.RawValue == UUID {

    /// List element from firebase realtime database.
    associatedtype FRDListElement: Decodable

    /// Initializes element with id and frd element.
    /// - Parameter keyValueElement: Pair of id and frd element.
    init(_ keyValueElement: KeyValuePair<ID, FRDListElement>)
}

extension Person: ListElement {
    typealias FRDListElement = FRDPerson
}

extension ReasonTemplate: ListElement {
    typealias FRDListElement = FRDReasonTemplate
}

extension Fine: ListElement {
    typealias FRDListElement = FRDFine
}
