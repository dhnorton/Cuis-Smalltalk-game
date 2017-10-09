!classDefinition: #Game category: #'Game-Model'!
ActiveModel subclass: #Game
	instanceVariableNames: 'world cells spaces goal response players currentPlayer token tokenPos playerIndex buttons outs cellCount hardRoll won spaceFreq chantBeat'
	classVariableNames: 'TestGoal TestMode'
	poolDictionaries: ''
	category: 'Game-Model'!
!Game commentStamp: 'dhn 7/10/2016 12:01' prior: 0!
Abstract class for a board game model.!


!Game methodsFor: 'operating' stamp: 'dhn 8/23/2016 21:33:37'!
addMarkerIDInMarks
	"(self marks at: self currentPlayer position) at: self playerIndex
		put: self currentPlayer identity" ! !

!Game methodsFor: 'operating' stamp: 'dhn 1/14/2017 14:43:58'!
cellsAt: anIndex 
	"Show the board starting with spaces at: anIndex."
	| str |
	
	1 to: cellCount do: [:k | 
		(cells at: k) marksPane removeAllMorphs].
	
	1 to: cellCount do: [:m | | sp |
		sp _ spaces atWrap: anIndex + m - 1.
		str _ String new writeStream.
		str nextPutAll: sp label; newLine.
		self testMode
			ifTrue: [str nextPutAll: sp routine asString; newLine].
		(cells at: m) textPane
			model actualContents: str contents.
		sp marks ifNotEmpty: [
			(cells at: m) marksPane
				addAllMorphs: sp marks]]
! !

!Game methodsFor: 'operating' stamp: 'dhn 9/15/2017 18:36:32'!
declareBroke: aString
	"Inform that the player named aString is out of cash"
	
	GamePopUp 
		inform: aString , ' is out of cash and must auction 
assets until cash is no longer negative.'
		title: 'Out of Cash'! !

!Game methodsFor: 'operating' stamp: 'dhn 9/15/2017 18:32:11'!
declareOver: aString
	"Inform that the player named aString is over the debt limit"
	
	GamePopUp 
		inform: (String streamContents: [:str |
			str
				nextPutAll: currentPlayer identity;
				nextPutAll: ' must use cash to bring debt to $';
				nextPutAll: currentPlayer playerDebtLimit value negated printStringWithCommas;
				nextPutAll: ' or less.']) 
		title: 'Debt Too High'! !

!Game methodsFor: 'operating' stamp: 'dhn 9/15/2017 18:42:37'!
declareWinner
	"Inform that there is a winner"

	GamePopUp 
		inform: (String streamContents: [:str |
			str
				nextPutAll: self currentPlayer identity;
				nextPutAll: ' has amassed net assets of more than $';
				nextPutAll: self goal printStringWithCommas; nextLine;
				nextPutAll: ' and is the winner of the game.']) 
		title: 'THE WINNAH!!!!!!!!'.
	token delete.
	self won: true! !

!Game methodsFor: 'operating' stamp: 'dhn 8/4/2016 18:47:37'!
disableAll: aCollection
	"Disable each button named in aCollection"
	| btn |
	
	aCollection do: [:x |
		btn _ self buttons submorphs detect: [:b | b label = x] ifNone: [nil].
		btn ifNotNil: [btn disableButton]]! !

!Game methodsFor: 'operating' stamp: 'dhn 1/11/2017 21:35:01'!
doSpace
	"Perform the method associated with the space where the player is"

	^ self perform: ((spaces at: self currentPlayer position) routine)! !

!Game methodsFor: 'operating' stamp: 'dhn 10/9/2011 11:04'!
drawCard: aDeck discard: aDiscard
	|card|
	aDeck isEmpty ifFalse: [.
		card := aDeck removeFirst.
		aDiscard addFirst: card.
		^card
		]
	ifTrue: [
		aDeck addAll: (self scramble: aDiscard).
		aDiscard removeAll: aDeck.
		^self drawCard: aDeck discard: aDiscard.
		].
! !

!Game methodsFor: 'operating' stamp: 'dhn 8/4/2016 18:47:09'!
enableAll: aCollection
	"Enable each button named in aCollection"
	| btn |
	
	aCollection do: [:x |
		btn _ self buttons submorphs detect: [:b | b label = x] ifNone: [nil].
		btn ifNotNil: [btn enableButton]]! !

!Game methodsFor: 'operating' stamp: 'dhn 10/16/2016 14:38:10'!
goal
	"Answer the goal of the game"
	
	goal ifNil: [goal _ self class defaultGoal].
	^ self testMode
		ifTrue: [TestGoal]
		ifFalse: [goal]! !

!Game methodsFor: 'operating' stamp: 'dhn 9/22/2016 11:26:34'!
hardRoll
	"Answer the value of hardRoll"
	
	^ hardRoll! !

!Game methodsFor: 'operating' stamp: 'dhn 9/22/2016 11:27:21'!
hardRoll: anObject
	"Set the value of hardRoll"
	
	hardRoll _ anObject! !

!Game methodsFor: 'operating' stamp: 'dhn 9/6/2017 22:10:04'!
hopFor: anObject
	"Hop token for anObject number of spaces"
	| roll |
	
	token who oldPosition: token who position.
	roll _ self testMode ifTrue: [self hardRoll] ifFalse: [anObject].
	token jump: roll.
	currentPlayer 
		roll: roll;
		position: (currentPlayer forwardTo: (roll + currentPlayer position) 
			around: spaces size).
	currentPlayer rollStats: roll! !

!Game methodsFor: 'operating' stamp: 'dhn 8/21/2017 13:20:32'!
move
	"Roll the die"
	| bone |
	
	self disableAll: {'Move'}.
	bone _ DieMorph new openInWorld: world.
	bone model: self.
	currentPlayer die: bone.
	bone adjustTo: token.
	bone show: bone class faces shuffled! !

!Game methodsFor: 'operating' stamp: 'dhn 8/9/2017 15:48:42'!
nextPlayer
	"Begin the next player's turn"
	| x |
	
	currentPlayer _ (players atWrap: (playerIndex _ playerIndex + 1)).
	self 
		triggerEvent: #deleteOpenWindows; 	"close any open views of the current player"
		triggerEvent: #itemChange; 	"update board view"
		triggerEvent: #titleChange with: currentPlayer;
		positionBoardTo: currentPlayer position; 	"position board,"
		removeMarkers.
	token openInWorld: world.
	token morphPosition: tokenPos.
	token id contents: currentPlayer identity.
	token doubled contents: currentPlayer doubledString.
	token color: currentPlayer color.
	token who: currentPlayer.
	token setBalloonText: 'token for ', currentPlayer identity.
	self testMode ifTrue: [
	x _ (FillInTheBlankMorph request: 'How many spaces' initialAnswer: '6' onCancel: ['0']) asNumber.
	self hardRoll: ((1 to: 6) asArray atWrap: x)]! !

!Game methodsFor: 'operating' stamp: 'dhn 1/11/2017 15:52:14'!
parseSeasonsAt: anIndex 
	"Answer associations of point->season, where point defines the range of cells for the season"
	| col max start sea |
	
	col := OrderedCollection new.
	max _ spaces size.
	sea _ self seasonAt: anIndex.
	start _ 0.
	0 to: cellCount - 1 do: [:n | 	| next |
		next _ self seasonAt: (self wrapIndex: anIndex + n around: max).
		sea desc = next desc
			ifFalse: [
				col addLast: start + 1 @ n -> sea.
				start _ n.
				sea _ next]].
	col addLast: start + 1 @ cellCount -> sea.
	^ col! !

!Game methodsFor: 'operating' stamp: 'dhn 10/2/2016 16:48:07'!
positionBoardTo: anIndex 
	"Change the location on the board"
	| assoc |
	
	self cellsAt: anIndex.
	assoc _ self parseSeasonsAt: anIndex.
	self triggerEvent: #showSeasons: with: assoc! !

!Game methodsFor: 'operating' stamp: 'dhn 8/9/2017 21:27:12'!
removeMarkers
	"Remove a player's marker from space and cell"
	
	(spaces atWrap: currentPlayer position) markRemFor: currentPlayer.
	cells first marksPane removeMorph: currentPlayer marker
! !

!Game methodsFor: 'operating' stamp: 'dhn 10/10/2013 22:10'!
won
	won ifNil: [won := false].
	^ won! !

!Game methodsFor: 'operating' stamp: 'dhn 10/10/2013 22:11'!
won: aBool
	won := aBool.! !

!Game methodsFor: 'operating' stamp: 'dhn 11/1/2013 18:52'!
wrapIndex: anIndex around: aLimit 
	"Answer an index value in the interval [1, aLimit]."
	anIndex > aLimit
		ifTrue: ["Use recursion to limit gross excesses."
			^ self wrapIndex: anIndex - aLimit around: aLimit]
		ifFalse: [anIndex <= 0
				ifTrue: [^ aLimit].
			^ anIndex]! !


!Game methodsFor: 'accessing' stamp: 'dhn 9/16/2011 17:54'!
buttons
	"Answer the value of buttons"

	^ buttons! !

!Game methodsFor: 'accessing' stamp: 'dhn 9/16/2011 17:54'!
buttons: anObject
	"Set the value of buttons"

	buttons := anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 9/22/2016 21:02:27'!
cells
	"Answer the value of cells"

	^ cells! !

!Game methodsFor: 'accessing' stamp: 'dhn 9/22/2016 21:02:59'!
cells: anObject
	"Set the value of cells"

	cells _ anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/28/2016 14:54:47'!
chantBeat
	"Answer the value of chantBeat"

	chantBeat ifNil: [chantBeat _ 2000].
	^ chantBeat! !

!Game methodsFor: 'accessing' stamp: 'dhn 9/11/2011 17:00'!
currentPlayer
	"Answer the value of currentPlayer"

	^ currentPlayer! !

!Game methodsFor: 'accessing' stamp: 'dhn 7/29/2013 14:44'!
currentPlayer: anObject
	currentPlayer := anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/2/2016 17:01:38'!
oldGoal
	^ self class oldGoal asNumber! !

!Game methodsFor: 'accessing' stamp: 'dhn 11/4/2011 08:31'!
outs
	"Answer the players who are out of the game."

	^ outs ifNil: [OrderedCollection new].! !

!Game methodsFor: 'accessing' stamp: 'dhn 11/4/2011 08:29'!
outs: anObject
	"Set the value of outs"

	outs := anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/10/2011 18:14'!
playerIndex
	"Answer the value of playerIndex"

	playerIndex ifNil: [playerIndex := 0].
	^ playerIndex! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/10/2011 18:12'!
playerIndex: anObject
	"Set the value of playerIndex"

	playerIndex := anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 9/14/2011 22:55'!
players
	"Answer the value of players"

	^ players! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/27/2016 12:27:51'!
players: anObject
	"Set value of players to anObject"
	
	players _ anObject! !

!Game methodsFor: 'accessing' stamp: 'dhn 10/7/2014 12:23'!
spaceFreq
	"Answer the value of spaceFreq"

	^ spaceFreq! !

!Game methodsFor: 'accessing' stamp: 'dhn 3/18/2017 18:39:37'!
token
	"Answer the value of token"

	^ token! !

!Game methodsFor: 'accessing' stamp: 'dhn 3/18/2017 18:39:03'!
token: anObject
	"Set the value of token"

	token _ anObject! !


!Game methodsFor: 'initialize' stamp: 'dhn 8/31/2017 16:10:39'!
describeSpaces
	"Descriptions for the spaces on the board."

	self subclassResponsibility ! !

!Game methodsFor: 'initialize' stamp: 'dhn 8/2/2014 21:49'!
initialButtonState
	"Establish the button state at the start of the game"
	self subclassResponsibility! !

!Game methodsFor: 'initialize' stamp: 'dhn 8/31/2017 16:08:04'!
initialize

	players _ OrderedCollection new.
	cells _ OrderedCollection new.
	spaceFreq _ Histogram ofSize: self class describeSpaces size! !

!Game methodsFor: 'initialize' stamp: 'dhn 7/11/2013 14:53'!
markerSize
	"Answer the size for markers"
	^ 28! !

!Game methodsFor: 'initialize' stamp: 'dhn 10/2/2016 14:53:22'!
quitGame
	"Signal that we are quitting"

	self triggerEvent: #deleteOpenWindows.
	self triggerEvent: #quitGame! !

!Game methodsFor: 'initialize' stamp: 'dhn 9/17/2011 13:19'!
scramble: aCollection
	"Try to achieve a better mix."
	|temp|
	temp := aCollection shuffled.
	temp := temp shuffled.
	^temp shuffled.
! !

!Game methodsFor: 'initialize' stamp: 'dhn 10/28/2016 15:13:22'!
setBeat
	"Set the time between '...going', '...going' "
	| value x |
	
	value _ self chantBeat / 1000.0.
	x _ (FillInTheBlankMorph request: 'Auctioneer pause time (sec)' initialAnswer: value asString).
	x ~= '' ifTrue:  [chantBeat _ (x asNumber * 1000.0) asInteger]! !

!Game methodsFor: 'initialize' stamp: 'dhn 10/16/2016 12:07:28'!
setGoal
	"Set the goal of the game"
	| x |
	
	goal ifNil: [goal _ self class defaultGoal].
	x _ (FillInTheBlankMorph request: 'Net assets to win the game?' initialAnswer: goal asString).
	x ~= '' ifTrue:  [goal _ x asNumber]! !

!Game methodsFor: 'initialize' stamp: 'dhn 8/6/2017 21:32:46'!
world
	"Answer the value of world"

	^ world! !

!Game methodsFor: 'initialize' stamp: 'dhn 4/3/2017 19:38:36'!
world: anObject
	"Set the value of world"

	world _ anObject! !


!classDefinition: #Asset category: #'Game-Model'!
Object subclass: #Asset
	instanceVariableNames: 'description quantity cost gross factor quality count missed owner singleOwner'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!Asset commentStamp: 'dhn 7/10/2016 11:58' prior: 0!
Abstract class for an asset model.!


!Asset methodsFor: 'accessing' stamp: 'dhn 9/25/2011 10:37'!
cost
	"Answer the value of cost"

	cost ifNil: [cost := 0].
	^ cost ! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/18/2011 10:43'!
cost: anObject
	"Set the value of cost"

	cost := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 10/13/2011 12:28'!
count
	"Answer the number of harvests"

	count isNil ifTrue: [count := 0].
	^ count! !

!Asset methodsFor: 'accessing' stamp: 'dhn 10/13/2011 12:28'!
count: anObject
	"Set the value of count"

	count := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/23/2014 20:19'!
description: anObject
	"Set the value of description"

	description := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 11:18'!
factor
	"Answer the value of factor"

	factor isNil ifTrue: [factor := 1].
	^ factor! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 09:24'!
factor: anObject
	"Set the value of factor"

	factor := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/25/2011 10:36'!
gross
	"Answer the value of gross"

	gross ifNil: [gross := 0].
	^ gross! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/18/2011 10:43'!
gross: anObject
	"Set the value of gross"

	gross := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 14:35'!
missed
	"Answer the count of missed opportunities for this asset"

	missed ifNil: [missed := 0].
	^ missed! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 14:33'!
missed: anObject
	"Set the value of missed"

	missed := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 18:03'!
owner
	"Answer the value of owner"

	^ owner! !

!Asset methodsFor: 'accessing' stamp: 'dhn 12/6/2011 18:03'!
owner: anObject
	"Set the value of owner"

	owner := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 10/13/2011 12:27'!
quality
	"Answer the sum of each harvest quality."

	quality isNil ifTrue: [quality := 0].
	^ quality! !

!Asset methodsFor: 'accessing' stamp: 'dhn 10/13/2011 12:27'!
quality: anObject
	"Set the value of quality"

	quality := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/25/2011 10:36'!
quantity
	"Answer the value of quantity"

	quantity ifNil: [quantity := 0].
	^ quantity! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/19/2011 11:17'!
quantity: anObject
	"Set the value of quantity"

	quantity := anObject! !

!Asset methodsFor: 'accessing' stamp: 'dhn 9/8/2017 15:19:22'!
singleOwner
	"Answer true if the asset can have only one owner"

	singleOwner isNil ifTrue: [singleOwner _ false].
	^ singleOwner! !


!Asset methodsFor: 'as yet unclassified' stamp: 'dhn 1/18/2014 12:19'!
description
	^ description! !

!Asset methodsFor: 'as yet unclassified' stamp: 'dhn 8/27/2016 14:45:06'!
profit: aGross orLoss: aCost 
	| pnl msg |
	pnl := aGross - aCost.
	pnl >= 0
		ifTrue: [msg := ' profit']
		ifFalse: [msg := ' loss'.
			pnl := pnl negated].
	^ '$' , pnl asInteger printStringWithCommas , msg! !


!Asset methodsFor: 'initialize-release' stamp: 'dhn 9/25/2011 05:20'!
initialize
	super initialize.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Asset class' category: #'Game-Model'!
Asset class
	instanceVariableNames: ''!

!Asset class methodsFor: 'as yet unclassified' stamp: 'dhn 1/20/2014 08:18'!
optionCost
	^ self price * self auctionQuantity! !


!classDefinition: #BoardSpace category: #'Game-Model'!
Object subclass: #BoardSpace
	instanceVariableNames: 'label routine marks'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!BoardSpace commentStamp: 'dhn 1/11/2017 19:04:14' prior: 0!
A model for a space on a board game. Instance variables include:

label - describes the space
routine - a symbol for the method to run when landing on the space
marks - morphs indicating player's presence!


!BoardSpace methodsFor: 'initialization' stamp: 'dhn 1/13/2017 18:00:11'!
initialize

	marks _ OrderedCollection new! !


!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/11/2017 19:04:31'!
label
	"Answer the value of label"

	^ label! !

!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/11/2017 19:04:31'!
label: anObject
	"Set the value of label"

	label _ anObject! !

!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/13/2017 18:08:29'!
marks
	"Answer  the value of marks"
	
	^ marks! !

!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/11/2017 19:04:31'!
marks: anObject
	"Set the value of marks"

	marks _ anObject! !

!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/11/2017 19:04:31'!
routine
	"Answer the value of routine"

	^ routine! !

!BoardSpace methodsFor: 'accessing' stamp: 'dhn 1/11/2017 19:04:31'!
routine: anObject
	"Set the value of routine"

	routine _ anObject! !


!BoardSpace methodsFor: 'operating' stamp: 'dhn 1/13/2017 17:59:12'!
markAddFor: aPlayer
	"Set the marker for aPlayer in marks"
	
	marks add: aPlayer marker! !

!BoardSpace methodsFor: 'operating' stamp: 'dhn 1/13/2017 17:50:53'!
markRemFor: aPlayer
	"Remove the marker for aPlayer in marks"
	
	marks remove: aPlayer marker ifAbsent: []! !


!classDefinition: #Direction category: #'Game-Model'!
Object subclass: #Direction
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!Direction commentStamp: 'dhn 7/10/2016 12:00' prior: 0!
A model for finding the shortest distance around a game board.!


!Direction methodsFor: 'as yet unclassified' stamp: 'dhn 7/15/2016 21:20'!
testLong
	| ans |
	Transcript clear.
	1
		to: 12
		do: [:from | 1
				to: 12
				do: [:to | 
					ans := Direction
								longest: from
								to: to
								in: 12.
					Transcript newLine; show: from; tab; show: to; tab; show: ans; newLine]]! !

!Direction methodsFor: 'as yet unclassified' stamp: 'dhn 7/15/2016 21:20'!
testShort
	| ans |
	Transcript clear.
	1
		to: 12
		do: [:from | 1
				to: 12
				do: [:to | 
					ans := Direction
								shortest: from
								to: to
								in: 12.
					Transcript newLine; show: from; tab; show: to; tab; show: ans; newLine]]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Direction class' category: #'Game-Model'!
Direction class
	instanceVariableNames: ''!

!Direction class methodsFor: 'as yet unclassified' stamp: 'dhn 8/8/2013 09:53'!
longest: a to: b in: n 
	^ (Direction shortest: a to: b in: n) negated! !

!Direction class methodsFor: 'as yet unclassified' stamp: 'dhn 8/8/2013 09:48'!
shortest: a to: b in: n 
	^ (Float twoPi * (b + n - a / n)) sin sign! !


!classDefinition: #Gamer category: #'Game-Model'!
Object subclass: #Gamer
	instanceVariableNames: 'color identity cash debt inFlow outFlow interestPd paidInterest avoidedDebt assets history passedGo years mgr position oldPosition die marker roll totalRoll turns expenseCount'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!Gamer commentStamp: 'dhn 7/10/2016 12:02' prior: 0!
A model for a player in a board game.
!


!Gamer methodsFor: 'accessing' stamp: 'dhn 9/3/2013 21:29'!
assets
	^ assets! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 3/18/2017 12:48:35'!
color
	"Answer the value of color"

	^ color! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 3/18/2017 12:48:10'!
color: anObject
	"Set the value of color"

	color := anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 8/22/2016 13:34:58'!
die
	"Answer the value of die"

	^ die! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 8/22/2016 13:35:45'!
die: anObject
	"set the value of die"

	die _ anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 7/24/2016 12:46'!
identity
	"Answer the value of identity"
	
	identity ifNil: [identity _ ''].
	^ identity! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 7/25/2016 12:12'!
identity: anObject
	"Set the value of identity"

	identity := anObject asString withBlanksCondensed! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 6/27/2013 17:34'!
marker

	^ marker! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 6/27/2013 17:34'!
marker: anObject

	marker := anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:18'!
mgr
	"Answer the value of mgr"

	^ mgr! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:18'!
mgr: anObject
	"Set the value of mgr"

	mgr := anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 8/24/2016 21:27:17'!
oldPosition
	"Answer the value of oldPosition"

	^ oldPosition! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 8/24/2016 21:27:37'!
oldPosition: anObject
	"set the value of oldPosition"

	oldPosition _ anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:57'!
passedGo
	"Answer the value of passedGo"

	passedGo ifNil: [passedGo := false].
	^ passedGo! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:18'!
passedGo: anObject
	"Set the value of passedGo"

	passedGo := anObject! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:58'!
position
	"Answer the value of position"

	position ifNil: [position := 1].
	^ position! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 10/7/2014 12:24'!
position: anObject
	"Set the value of position; record frequency"

	position := anObject.
	self mgr spaceFreq incrementAt: anObject.! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 4/25/2012 20:18'!
roll
	"Answer the value of roll"

	^ roll! !

!Gamer methodsFor: 'accessing' stamp: 'dhn 9/27/2016 21:26:40'!
roll: anObject
	"Set the value of roll"

	roll _ anObject! !


!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:46'!
avoidedDebt
	"Answer the value of avoidedDebt"

	avoidedDebt ifNil: [avoidedDebt := 0].
	^ avoidedDebt! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
avoidedDebt: anObject
	"Set the value of avoidedDebt"

	avoidedDebt := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
cash
	"Answer the value of cash"

	^ cash! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
cash: anObject
	"Set the value of cash"

	cash := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
debt
	"Answer the value of debt"

	^ debt! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
debt: anObject
	"Set the value of debt"

	debt := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:49'!
expenseCount
	"Answer the value of expenseCount"

	expenseCount ifNil: [expenseCount := 0].
	^ expenseCount! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
expenseCount: anObject
	"Set the value of expenseCount"

	expenseCount := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
history
	"Answer the value of history"

	^ history! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
history: anObject
	"Set the value of history"

	history := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:51'!
inFlow
	"Answer the value of inFlow"
	inFlow ifNil: [inFlow := 0].
	^ inFlow! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
inFlow: anObject
	"Set the value of inFlow"

	inFlow := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:52'!
interestPd
	"Answer the value of interestPd"
	interestPd ifNil: [interestPd := 0].
	^ interestPd! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
interestPd: anObject
	"Set the value of interestPd"

	interestPd := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 9/30/2016 22:18:02'!
netAssets
	"Answer the value of the receiver's net assets"
	| sum |
	
	sum _ cash + debt.
	assets do: [:a | sum _ sum + a assetValue].
	^ sum! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:54'!
outFlow
	"Answer the value of outFlow"
	outFlow ifNil: [outFlow := 0].
	^ outFlow! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
outFlow: anObject
	"Set the value of outFlow"

	outFlow := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:55'!
paidInterest
	"Answer the value of paidInterest"

	paidInterest ifNil: [paidInterest := 0].
	^ paidInterest! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
paidInterest: anObject
	"Set the value of paidInterest"

	paidInterest := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 8/27/2016 17:42:17'!
rollStats: aRoll
	"Collect statistics concerning the value of the die"
	
	self totalRoll: aRoll + self totalRoll. 
	self turns: 1 + self turns. 
	self mgr triggerEvent: #itemChange! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 9/14/2017 18:43:02'!
tally: anAmount
	"Answer anAmount after accounting for it"
	
	self cash: anAmount + self cash.
	anAmount > 0 
		ifTrue: [self inFlow: anAmount + self inFlow]
		ifFalse: [self outFlow: anAmount + self outFlow].
	0 > self cash 
		ifTrue: [
		self mgr updatePlayer.
		self tally: self emergencyLoan].
	^ anAmount
! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 21:00'!
totalRoll
	"Answer the value of totalRoll"


	totalRoll ifNil: [totalRoll := 0].
	^ totalRoll! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
totalRoll: anObject
	"Set the value of totalRoll"

	totalRoll := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 21:01'!
turns
	"Answer the value of turns"

	turns ifNil: [turns := 0].
	^ turns! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
turns: anObject
	"Set the value of turns"

	turns := anObject! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 21:01'!
years
	"Answer the value of years"

	years ifNil: [years := 0].
	^ years! !

!Gamer methodsFor: 'statistics' stamp: 'dhn 4/25/2012 20:18'!
years: anObject
	"Set the value of years"

	years := anObject! !


!Gamer methodsFor: 'movement' stamp: 'dhn 4/26/2012 17:43'!
forwardTo: anIndex around: aLimit
	"Answer an index value which starts back at 1 when a limit is reached."
	anIndex > aLimit 
		ifFalse: [^anIndex]
		ifTrue:[ "Use recursion to limit gross excesses."
			self passedGo: true.
			self years: 1 + self years.
			^self forwardTo: anIndex - aLimit around: aLimit
			].! !


!Gamer methodsFor: 'operating' stamp: 'dhn 9/15/2017 18:55:12'!
outOfAssets
	"Answer whether the receiver is out of assets"
	
	^ assets allSatisfy: [:a | a quantity <= 0]! !


!classDefinition: #Histogram category: #'Game-Model'!
Object subclass: #Histogram
	instanceVariableNames: 'distribution'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!Histogram commentStamp: 'dhn 10/7/2014 17:28' prior: 0!
A Histogram shows the frequency distribution of how often some value occurs.
!


!Histogram methodsFor: 'accessing' stamp: 'dhn 10/7/2014 17:10'!
distribution

	^ distribution! !

!Histogram methodsFor: 'accessing' stamp: 'dhn 10/7/2014 17:11'!
distribution: anObject

	distribution := anObject! !

!Histogram methodsFor: 'accessing' stamp: 'dhn 11/12/2016 22:08:56'!
incrementAt: anIndex
	"Add 1 to the amount in the distribution at anIndex"
	| x |
	
	x _ distribution atWrap: anIndex.
	distribution atWrap: anIndex put: x + 1! !

!Histogram methodsFor: 'accessing' stamp: 'dhn 10/7/2014 17:15'!
maximum
	"Answer the maximum of the distribution"
	^ self distribution inject: 0 into: [:a :c | (a > c)	
		ifTrue: [a]
		ifFalse: [c]].! !

!Histogram methodsFor: 'accessing' stamp: 'dhn 10/7/2014 17:17'!
size
	^ self distribution size! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Histogram class' category: #'Game-Model'!
Histogram class
	instanceVariableNames: ''!

!Histogram class methodsFor: 'instance creation' stamp: 'dhn 10/7/2014 17:11'!
ofSize: size
	| arr |
	arr := Array new: size.
	1 to: size do: [:i | arr at: i put: 0].
	^ self new distribution: arr! !


!classDefinition: #Season category: #'Game-Model'!
Object subclass: #Season
	instanceVariableNames: 'desc color textColor range assetName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Game-Model'!
!Season commentStamp: 'dhn 7/10/2016 12:02' prior: 0!
A Season is the collection of attributes associated with, for example:
	a season (Farming Game, Construction Game)
	a property set (Monopoly)
!


!Season methodsFor: 'accessing' stamp: 'dhn 1/22/2014 13:41'!
assetName

	^ assetName! !

!Season methodsFor: 'accessing' stamp: 'dhn 1/22/2014 13:41'!
assetName: anObject

	assetName := anObject! !

!Season methodsFor: 'accessing' stamp: 'dhn 2/13/2012 11:42'!
color
	"Answer the value of color"

	^ color! !

!Season methodsFor: 'accessing' stamp: 'dhn 2/13/2012 11:42'!
color: anObject
	"Set the value of color"

	color := anObject! !

!Season methodsFor: 'accessing' stamp: 'dhn 2/13/2012 11:45'!
desc
	"Answer the value of desc"

	^ desc! !

!Season methodsFor: 'accessing' stamp: 'dhn 2/13/2012 11:45'!
desc: anObject
	"Set the value of desc"

	desc := anObject! !

!Season methodsFor: 'accessing' stamp: 'dhn 2/13/2012 11:46'!
range
	"Answer the value of range"

	^ range! !

!Season methodsFor: 'accessing' stamp: 'dhn 4/14/2012 15:08'!
range: aPoint
	"Set the value of range as from@to"

	range := aPoint! !

!Season methodsFor: 'accessing' stamp: 'dhn 4/14/2012 15:07'!
textColor
	"Answer whether the color of the text is white (true) or black"

	textColor ifNil: [textColor := false].
	^ textColor! !

!Season methodsFor: 'accessing' stamp: 'dhn 4/14/2012 15:06'!
textColor: aBool
	"Set the value of textColor"

	textColor := aBool! !


!Season methodsFor: 'initialize-release' stamp: 'dhn 2/24/2012 21:51'!
initialize
	super initialize! !
