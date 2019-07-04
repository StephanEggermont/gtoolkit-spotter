Class {
	#name : #GtSpotterPager,
	#superclass : #BrPager,
	#instVars : [
		'spotterModel'
	],
	#category : #'GToolkit-Spotter-UI-Bloc'
}

{ #category : #initialization }
GtSpotterPager >> initialize [
	super initialize.

	self look: BrScrollablePagerLook new + BrLayoutLook linearVertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ]
]

{ #category : #'event handling' }
GtSpotterPager >> onCurrentStepChanged: anAnnouncement [
	self smoothScrollTo: anAnnouncement index
]

{ #category : #'event handling' }
GtSpotterPager >> onStepAdded: anAnnouncement [
	"as soon as step added we need to push it"
	
	self pushStep: anAnnouncement stepModel
]

{ #category : #'event handling' }
GtSpotterPager >> onStepRemoved: anAnnouncement [
	"as soon as step added we need to push it"
	
	self removePageAt: anAnnouncement index
]

{ #category : #'actions api' }
GtSpotterPager >> pushStep: aSpotterStep [
	| aStepElement aPageModel aPageContainer |
	
	aStepElement := aSpotterStep asElement.
	
	aPageModel := BrPagerPageModel new.
	aPageModel model: aSpotterStep.
	
	aPageContainer := BlElement new.
	aPageContainer constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	
	aPageContainer addChild: aStepElement.
	aPageContainer viewModel: aPageModel.
	
	self addPage: aPageContainer
]

{ #category : #accessing }
GtSpotterPager >> spotterModel [
	^ spotterModel
]

{ #category : #accessing }
GtSpotterPager >> spotterModel: aModel [ 
	spotterModel := aModel.

	spotterModel steps do: [ :eachStep | self pushStep: eachStep ].

	spotterModel announcer when: GtSpotterStepAdded send: #onStepAdded: to: self.
	spotterModel announcer when: GtSpotterStepRemoved send: #onStepRemoved: to: self.
	spotterModel announcer when: GtSpotterCurrentStepChanged send: #onCurrentStepChanged: to: self
]