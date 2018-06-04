//
//  OrganizationCRUD.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-05-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSAuthCore


let OrganizationsCRUD = OrganizationsCRU()

public class OrganizationsCRU  {
	
	// . . .
	
	//Insert a note using Amazon DynamoDB
	func insertOrganizationWith(id: String, name: String) {
		
		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
		
		// Create a Note object using data model you downloaded from Mobile Hub
		let organization: Organizations = Organizations()

		organization._id = id
		organization._name = name
		organization._creationDate = NSDate().timeIntervalSince1970 as NSNumber
		
		//Save a new item
		
		dynamoDbObjectMapper.save(organization, completionHandler: {
			(error: Error?) -> Void in
			
			if let error = error {
				print("Amazon DynamoDB Save Error on new note: \(error)")
				return
			}
			print("New note was saved to DDB.")
		})
		
	}
	
//	//Insert a note using Amazon DynamoDB
//	func updateNoteDDB(noteId: String, noteTitle: String, noteContent: String)  {
//		
//		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
//		
//		let noteItem: Notes = Notes()
//		
//		noteItem._userId = AWSIdentityManager.default().identityId
//		noteItem._noteId = noteId
//		
//		if (!noteTitle.isEmpty){
//			noteItem._title = noteTitle
//		} else {
//			noteItem._title = emptyTitle
//		}
//		
//		if (!noteContent.isEmpty){
//			noteItem._content = noteContent
//		} else {
//			noteItem._content = emptyContent
//		}
//		
//		noteItem._updatedDate = NSDate().timeIntervalSince1970 as NSNumber
//		let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
//		updateMapperConfig.saveBehavior = .updateSkipNullAttributes //ignore any null value attributes and does not remove in database
//		dynamoDbObjectMapper.save(noteItem, configuration: updateMapperConfig, completionHandler: {(error: Error?) -> Void in
//			if let error = error {
//				print(" Amazon DynamoDB Save Error on note update: \(error)")
//				return
//			}
//			print("Existing note updated in DDB.")
//		})
//	}
//	
//	//Delete a note using Amazon DynamoDB
//	func deleteNoteDDB(noteId: String) {
//		let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
//		
//		let itemToDelete = Notes()
//		itemToDelete?._userId = AWSIdentityManager.default().identityId
//		itemToDelete?._noteId = noteId
//		
//		dynamoDbObjectMapper.remove(itemToDelete!, completionHandler: {(error: Error?) -> Void in
//			if let error = error {
//				print(" Amazon DynamoDB Save Error: \(error)")
//				return
//			}
//			print("An note was deleted in DDB.")
//		})
//	}
}
