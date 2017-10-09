!classDefinition: #Token category: #'Game-Graphics'!
EllipseMorph subclass: #Token
	instanceVariableNames: 'labelArea model who count die arrow id hop'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!Token commentStamp: 'dhn 7/10/2016 11:44' prior: 0!
A player's piece on the game board.!


!Token methodsFor: 'accessing' stamp: 'dhn 9/24/2016 15:44:32'!
arrow
	"Answer the value of arrow"

	^ arrow! !

!Token methodsFor: 'accessing' stamp: 'dhn 2/18/2017 18:16:13'!
arrowPosition
	"Answer the position for the arrow"

	^ (self morphWidth / 3)@-60! !

!Token methodsFor: 'accessing' stamp: 'dhn 10/9/2011 20:04'!
count
	"Answer the value of count"

	count ifNil: [count := 0].
	^ count! !

!Token methodsFor: 'accessing' stamp: 'dhn 10/9/2011 19:54'!
count: anObject
	"Set the value of count"

	count := anObject! !

!Token methodsFor: 'accessing' stamp: 'dhn 9/24/2016 15:44:32'!
die
	"Answer the value of die"

	^ die! !

!Token methodsFor: 'accessing' stamp: 'dhn 9/24/2016 15:44:32'!
die: anObject
	"Set the value of die"

	die _ anObject! !

!Token methodsFor: 'accessing' stamp: 'dhn 9/24/2016 15:53:50'!
id
	"Answer the value of id"

	^ id! !

!Token methodsFor: 'accessing' stamp: 'dhn 3/18/2017 13:10:52'!
id: anObject
	"Set the value of id"

	id _ anObject! !

!Token methodsFor: 'accessing' stamp: 'dhn 8/25/2016 17:23:29'!
labelArea
	"Answer the value of labelArea"

	^ labelArea! !

!Token methodsFor: 'accessing' stamp: 'dhn 8/25/2016 17:24:01'!
labelArea: anObject
	"Set the value of labelArea"

	labelArea _ anObject! !

!Token methodsFor: 'accessing' stamp: 'dhn 10/11/2011 21:53'!
who
	"Answer the value of who"

	^ who! !

!Token methodsFor: 'accessing' stamp: 'dhn 10/11/2011 21:53'!
who: anObject
	"Set the value of who"

	who := anObject! !


!Token methodsFor: 'initialization' stamp: 'dhn 8/8/2017 11:31:47'!
arrowLeft
	"Associate an arrow with the sender, pointing to the left"

	arrow _ ArrowMorph new
		form: (BitBltCanvas arrowOfDirection: #left size: 40) as8BitColorForm.
	self addMorph: arrow.
	arrow openInWorld: self.
	arrow morphPosition: self arrowPosition

! !

!Token methodsFor: 'initialization' stamp: 'dhn 8/8/2017 11:31:24'!
arrowRight
	"Associate an arrow with the sender, pointing to the right"

	arrow _ ArrowMorph new
		form: (BitBltCanvas arrowOfDirection: #right size: 40) as8BitColorForm.
	self addMorph: arrow.
	arrow openInWorld: self.
	arrow morphPosition: self arrowPosition
! !

!Token methodsFor: 'initialization' stamp: 'dhn 8/22/2016 20:12:13'!
identity: aString
	"Set the layout for the player's name"

	^ (StringMorph 
		contents: aString 
		font: (AbstractFont familyName: 'DejaVu' aroundPointSize: 10)
		emphasis: AbstractFont boldCode)
			morphPosition: 50@18! !

!Token methodsFor: 'initialization' stamp: 'dhn 3/22/2017 11:27:16'!
initialize

	super initialize.
	
	hop _ OrderedCollection new.
	180 to: 360 by: 18 do: [:a | hop add: 6 * (a degreesToRadians cos * 2)].
	
	self setBalloonText: 'A token representing the player. When the Move button is clicked, 
a die is "rolled" and the token moves that number of spaces.'! !

!Token methodsFor: 'initialization' stamp: 'dhn 3/21/2017 18:47:12'!
model
	"Answer the value of model"

	^ model! !

!Token methodsFor: 'initialization' stamp: 'dhn 3/21/2017 18:46:25'!
model: anObject
	"Set the value of model"

	model _ anObject! !

!Token methodsFor: 'initialization' stamp: 'dhn 8/17/2017 13:22:03'!
posAdjust
	"Answer the position"
	| ver hor |
	
	ver _ model world morphExtent y * 8 / 10.
	hor _ model world morphExtent x * 0.025.
	^ hor@ver! !

!Token methodsFor: 'initialization' stamp: 'dhn 3/21/2017 14:17:20'!
setSize
	"Set the extent of the receiver"
	| w h |
	
	w _ owner morphExtent x * 0.13.
	h _ w * 0.5.
	self morphExtent: w@h! !


!Token methodsFor: 'stepping' stamp: 'dhn 4/8/2017 20:35:06'!
jump: aCount
	"Move the receiver in aCount hops"
	| step limit i horiz |
	
	step _ 30.	"time of each increment of the hop"
	limit _ hop size * (aCount min: 6).
	horiz _ (who mgr cells first morphWidth +2)/ (hop size).
	i _ 0.
	self when: #morphicStep evaluate: [ :delta |
		i _ i + 1.
		i < limit 
			ifTrue: [self morphPosition: (self morphPosition translatedBy: horiz@(hop atWrap: i))]
			ifFalse: [
				self stopStepping.
				self removeActionsForEvent: #morphicStep.
				self moved]].
	self startSteppingStepTime: step. 	
! !

!Token methodsFor: 'stepping' stamp: 'dhn 8/9/2017 22:06:33'!
moveFrom: positionA to: positionB
	"Determine best direction and move"
	| dir |
	
	dir _ Direction
		shortest: positionA
		to: positionB
		in: who mgr spaces size.
	dir > 0
		ifTrue: [self arrowRight]
		ifFalse: [self arrowLeft].
	self moveFrom: positionA to: positionB by: dir enabling: {}! !

!Token methodsFor: 'stepping' stamp: 'dhn 8/12/2017 10:54:35'!
moveFrom: start to: end by: direction
	"Animate moves forward or backward."
	| a b board posns limit i |
	
	a _ start.
	b _ end.
	board _ model class describeSpaces.
	direction < 0
		ifTrue: [start < end ifTrue: [	a _ start + board size]]
		ifFalse: [start > end ifTrue: [b _ end + board size]].
	posns _ (Interval from: a to: b by: direction) asArray.
	limit _ posns size.
	i _ 0.
	self when: #morphicStep evaluate: [ :unused |
		i _ i + 1.
		model positionBoardTo: (posns at: i).
		i < limit 
			ifFalse: [
				self stopStepping.
				self removeActionsForEvent: #morphicStep.
				arrow delete.
				model currentPlayer position: (posns at: i)]].
	self startSteppingStepTime: 400
! !

!Token methodsFor: 'stepping' stamp: 'dhn 8/10/2017 11:55:21'!
moveFrom: start to: end by: direction enabling: anArray
	"Animate moves forward or backward."
	| a b board posns limit i |
	
	a _ start.
	b _ end.
	board _ model class describeSpaces.
	direction < 0
		ifTrue: [start < end ifTrue: [	a _ start + board size]]
		ifFalse: [start > end ifTrue: [b _ end + board size]].
	posns _ (Interval from: a to: b by: direction) asArray.
	limit _ posns size.
	i _ 0.
	self when: #morphicStep evaluate: [ :unused |
		i _ i + 1.
		model positionBoardTo: (posns at: i).
		i < limit 
			ifFalse: [
				self stopStepping.
				self removeActionsForEvent: #morphicStep.
				arrow delete.
				model currentPlayer position: (posns at: i).
				self doubled contents: model currentPlayer doubledString.
				model currentPlayer canDoJob ifTrue: [model enableAll: {'Do Job'}].
				model enableAll: anArray]].
	self startSteppingStepTime: 400
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Token class' category: #'Game-Graphics'!
Token class
	instanceVariableNames: ''!

!Token class methodsFor: 'instance creation' stamp: 'dhn 7/11/2013 14:42'!
colors
	"Answer the colors that players can have."
	^ {Color r: 0.0 g: 0.634 b: 1. 
		Color r: 0.729 g: 0.455 b: 0.819. 
		Color r: 0.544 g: 0.729 b: 0.544. 
		Color r: 0.909 g: 0.27 b: 0.729. 
		Color r: 0.634 g: 0.729 b: 1. 
		Color cyan. Color green. Color red. Color orange. Color magenta}! !

!Token class methodsFor: 'instance creation' stamp: 'dhn 1/20/2017 11:58:56'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !

!Token class methodsFor: 'instance creation' stamp: 'dhn 4/8/2017 20:24:59'!
newFor: aModel
	"Establish an instance with model aModel"
	
	^ self initializedInstance model: aModel! !


!Token class methodsFor: 'operation' stamp: 'dhn 12/2/2011 22:32'!
rollCount
	"Answer the number of iterations for a roll"
	^ 1! !


!classDefinition: #GameButtonMorph category: #'Game-Graphics'!
PluggableButtonMorph subclass: #GameButtonMorph
	instanceVariableNames: 'oldTarget enabled'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!GameButtonMorph commentStamp: '<historical>' prior: 0!
A button morph which can be disabled and enabled.!


!GameButtonMorph methodsFor: 'state' stamp: 'dhn 7/23/2016 15:33'!
disableButton
	"Change to the disabled state, caching the actionSelector"
	
	self enabled ifTrue: [
		self oldTarget: self actionSelector.
		self action: nil.
		self enabled: false.
		self color: GameButtonMorph disabledColor]! !

!GameButtonMorph methodsFor: 'state' stamp: 'dhn 7/23/2016 15:34'!
enableButton
	"Change to the enabled state"
	
	self enabled ifFalse: [
		oldTarget ifNotNil: [self action: oldTarget].
		self enabled: true.
		self color: GameButtonMorph enabledColor]! !


!GameButtonMorph methodsFor: 'accessing' stamp: 'dhn 10/12/2011 16:05'!
enabled
	"Answer the value of enabled"

	enabled ifNil: [enabled := true].
	^ enabled! !

!GameButtonMorph methodsFor: 'accessing' stamp: 'dhn 10/12/2011 16:04'!
enabled: aBoolean
	"Set the value of enabled"

	enabled := aBoolean! !

!GameButtonMorph methodsFor: 'accessing' stamp: 'dhn 7/23/2016 15:05'!
label
	"Answer the button label"
	
	^ label! !

!GameButtonMorph methodsFor: 'accessing' stamp: 'dhn 10/12/2011 16:03'!
oldTarget: anObject
	"Set the value of oldTarget"

	oldTarget := anObject! !


!GameButtonMorph methodsFor: 'initialization' stamp: 'dhn 9/3/2013 19:44'!
initialize
	super initialize! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'GameButtonMorph class' category: #'Game-Graphics'!
GameButtonMorph class
	instanceVariableNames: ''!

!GameButtonMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 7/23/2016 09:36'!
defaultExtent
	"Answer the default extent for a button: width@height"
	
	^ 90@40! !

!GameButtonMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 10/12/2011 16:26'!
disabledColor
	^Color veryLightGray! !

!GameButtonMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 10/12/2011 16:29'!
enabledColor
	^Color r: 0.4 g: 0.8 b: 0.6! !

!GameButtonMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 7/23/2016 15:41'!
label: label action: actionSymbol state: stateSymbol model: aModel
	"Create an instance of this class"
	| btn |
	
	btn _ self new
		label: label;
		morphExtent: self defaultExtent;
		model: aModel.
	stateSymbol 
		ifNil: [
			btn 
				enabled: true;
				action: actionSymbol;
				color: self enabledColor]
		ifNotNil: [
			stateSymbol 
				ifTrue: [
					btn 
						enabled: true;
						action: actionSymbol;
						color: self enabledColor]
				ifFalse: [
					btn 
						enabled: false;
						action: nil;
						oldTarget: actionSymbol;
						color: self disabledColor]].

	^ btn! !


!classDefinition: #BidderButton category: #'Game-Graphics'!
GameButtonMorph subclass: #BidderButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!BidderButton commentStamp: 'dhn 8/14/2017 11:27:04' prior: 0!
A button to enable players to offer bids. This class provides polymorphism which differs from super in that the action is performed with a passed parameter.!


!BidderButton methodsFor: 'updating' stamp: 'dhn 9/17/2016 21:49:30'!
performAction
	"Inform the model that this button has been pressed and pass the label. "

	actionSelector ifNotNil: [
		model perform: actionSelector with: label]! !


!classDefinition: #GameCell category: #'Game-Graphics'!
TextModelMorph subclass: #GameCell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!GameCell commentStamp: 'dhn 8/2/2016 16:49:15' prior: 0!
A description of the board space represented by a cell.!


!GameCell methodsFor: 'accessing' stamp: 'dhn 8/14/2017 10:59:26'!
describe
	"Answer the default cell content which is needed during initialization"

	model actualContents ifNil: [model actualContents: ''].
	^ model actualContents! !


!classDefinition: #GameBoard category: #'Game-Graphics'!
SystemWindow subclass: #GameBoard
	instanceVariableNames: 'pasteup board buttonArea gameTitle'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!GameBoard commentStamp: 'dhn 8/21/2016 21:38:39' prior: 0!
Abstract class for views of a board game.!


!GameBoard methodsFor: 'accessing' stamp: 'dhn 3/5/2017 18:00:18'!
board
	"Answer the value of board"

	^ board! !

!GameBoard methodsFor: 'accessing' stamp: 'dhn 7/25/2016 11:17'!
gameTitle
	"Answer the value of gameTitle"

	^ gameTitle! !

!GameBoard methodsFor: 'accessing' stamp: 'dhn 9/10/2016 20:15:07'!
layoutMorph
	"Answer the value of layoutMorph"
	
	^ layoutMorph! !

!GameBoard methodsFor: 'accessing' stamp: 'dhn 3/23/2017 20:54:14'!
pasteup
	"Answer the value of pasteup"

	^ pasteup! !


!GameBoard methodsFor: 'initialization' stamp: 'dhn 7/12/2016 19:58'!
buttonAreaHeight

	^ 30! !

!GameBoard methodsFor: 'initialization' stamp: 'dhn 9/10/2016 20:19:36'!
defaultExtent

	^ (Display width) @ (Display height * 0.6)! !

!GameBoard methodsFor: 'initialization' stamp: 'dhn 10/19/2016 16:40:06'!
initialize

	super initialize! !

!GameBoard methodsFor: 'initialization' stamp: 'dhn 8/3/2016 15:53:27'!
labelAreaHeight

	^ 50! !

!GameBoard methodsFor: 'initialization' stamp: 'dhn 11/8/2016 16:51:43'!
makeTitleArea
	"Lay out the area for title"
	| area |
	
	area _ LayoutMorph newRow.
	area
			color: Color transparent;
			name: #title;
			padding: #center.
	
	gameTitle _ (StringMorph contents: '') 
		emphasis: AbstractFont boldCode;
		font: (AbstractFont familyName: 'DejaVu' aroundPointSize: 22).
		
	area addMorph: gameTitle.
	^ area	layoutSpec: (LayoutSpec  
		proportionalWidth: 1.0
		proportionalHeight: self class titleHeight)	! !

!GameBoard methodsFor: 'initialization' stamp: 'dhn 7/12/2016 19:43'!
morphWidth
	"Specify the width of the board"
	
	^ Display width! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'GameBoard class' category: #'Game-Graphics'!
GameBoard class
	instanceVariableNames: ''!

!GameBoard class methodsFor: 'as yet unclassified' stamp: 'dhn 7/17/2016 13:51'!
gameFont
	"Answer the font for balloon help"
	
	^ AbstractFont familyNames     
		detect: [:f | f = 'ComicPlain'] ifNone: [^ AbstractFont default]! !

!GameBoard class methodsFor: 'as yet unclassified' stamp: 'dhn 7/18/2016 10:37'!
submorphProportion
	"Answer the proportional width which extends almost to the game board border"
	
	^ 0.99! !


!GameBoard class methodsFor: 'instance creation' stamp: 'dhn 11/8/2016 16:52:40'!
titleHeight
	"Answer the proportional height for morphs such as title"
	
	^ 0.11! !


!classDefinition: #ListView category: #'Game-Graphics'!
SystemWindow subclass: #ListView
	instanceVariableNames: 'collection selectedItem text1'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!ListView commentStamp: 'dhn 7/10/2016 17:20' prior: 0!
An abstract class for game windows.!


!ListView methodsFor: 'text view 1' stamp: 'dhn 12/10/2013 21:07'!
accept1: string from: aPluggableTextMorph 
	"Sent by a PluggableTextMorph to tell that its string has changed and
	can now be taken by the receiver. 
	This method is sent from method accept of the PluggableTextMorph,
	a method that is frequently used as a menu activity.
	This method copies the changed string into the receiver and it
	answers 'true' to tell the =PluggableTextMorph that the string was
	accepted. "
	text1 := string.
	selectedItem ~= 0
		ifTrue: [(collection at: selectedItem)
				at: 1
				put: string].
	^ true! !

!ListView methodsFor: 'text view 1' stamp: 'dhn 12/10/2013 21:07'!
text1
	"Sent by a PluggableTextMorph to get a string to display."
	^ text1! !

!ListView methodsFor: 'text view 1' stamp: 'dhn 12/22/2013 11:58'!
text1: aString 
	text1 := aString.
! !


!ListView methodsFor: 'initialize-release' stamp: 'dhn 12/10/2013 21:07'!
buttonFor: aMorph target: anObject action: aSelector label: aString 
	^ aMorph target: anObject;
		 label: aString;
		 useRoundedCorners;
		 actionSelector: aSelector! !

!ListView methodsFor: 'initialize-release' stamp: 'dhn 12/10/2013 21:12'!
initialize
	super initialize.
	text1 := ''.
	selectedItem := 0! !


!ListView methodsFor: 'accessing' stamp: 'dhn 12/22/2013 12:21'!
collection
	^ collection! !

!ListView methodsFor: 'accessing' stamp: 'dhn 12/10/2013 21:07'!
collection: anObject
	"Set the value of collection"

	collection := anObject! !

!ListView methodsFor: 'accessing' stamp: 'dhn 12/10/2013 21:07'!
selectedItem
	"Answer the value of selectedItem"

	^ selectedItem! !

!ListView methodsFor: 'accessing' stamp: 'dhn 12/10/2013 21:07'!
selectedItem: anObject
	"Set the value of selectedItem"

	selectedItem := anObject! !


!ListView methodsFor: 'list view' stamp: 'dhn 12/10/2013 21:07'!
currentSelection
  "  Sent by a PluggableListMorph to get the current selection.
    Answer the index of the currently selected item.
    A value of 0 means that no item is currently selected. "
  ^selectedItem   
! !

!ListView methodsFor: 'list view' stamp: 'dhn 12/10/2013 21:07'!
list
   " Sent by a PluggableListMorph to get a list to display.
     Answer a collection of strings, the items that are displayed by the morph."
 ^collection .   
! !


!ListView methodsFor: 'common text menu' stamp: 'dhn 12/10/2013 21:07'!
menu: aMenuMorph 
	"Sent by a PluggableTextMorph to get a menu.
	In this example, all text morphs use the same menu. This is not
	always a feasible solution, but here it is."
	aMenuMorph add: 'accept' action: #accept.
	"#accept is a method of PluggableTextMorph"
	^ aMenuMorph! !


!classDefinition: #DieMorph category: #'Game-Graphics'!
PluggableMorph subclass: #DieMorph
	instanceVariableNames: 'dot value'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!DieMorph commentStamp: '<historical>' prior: 0!
A die (one half of a pair of dice).!


!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 11:13:10'!
adjustTo: aMorph
	"Set position based on anObject"
	| s |
	
	s _ aMorph morphExtent x * 50 / 132.
	self 
		morphExtent: s@s;
		setDots;
		referencePosition: aMorph referencePosition - (0@2 * aMorph morphHeight)! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:40:34'!
bottom
	"Answer the displacement which will locate an ellipse near the bottom"
	
	^ self morphExtent y * 0.65
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:10:28'!
center
	"Answer the horizontal displacement which will center an ellipse"
	
	^ self morphExtent x * 0.38
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:12:02'!
face1
	"Set the die to 1"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self center@self center).
	^ 1
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:50:31'!
face2
	"Set the die to 2, left"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	^ 2
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:50:22'!
face2b
	"Set the die to 2, right"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 2! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:50:06'!
face3
	"Set the die to 3, left"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self center@self center).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	^ 3! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:49:48'!
face3b
	"Set the die to 3, right"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self center@self center).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 3
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:54:25'!
face4
	"Set the die to 4"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 4
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:53:16'!
face5
	"Set the die to 5"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self center@self center).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 5
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 10:29:08'!
face6
	"Set the die to 6, horizontal"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self center@self top).
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	self addMorph: (dot copy morphPosition: self center@self bottom).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 6
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 10:31:36'!
face6b
	"Set the die to 6, vertical"
	
	self removeAllMorphs.
	self addMorph: (dot copy morphPosition: self left@self top).
	self addMorph: (dot copy morphPosition: self left@self center).
	self addMorph: (dot copy morphPosition: self left@self bottom).
	self addMorph: (dot copy morphPosition: self right@self top).
	self addMorph: (dot copy morphPosition: self right@self center).
	self addMorph: (dot copy morphPosition: self right@self bottom).
	^ 6
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:35:08'!
left
	"Answer the displacement which will locate an ellipse near the left edge"
	
	^ self morphExtent x * 0.10
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:42:26'!
right
	"Answer the displacement which will locate an ellipse near the right edge"
	
	^ self morphExtent x * 0.65
! !

!DieMorph methodsFor: 'drawing' stamp: 'dhn 8/21/2017 09:36:06'!
top
	"Answer the displacement which will locate an ellipse near the top"
	
	^ self morphExtent y * 0.10
! !


!DieMorph methodsFor: 'initialization' stamp: 'dhn 8/21/2017 11:17:03'!
initialize

	super initialize.
	self 
		borderWidth: 2;
		color: Color lightGreen! !

!DieMorph methodsFor: 'initialization' stamp: 'dhn 8/21/2017 11:27:25'!
setDots
	"Initialize the dot"
	
	dot _ EllipseMorph new
		color: Color black;
		borderWidth: 0;
		morphExtent: self morphExtent * 0.24! !


!DieMorph methodsFor: 'operation' stamp: 'dhn 9/6/2017 22:10:55'!
show: aCollection
	"Display the succession of faces in aCollection on the die, then hop the token"
	| limit linger t i x |
	
	limit _ 1600 + (500 atRandom).
	linger _ limit + 700. 	"to pause before vanishing"
	t _ 0.
	i _ 0.
	self when: #morphicStep evaluate: [ :delta |
		i _ i + 1.
		t _ t + delta.
		t < limit 	"limit on the total time of activity"
			ifTrue: [x _ self perform: (aCollection atWrap: i)]
			ifFalse: [
				model testMode ifTrue: [self perform: (self class faces at: (model hardRoll * 2))].
				t > linger ifTrue: [
					self stopStepping.
					model hopFor: x.
					self removeActionsForEvent: #morphicStep.
					owner removeMorph: self]]].
	self startSteppingStepTime: 85. 	"time of each step in the activity"
! !

!DieMorph methodsFor: 'operation' stamp: 'dhn 8/21/2017 10:49:21'!
show: aCollection event: aSymbol
	"Display the succession of faces in aCollection; answer the value of the final face"
	| limit linger t i |
	
	limit _ 1600 + (500 atRandom).
	linger _ limit + 700. 	"to pause before vanishing"
	t _ 0.
	i _ 0.
	self when: #morphicStep evaluate: [ :delta |
		i _ i + 1.
		t _ t + delta.
		t < limit 	"limit on the total time of activity"
			ifTrue: [value _ self perform: (aCollection atWrap: i)]
			ifFalse: [
				t > linger ifTrue: [
					self stopStepping.
					self removeActionsForEvent: #morphicStep.
					owner removeMorph: self.
					model remainder: value.
					]]].
	self startSteppingStepTime: 85. 	"time of each step in the activity"
! !

!DieMorph methodsFor: 'operation' stamp: 'dhn 8/21/2017 10:51:07'!
showEffect: aCollection
	"Display the succession of faces in aCollection; answer the value of the final face"
	| limit linger t i |
	
	limit _ 1600 + (500 atRandom).
	linger _ limit + 700. 	"to pause before vanishing"
	t _ 0.
	i _ 0.
	self when: #morphicStep evaluate: [ :delta |
		i _ i + 1.
		t _ t + delta.
		t < limit 	"limit on the total time of activity"
			ifTrue: [value _ self perform: (aCollection atWrap: i)]
			ifFalse: [
				t > linger ifTrue: [
					self stopStepping.
					self removeActionsForEvent: #morphicStep.
					owner removeMorph: self.
					model franchiseEffect: value]]].
	self startSteppingStepTime: 85. 	"time of each step in the activity"
! !

!DieMorph methodsFor: 'operation' stamp: 'dhn 9/20/2017 18:20:21'!
showEffect: aCollection then: aSymbol
	"Display the succession of faces in aCollection; answer the value of the final face"
	| limit linger t i |
	
	limit _ 1600 + (500 atRandom).
	linger _ limit + 700. 	"to pause before vanishing"
	t _ 0.
	i _ 0.
	self when: #morphicStep evaluate: [ :delta |
		i _ i + 1.
		t _ t + delta.
		t < limit 	"limit on the total time of activity"
			ifTrue: [value _ self perform: (aCollection atWrap: i)]
			ifFalse: [
				t > linger ifTrue: [
					self stopStepping.
					self removeActionsForEvent: #morphicStep.
					owner removeMorph: self.
					model franchiseEffect: value.
					model perform: aSymbol]]].
	self startSteppingStepTime: 85. 	"time of each step in the activity"
! !


!DieMorph methodsFor: 'access' stamp: 'dhn 8/21/2017 10:49:57'!
value
	"Answer the value"
	
	^ value! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'DieMorph class' category: #'Game-Graphics'!
DieMorph class
	instanceVariableNames: ''!

!DieMorph class methodsFor: 'reference' stamp: 'dhn 8/21/2017 08:47:44'!
faces
	"Answer the possible faces, in both orientations"
	
	^ #(
		#face1 	#face1
		#face2 	#face2b
		#face3 	#face3b
		#face4 	#face4
		#face5 	#face5
		#face6 	#face6b
		)! !


!DieMorph class methodsFor: 'instance creation' stamp: 'dhn 8/21/2017 11:16:12'!
new: aSize
	"Answer an instance of this class with aSize@aSize extent"
	
	^ self new morphExtent: aSize@aSize! !


!classDefinition: #ArrowMorph category: #'Game-Graphics'!
BorderedRectMorph subclass: #ArrowMorph
	instanceVariableNames: 'form'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!ArrowMorph commentStamp: '<historical>' prior: 0!
Enable a form to be opened on a world.!


!ArrowMorph methodsFor: 'drawing' stamp: 'dhn 11/12/2016 19:13:00'!
drawOn: aCanvas

	aCanvas image: form at: 0@0! !


!ArrowMorph methodsFor: 'accessing' stamp: 'dhn 11/12/2016 19:23:27'!
form
	"Answer the value of form"

	^ form! !

!ArrowMorph methodsFor: 'accessing' stamp: 'dhn 11/12/2016 19:23:27'!
form: anObject
	"Set the value of form"

	form _ anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'ArrowMorph class' category: #'Game-Graphics'!
ArrowMorph class
	instanceVariableNames: ''!

!ArrowMorph class methodsFor: 'instance creation' stamp: 'dhn 1/20/2017 11:56:31'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !

!ArrowMorph class methodsFor: 'instance creation' stamp: 'dhn 5/14/2017 12:52:40'!
leftOn: aWorld
	"Open a right-pointing arrow in aWorld"
	
	^ self new
		form: (BitBltCanvas arrowOfDirection: #left size: 40) as8BitColorForm! !

!ArrowMorph class methodsFor: 'instance creation' stamp: 'dhn 5/14/2017 12:46:15'!
rightOn: aWorld
	"Open a right-pointing arrow in aWorld"

	^ self new
		form: (BitBltCanvas arrowOfDirection: #right size: 40) as8BitColorForm! !


!classDefinition: #CellView category: #'Game-Graphics'!
LayoutMorph subclass: #CellView
	instanceVariableNames: 'textPane marksPane'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!CellView commentStamp: 'dhn 8/14/2017 11:23:23' prior: 0!
Define the layout for a cell on the game board. A cell is the lower portion of a space on the board.!


!CellView methodsFor: 'accessing' stamp: 'dhn 1/14/2017 13:17:39'!
marksPane
	"Answer the value of marksPane"

	^ marksPane! !

!CellView methodsFor: 'accessing' stamp: 'dhn 1/14/2017 13:17:39'!
marksPane: anObject
	"Set the value of marksPane"

	marksPane _ anObject! !

!CellView methodsFor: 'accessing' stamp: 'dhn 1/14/2017 13:17:39'!
textPane
	"Answer the value of textPane"

	^ textPane! !

!CellView methodsFor: 'accessing' stamp: 'dhn 1/14/2017 13:17:39'!
textPane: anObject
	"Set the value of textPane"

	textPane _ anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CellView class' category: #'Game-Graphics'!
CellView class
	instanceVariableNames: ''!

!CellView class methodsFor: 'instance creation' stamp: 'dhn 1/20/2017 11:57:03'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !


!classDefinition: #PlotGraphMorph category: #'Game-Graphics'!
FunctionGraphMorph subclass: #PlotGraphMorph
	instanceVariableNames: 'data points yScaleFactor startTime deltaT yFactor xFactor resumed players sorted'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!PlotGraphMorph commentStamp: 'dhn 9/28/2016 20:24:06' prior: 0!
Plot players' progress.!


!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 1/18/2017 18:21:02'!
asNormalizedPoints: aCollection
	"Answer an array of points which are mapped on [0, T] in both dimensions, where T is a multiple of 10"
	| yArray xArray result |

	yArray _ yFactor * (self normalize: aCollection asOrderedCollection with: yScaleFactor).
	xArray _ xFactor * (self normalize: (0 to: aCollection size) asArray).
	
	result _ OrderedCollection new.
	1 to: yArray size	do: [ :i | result add: (xArray at: i) @ (yArray at: i) ].
	
	^ result.! !

!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 3/18/2017 20:16:23'!
drawOn: aCanvas
	"Draw all the lines, including axes, on the graph"
	| fully lineColor |
	
	fully _ 10 raisedTo: yMax log asInteger.

	aCanvas line: (self toMorphic:0@yMin) to: (self toMorphic: 0 @ yMax) width: 2 color: Color lightGray.
	aCanvas line: (self toMorphic: xMin@0) to: (self toMorphic: xMax@0) width: 2 color: Color lightGray.
	aCanvas line: (self toMorphic: 0@fully) to: (self toMorphic: xMax@fully) width: 2 color: Color lightRed.
	
	owner owner rank: sorted.
	
	sorted do: [:ea |
		lineColor _ ea color.
		ea history size > 1 ifTrue: [
			points _ self asNormalizedPoints: ea history.

			1 to: points size - 1 do: [:n | | p |
				aCanvas 	"continue the graph"
					line: (self toMorphic: (p _ points at: n)) 	"from point"
					to: (self toMorphic: (points at: n + 1)) 	"to point"
					width: 2 color: lineColor]]].! !

!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 5/23/2015 11:50'!
normalize: aCollection
	"Answer aCollection divided by its maximum"
	| max |
	max _ aCollection inject: 0 into: [:a :c | (a > c)
		ifTrue: [a]
		ifFalse: [c]].
	^ OrderedCollection new
		addAll: aCollection / (max * 1.0)! !

!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 5/26/2015 20:09'!
normalize: aCollection with: aFactor
	"Answer aCollection divided by its maximum and scaled by maximum/aFactor"
	| max |
	max _ aCollection inject: 0 into: [:a :c | (a > c)
		ifTrue: [a]
		ifFalse: [c]].
	^ OrderedCollection new
		addAll: (aCollection / (max * 1.0)) * (max / aFactor)! !

!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 9/29/2016 10:58:56'!
plotData
	"Sort then plot for each player"

	sorted _ SortedCollection new
		sortBlock: [:a :c | a history last > c history last].
	sorted addAll: players.
	self redrawNeeded

! !

!PlotGraphMorph methodsFor: 'drawing' stamp: 'dhn 5/12/2016 10:39'!
startTime
	"Answer the value of startTime"
	
	startTime ifNil: [startTime _ Time localMillisecondClock].
	^ startTime! !


!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/6/2015 09:33'!
color: aColor

	super color: aColor.
! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/23/2015 16:09'!
data: aCollection

	data _ aCollection
! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 9/30/2016 20:57:20'!
details
	"Update the plot"

	self 
		players: owner owner model players;
		plotData! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 9/28/2016 20:37:04'!
players
	"Answer the value of players"

	^ players! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 9/28/2016 20:37:25'!
players: anObject
	"Set the value of players"

	players _ anObject! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/11/2016 02:06'!
points
	"Answer the value of points"

	^ points! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/11/2016 02:06'!
points: anObject
	"Set the value of points"

	points _ anObject! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 6/11/2016 12:13'!
resumed: anObject
	"Set the value of resumed"

	resumed _ anObject! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/11/2016 02:06'!
startTime: anObject
	"Set the value of startTime"

	startTime _ anObject! !

!PlotGraphMorph methodsFor: 'accessing' stamp: 'dhn 5/26/2015 12:25'!
yScaleFactor: aNumber

	yScaleFactor _ aNumber
! !


!PlotGraphMorph methodsFor: 'initialization' stamp: 'dhn 5/12/2016 09:50'!
initialize

	super initialize! !

!PlotGraphMorph methodsFor: 'initialization' stamp: 'dhn 5/11/2016 21:17'!
setXYFactors
	"Set the values of xFactor and yFactor"

	xFactor _ 10 raisedTo: xMax log asInteger.
	yFactor _ 10 raisedTo: yMax log asInteger
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'PlotGraphMorph class' category: #'Game-Graphics'!
PlotGraphMorph class
	instanceVariableNames: ''!

!PlotGraphMorph class methodsFor: 'instance creation' stamp: 'dhn 1/20/2017 11:58:36'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !


!PlotGraphMorph class methodsFor: 'display' stamp: 'dhn 5/11/2016 16:01'!
ticLength
	"Answer the length of tic marks"
	
	^ 0.2! !


!classDefinition: #GamePopUp category: #'Game-Graphics'!
PopUpMenu subclass: #GamePopUp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Graphics'!
!GamePopUp commentStamp: '<historical>' prior: 0!
Modal dialog, providing syntax identical to a Squeak class:

UserDialogBoxMorph inform: 'An informative string.' title: 'Title'.
!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'GamePopUp class' category: #'Game-Graphics'!
GamePopUp class
	instanceVariableNames: ''!

!GamePopUp class methodsFor: 'dialogs' stamp: 'dhn 8/24/2016 10:10:56'!
inform: aMessage title: aTitle
	"Display a modal dialog with aTitle containing aMessage"
	"Can be dismissed by clicking anywhere below the title"
	
	self 
		confirm: aTitle
		trueChoice: aMessage
		falseChoice: 'OK'! !
