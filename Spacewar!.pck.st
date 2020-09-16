'From Cuis 5.0 [latest update: #4249] on 16 September 2020 at 4:42:25 pm'!
'Description '!
!provides: 'Spacewar!!' 1 35!
SystemOrganization addCategory: #'Spacewar!!'!


!classDefinition: #SpaceShip category: #'Spacewar!!'!
RectangleLikeMorph subclass: #SpaceShip
	instanceVariableNames: 'name position heading velocity fuel torpedoes mass acceleration'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'SpaceShip class' category: #'Spacewar!!'!
SpaceShip class
	instanceVariableNames: ''!

!classDefinition: #SpaceWar category: #'Spacewar!!'!
RectangleLikeMorph subclass: #SpaceWar
	instanceVariableNames: 'ships torpedoes centralStar'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'SpaceWar class' category: #'Spacewar!!'!
SpaceWar class
	instanceVariableNames: ''!

!classDefinition: #CentralStar category: #'Spacewar!!'!
Morph subclass: #CentralStar
	instanceVariableNames: 'mass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'CentralStar class' category: #'Spacewar!!'!
CentralStar class
	instanceVariableNames: ''!

!classDefinition: #Torpedo category: #'Spacewar!!'!
Morph subclass: #Torpedo
	instanceVariableNames: 'position velocity lifeSpan'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Spacewar!!'!
!classDefinition: 'Torpedo class' category: #'Spacewar!!'!
Torpedo class
	instanceVariableNames: ''!


!SpaceWar commentStamp: 'hlsf 9/16/2020 15:06:56' prior: 0!
I am the gameplay view. My submorphs are the elements of the game.

| game | 
game _ SpaceWar new.
game addMorph: SpaceShip new.
game openInWorld

Control with the left, up, right arrows!

!CentralStar commentStamp: '<historical>' prior: 0!
I am the central start of the game generating a gravity field.!

!SpaceShip methodsFor: 'initialization' stamp: 'hlsf 9/10/2020 19:16:16'!
initialize
	super initialize.
	heading _ Float halfPi.
	velocity _ 0 @ 0.
	position _ 100 @ 100.
	acceleration _ 0.
	mass _ 1.! !

!SpaceShip methodsFor: 'accessing' stamp: 'hlsf 9/16/2020 15:05:55'!
acceleration
"The acceleration boost when the engine ship are on"
	^ 2! !

!SpaceShip methodsFor: 'accessing' stamp: 'hlsf 9/16/2020 15:04:45'!
direction
"I am an unit vector representing the noze direction of the ship"
	 ^ heading cos @ heading sin
	! !

!SpaceShip methodsFor: 'accessing' stamp: 'hlsf 9/16/2020 15:05:10'!
normal
"A vector normal to the direction heading of the ship"
	| direction |
	direction _ self direction.
	 ^ direction y negated @ direction x
	! !

!SpaceShip methodsFor: 'drawing' stamp: 'hlsf 9/10/2020 19:42:55'!
drawOn: canvas
	| m u n a b c |
	m _ self transformation.
	
	u _ self direction * 30.
	n _ self normal * 10.
	a _ m transform: position + n.
	b _ m transform: position - n.
	c _ m transform: position + u.
	canvas line: a to: b width: 2 color: Color white.
	canvas line: c to: b width: 2 color: Color white.
	canvas line: a to: c width: 2 color: Color white.
	
	"Draw gas exhaust"
	acceleration ifNotZero: [
		canvas line: (m transform: position) to: (m transform: position - u) width: 1 color: Color gray]

	! !

!SpaceShip methodsFor: 'drawing' stamp: 'hlsf 9/16/2020 15:07:02'!
transformation
"The transofmration matrix to compute the ship coordinates in the gameplay view"
	^ AffineTransformation withPointScale: 1 @ -1 position: owner morphExtent / 2.0.
! !

!SpaceShip methodsFor: 'computing' stamp: 'hlsf 9/10/2020 19:31:57'!
gravity
"Compute the gravity acceleration vector"
	^ [-10 * mass * owner starMass / (position r raisedTo: 3) * position]
		on: Error do: [0 @ 0]! !

!SpaceShip methodsFor: 'computing' stamp: 'hlsf 9/16/2020 15:09:51'!
update
"Update the ship position and velocity "
	| ai ag newVelocity t |
	"acceleration vectors"
	t _ owner stepTime / 1000.0.
	ai _ acceleration * self direction.
	ag _ self gravity.
	newVelocity _ (ai + ag) * t + velocity.
	position _ (0.5 * (ai + ag) * t squared) + (velocity * t) + position.
	velocity _ newVelocity .
	
	"Are we out of screen?
	If so we move the ship to the other corner and slow it down by a factor of 2"
	(self isInOuterSpace and: [self isGoingOuterSpace])
		ifTrue: [velocity _ velocity / 2.
			position _ position negated]! !

!SpaceShip methodsFor: 'testing' stamp: 'hlsf 9/16/2020 15:07:18'!
isGoingOuterSpace
"is the ship going crazy in the outer space?"
	^ (position dotProduct: velocity) > 0 ! !

!SpaceShip methodsFor: 'testing' stamp: 'hlsf 9/16/2020 15:07:34'!
isInOuterSpace
"Is the ship located in the outer space? (outside of the game playarea)"
	^ (((0@0 extent: owner morphExtent) expandBy: 20) containsPoint: (self transformation transform: position)) not
		! !

!SpaceShip methodsFor: 'control' stamp: 'hlsf 9/16/2020 15:07:51'!
left
"Rotate the ship to its left"
	heading _ heading + 0.1.! !

!SpaceShip methodsFor: 'control' stamp: 'hlsf 9/16/2020 15:08:10'!
push
"Init an accelaration boost"
	acceleration _ 10! !

!SpaceShip methodsFor: 'control' stamp: 'hlsf 9/16/2020 15:08:01'!
right
"Rotate the ship to its right"
	heading _ heading - 0.1.! !

!SpaceShip methodsFor: 'control' stamp: 'hlsf 9/16/2020 15:08:18'!
unpush
"Stop the accelaration boost"
	acceleration _ 0! !

!SpaceWar methodsFor: 'accessing' stamp: 'hlsf 9/16/2020 15:51:33'!
ship
	^ submorphs first! !

!SpaceWar methodsFor: 'accessing' stamp: 'hlsf 9/16/2020 16:41:40'!
starMass
	^ centralStar mass! !

!SpaceWar methodsFor: 'initialization' stamp: 'hlsf 9/10/2020 15:21:22'!
defaultColor
	^ `Color black`! !

!SpaceWar methodsFor: 'initialization' stamp: 'hlsf 9/16/2020 16:41:16'!
initialize
	super initialize.
	extent _ 500 @ 500.
	self setProperty: #'handlesKeyboard' toValue: true.
	self setProperty: #'handlesMouseOver:' toValue: true.
	self startSteppingStepTime: self stepTime.
	self addMorph: (centralStar _ CentralStar new).! !

!SpaceWar methodsFor: 'events' stamp: 'hlsf 9/10/2020 19:17:33'!
keyStroke: event
	| key |
	key _ event keyCharacter.
	key = Character arrowUp ifTrue: [self ship push].
	key = Character arrowRight ifTrue: [self ship right].
	key = Character arrowLeft ifTrue: [self ship left]! !

!SpaceWar methodsFor: 'events' stamp: 'hlsf 9/11/2020 10:07:17'!
mouseEnter: evt
	evt hand newKeyboardFocus: self.	
	self startStepping! !

!SpaceWar methodsFor: 'events' stamp: 'hlsf 9/11/2020 10:07:22'!
mouseLeave: evt
	evt hand releaseKeyboardFocus: self.
	self stopStepping! !

!SpaceWar methodsFor: 'focus handling' stamp: 'hlsf 9/10/2020 16:04:35'!
keyboardFocusChange: gotFocus
	gotFocus 
		ifTrue: [color _ self defaultColor ]
		ifFalse: [color _ self defaultColor alpha: 0.5].
	self redrawNeeded.! !

!SpaceWar methodsFor: 'stepping' stamp: 'hlsf 9/10/2020 18:35:22'!
step
	self ship update.
	self ship unpush.
	self redrawNeeded ! !

!SpaceWar methodsFor: 'stepping' stamp: 'hlsf 9/11/2020 13:19:07'!
stepTime
"millisecond"
	^ 20! !

!SpaceWar methodsFor: 'stepping' stamp: 'hlsf 9/10/2020 18:03:59'!
wantsSteps
	^ true! !

!CentralStar methodsFor: 'accessing' stamp: 'hlsf 9/10/2020 13:59:50'!
mass
	^ mass! !

!CentralStar methodsFor: 'accessing' stamp: 'hlsf 9/10/2020 14:00:10'!
mass: anInteger
	mass _ anInteger ! !

!CentralStar methodsFor: 'drawing' stamp: 'hlsf 9/16/2020 16:05:41'!
drawOn: canvas
	canvas ellipseCenterX: owner morphExtent x // 2 
		y:  owner morphExtent y // 2 
		rx: 10 + (2 atRandom - 1)
		ry: 10 + (2 atRandom - 1)
		borderWidth: 2 
		borderColor: Color orange 
		fillColor: Color yellow ! !

!CentralStar methodsFor: 'initialization' stamp: 'hlsf 9/16/2020 16:06:06'!
initialize
	super initialize.
	mass _ 8000.! !