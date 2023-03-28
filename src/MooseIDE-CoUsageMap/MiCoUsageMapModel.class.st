"
A model for the CoUsageMap browser
"
Class {
	#name : #MiCoUsageMapModel,
	#superclass : #MiAbstractModel,
	#instVars : [
		'settingsWindow',
		'containerEntities'
	],
	#category : #'MooseIDE-CoUsageMap-Model'
}

{ #category : #'private - for tests' }
MiCoUsageMapModel >> closeSettings [
	"used only for closing settings opened in tests"
	settingsWindow ifNotNil: [ settingsWindow close ]
]

{ #category : #accessing }
MiCoUsageMapModel >> collectionModel [

	^ containerEntities
]

{ #category : #accessing }
MiCoUsageMapModel >> collectionModel: anObject [

	containerEntities := anObject
]

{ #category : #accessing }
MiCoUsageMapModel >> entities [
	^containerEntities
]

{ #category : #actions }
MiCoUsageMapModel >> followEntity: aCollection [
	self collectionModel: aCollection.
	browser update
]

{ #category : #accessing }
MiCoUsageMapModel >> lastTagSelected [
	^lastTagSelected
]

{ #category : #accessing }
MiCoUsageMapModel >> lastTagSelected: aTag [
	lastTagSelected := aTag.
	self flag: 'updateTagCommand button'
]

{ #category : #accessing }
MiCoUsageMapModel >> miSelectedItem [
	self flag: 'Should be the attribute currently selected ?'.
	^ containerEntities
]

{ #category : #actions }
MiCoUsageMapModel >> openSettings [ 
	"For now, we handle settings here:
	 - create the window 
	 - subscribe to be informed when any window is closed closed
	 - if this is the setting window that is closed
	    - unsubscribe to ALL announcements
	    - update the visualization"

	| settingBrowser |
	settingBrowser := SettingBrowser new.
	settingBrowser
		changePackageSet:
			(OrderedCollection with:
				(RPackage organizer 
					packageNamed: MiCoUsageMapSettings package name)).
	settingsWindow := settingBrowser open.
	settingsWindow position: (self currentWorld extent - settingsWindow extent) // 2.
	settingBrowser expandAll.

	self currentWorld announcer when: WindowClosed do: [ :annoucement |
		(annoucement window = settingsWindow)
		ifTrue: [
			self currentWorld announcer unsubscribe: self.
			browser update
		]
	]
]

{ #category : #'as yet unclassified' }
MiCoUsageMapModel >> removeTagOn: aMooseEntity [
	aMooseEntity allTags
		detect: [ :aTag | aTag isHidden not ]
		ifOne: [ :aTag | aTag removeReference: aMooseEntity ]
		ifNone: [ "nothing" ]
]

{ #category : #accessing }
MiCoUsageMapModel >> settings [
	^MiCoUsageMapSettings
]

{ #category : #'as yet unclassified' }
MiCoUsageMapModel >> tagEntity: aMooseEntity with: aTag [
	self removeTagOn: aMooseEntity.

	aTag ifNotNil: [ 	| tagAssociation |
		tagAssociation := aTag addReference: aMooseEntity.
		self currentApplication consumeItem: tagAssociation.

		self lastTagSelected: aTag
	].

	browser updateTagColorFor: aMooseEntity
]