Class {
	#name : #GtSpotterDiveOut,
	#superclass : #Announcement,
	#instVars : [
		'element'
	],
	#category : #'GToolkit-Spotter-Announcements'
}

{ #category : #'as yet unclassified' }
GtSpotterDiveOut >> asRecorderEvent [
	^ GTSpotterRecorderDiveOutEvent fromAnnouncement: self
]

{ #category : #accessing }
GtSpotterDiveOut >> element [
	^ element
]

{ #category : #accessing }
GtSpotterDiveOut >> element: anObject [
	element := anObject
]