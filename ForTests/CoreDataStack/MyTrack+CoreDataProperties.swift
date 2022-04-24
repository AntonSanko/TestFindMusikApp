//
//  MyTrack+CoreDataProperties.swift
//  ForTests
//
//  Created by Anton on 23/04/2022.
//
//

import Foundation
import CoreData


extension MyTrack {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTrack> {
        return NSFetchRequest<MyTrack>(entityName: "MyTrack")
    }

    @NSManaged public var name: String?
    @NSManaged public var artist: String?
    @NSManaged public var artworkUrl: URL?
    @NSManaged public var trackViewURL: URL?

}

extension MyTrack : Identifiable {

}
