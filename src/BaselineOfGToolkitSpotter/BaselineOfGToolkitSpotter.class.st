Class {
	#name : #BaselineOfGToolkitSpotter,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitSpotter
}

{ #category : #baseline }
BaselineOfGToolkitSpotter >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec 
			baseline: 'Brick' with: [
				spec repository: 'github://feenkcom/Brick/src' ];
			baseline: 'GToolkitExamples' with: [
				spec repository: 'github://feenkcom/gtoolkit-examples/src' ].
		spec 
			package: 'GToolkit-Spotter' with: [
				spec requires: #(#Brick) ];
			package: 'GToolkit-Spotter-Examples' with: [
				spec requires: #(#GToolkitExamples #'GToolkit-Spotter' ). ]. ].
]