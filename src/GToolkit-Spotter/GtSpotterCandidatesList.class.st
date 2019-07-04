Class {
	#name : #GtSpotterCandidatesList,
	#superclass : #Object,
	#instVars : [
		'categories',
		'candidates',
		'announcer',
		'processorLinksMap'
	],
	#category : #'GToolkit-Spotter-Model'
}

{ #category : #'adding/removing' }
GtSpotterCandidatesList >> addAllCandidates: aCollection in: aProcessor [
	| allLinks |
	allLinks := OrderedCollection new.
	aCollection
		do: [ :each | 
			| processorLink candidateLink |
			processorLink := self getProcessorLink: aProcessor.
			candidateLink := each asSpotterCandidateLink processorLink: processorLink.	"if head is nil, it means there are no candidates yet"
			candidateLink := processorLink isEmpty
				ifTrue: [ self privateAddCandidate: candidateLink inEmpty: processorLink ]
				ifFalse: [ self privateAddCandidate: candidateLink inNotEmpty: processorLink ].
			self updateCycleConnectionFor: candidateLink.
			allLinks add: candidateLink ].
	self announcer announce:
			(GtSpotterAllCandidatesAdded new
				candidateLinks: allLinks;
				category: aProcessor;
				yourself)
]

{ #category : #'adding/removing' }
GtSpotterCandidatesList >> addCandidate: anObjectOrLink in: aProcessor [
	"before adding candidates we need to define all categories, because their order is important"
	|processorLink candidateLink|
	
	"processorLink is DoubleLink"
	processorLink := self getProcessorLink: aProcessor.
	
	candidateLink := anObjectOrLink asSpotterCandidateLink processorLink: processorLink.
	
	"if head is nil, it means there are no candidates yet"
	candidateLink := (processorLink isEmpty)
		ifTrue: [ self privateAddCandidate: candidateLink inEmpty: processorLink ]
		ifFalse: [ self privateAddCandidate: candidateLink inNotEmpty: processorLink ].
		
	self updateCycleConnectionFor: candidateLink.
	
	self notifyCandidateAdded: candidateLink in: aProcessor.
	
	^ candidateLink
	
]

{ #category : #'adding/removing' }
GtSpotterCandidatesList >> addProcessor: aProcessor [
	|processorLink|
	
	processorLink := aProcessor asSpotterProcessorLink.
	"linking processor with it's link"
	self processorLinksMap add: (aProcessor -> processorLink).
	self processors addLast: processorLink.
	
	^ processorLink
]

{ #category : #accessing }
GtSpotterCandidatesList >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtSpotterCandidatesList >> candidates [

	^ candidates ifNil: [ candidates := GtSpotterDoubleLinkedList new ]
]

{ #category : #candidates }
GtSpotterCandidatesList >> getCandidateLink: aCandiate in: aProcessor [
	"returns a corresponding candidateLink, that belongs to a processor"
	(self getCandidateLinks: (self getProcessorLink: aProcessor))
		do: [ :each | each value = aCandiate ifTrue: [ ^ each ] ].
	
	^ nil
	
]

{ #category : #candidates }
GtSpotterCandidatesList >> getCandidateLinks: aProcessorLink [
	"returns all candidate links that belongs to a processor link"
	|list head tail current|
	
	head := aProcessorLink headLink.
	tail := aProcessorLink tailLink.
	
	list := OrderedCollection new.
	head ifNil: [ ^ list ].
	(head = tail) ifTrue: [ list add: head. ^ list ].
	
	current := head.
	
	[ current = tail ] whileFalse: [
		list add: current.
		current := current nextLink ].
	"adding last one"
	list add: current.
	
	^ list
	
]

{ #category : #processors }
GtSpotterCandidatesList >> getProcessorLink: aProcessor [

	^ self processorLinksMap at: aProcessor ifAbsentPut: [ self addProcessor: aProcessor ]
]

{ #category : #processors }
GtSpotterCandidatesList >> getProcessorLinkByCandidateLink: aCandidateLink [

	^ aCandidateLink processorLink
]

{ #category : #candidates }
GtSpotterCandidatesList >> head [

	^ self candidates head
]

{ #category : #testing }
GtSpotterCandidatesList >> isEmpty [
	"Return true if there are no candidates in the list, false otherwise"
	<return: #Boolean>

	^ self candidates isEmpty
]

{ #category : #testing }
GtSpotterCandidatesList >> isNotEmpty [
	"Return true if there is at least one candidate in the list, false otherwise"
	<return: #Boolean>

	^ self isEmpty not
]

{ #category : #processors }
GtSpotterCandidatesList >> nextProcessorLinkOf: aProcessorLink [
	"returns next processor link, that has more than zero candidates.
	if passed processor is the last one, will continue searching from the beginning"
	|current|
	aProcessorLink ifNil: [ ^ aProcessorLink ].
	
	current := aProcessorLink nextLink.
	current ifNil: [ current := self processors head ].
	
	[ current = aProcessorLink ] whileFalse: [
		(current isEmpty) ifFalse: [ ^ current ].
		current := current nextLink.
		current ifNil: [ current := self processors head ].
	].

	^ aProcessorLink
	
]

{ #category : #notifying }
GtSpotterCandidatesList >> notifyAllCandidatesRemoved [

	self announcer announce: (GtSpotterAllCandidatesRemoved new)
]

{ #category : #notifying }
GtSpotterCandidatesList >> notifyCandidateAdded: aCandidateLink in: aProcessor [

	self announcer announce: (GtSpotterCandidateAdded new candidateLink: aCandidateLink; category: aProcessor; yourself).
]

{ #category : #'stream handling' }
GtSpotterCandidatesList >> onAmountChanged: anInteger in: aProcessor [
	"Amount must be non-negative"
	self assert: anInteger >= 0.
	
	"If amount is not positive there is no need to do anything"
	anInteger = 0 ifTrue: [ ^ self ].
	self announcer announce: (GtSpotterCandidatesAmountChanged new amount: anInteger; category: aProcessor; yourself)
]

{ #category : #processors }
GtSpotterCandidatesList >> previousProcessorLinkOf: aProcessorLink [
	"returns previous processor link, that has more than zero candidates.
	if passed processor is the first one, will continue searching from the end"
	|current|
	aProcessorLink ifNil: [ ^ aProcessorLink ].
	
	current := aProcessorLink previousLink.
	current ifNil: [ current := self processors tail ].
	
	[ current = aProcessorLink ] whileFalse: [
		(current isEmpty) ifFalse: [ ^ current ].
		current := current previousLink.
		current ifNil: [ current := self processors tail ].
	].

	^ aProcessorLink
	
]

{ #category : #private }
GtSpotterCandidatesList >> privateAddCandidate: aCandidateLink inEmpty: aProcessorLink [
	| head current |
		
	current := aProcessorLink.	"not nil"
	head := nil.						"nil"
	[ head isNil and: [ current isNotNil ]] whileTrue: [	
		current := current nextLink.	"next category"
		"head of next category if not nil break loop"
		current ifNotNil: [ head := current headLink ] ifNil: [ nil ] ].
	
	"means all next categories are empty, just add to the end"
	current
		ifNil: [ self candidates addLast: aCandidateLink ]
		ifNotNil: [ self candidates add: aCandidateLink beforeLink: head ].
		aProcessorLink
			headLink: aCandidateLink;
			tailLink: aCandidateLink.
			
		aProcessorLink incrementSize.
		
	^ aCandidateLink
]

{ #category : #private }
GtSpotterCandidatesList >> privateAddCandidate: aCandidateLink inNotEmpty: aProcessorLink [
	
	"aCandidateLink weight
		ifNotNil: [ ^ self privateAddCandidate: aCandidateLink weightedIn: aProcessorLink ]."
	
	self candidates add: aCandidateLink afterLink: (aProcessorLink tailLink).
	aProcessorLink incrementSize.
	"updating category tail"
	aProcessorLink tailLink: aCandidateLink.
	^ aCandidateLink
]

{ #category : #private }
GtSpotterCandidatesList >> privateAddCandidate: aCandidateLink weightedIn: aProcessorLink [

	^ aProcessorLink isFull
		ifTrue: [ self privateAddCandidate: aCandidateLink weightedInFull: aProcessorLink ]
		ifFalse: [ self privateAddCandidate: aCandidateLink weightedInNotFull: aProcessorLink ]
]

{ #category : #private }
GtSpotterCandidatesList >> privateAddCandidate: aCandidateLink weightedInFull: aProcessorLink [

	
]

{ #category : #private }
GtSpotterCandidatesList >> privateAddCandidate: aCandidateLink weightedInNotFull: aProcessorLink [
	|head tail|
	
	head := aProcessorLink headLink.
	tail := aProcessorLink tailLink.

	"fast check if we need to add it before first"
	(aCandidateLink weight > head weight)
		ifTrue: [ head := self candidates add: aCandidateLink beforeLink: head ]
		ifFalse: [
	"fast check if we need to add it after the last"
	(aCandidateLink weight > tail weight)
		ifFalse: [ tail := self candidates add: aCandidateLink afterLink: tail ]
		ifTrue: [  ] ]
]

{ #category : #accessing }
GtSpotterCandidatesList >> processorLinksMap [

	^ processorLinksMap ifNil: [ processorLinksMap := Dictionary new ]
	
]

{ #category : #accessing }
GtSpotterCandidatesList >> processors [

	^ categories ifNil: [ categories := GtSpotterDoubleLinkedList new ].
]

{ #category : #'adding/removing' }
GtSpotterCandidatesList >> removeAllCandidates [

	self processors linksDo: [ :each | each clear ].
	self candidates removeAll.
	self notifyAllCandidatesRemoved
]

{ #category : #'adding/removing' }
GtSpotterCandidatesList >> removeAllCandidatesOf: aProcessor [
	|processorLink head tail current|
	
	processorLink := self getProcessorLink: aProcessor.
	
	(processorLink isEmpty) ifTrue: [ ^ self ].
	
	head := processorLink headLink.
	tail := processorLink tailLink.
		
	(head = tail) ifTrue: [
		self candidates removeCycledLink: head.
		processorLink clear. ].
	
	current := head.
	[ current = tail ] whileFalse: [ |nextCurrent|
		nextCurrent := current nextLink.
		self candidates removeCycledLink: current.
		current := nextCurrent ].
	
	self candidates removeCycledLink: current.
	
	processorLink clear.
	
	
	
	
	
	
]

{ #category : #candidates }
GtSpotterCandidatesList >> tail [

	^ self candidates tail
]

{ #category : #candidates }
GtSpotterCandidatesList >> updateCycleConnectionFor: aCandidateLink [

	"if link is the last setting nextLink to head"
	(self candidates tail = aCandidateLink) ifTrue: [
		aCandidateLink nextLink: self candidates head.
		self candidates head previousLink: aCandidateLink ].
	
	"if link is the first setting previousLink to tail"
	(self candidates head = aCandidateLink) ifTrue: [
		aCandidateLink previousLink: self candidates tail.
		self candidates tail nextLink: aCandidateLink ].
]