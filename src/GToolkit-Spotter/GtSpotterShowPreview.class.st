Class {
	#name : #GtSpotterShowPreview,
	#superclass : #Announcement,
	#category : #'GToolkit-Spotter-Announcements'
}

{ #category : #'as yet unclassified' }
GtSpotterShowPreview >> asRecorderEvent [

	^ GTSpotterRecorderShowPreviewEvent fromAnnouncement: self
]