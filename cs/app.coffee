`
// shim layer with setTimeout fallback
window.requestAnimFrame = (function(){
 return  window.requestAnimationFrame       ||
 window.webkitRequestAnimationFrame ||
 window.mozRequestAnimationFrame    ||
 window.oRequestAnimationFrame      ||
 window.msRequestAnimationFrame     ||
 function( callback ){
   window.setTimeout(callback, 1000 / 60);
 }
})();
`


class Entity
  b2AABB = Box2D.Collision.b2AABB
  b2Vec2 = Box2D.Common.Math.b2Vec2
  {b2BodyDef, b2Body, b2FixtureDef, b2Fixture } = Box2D.Dynamics
  {b2MassData, b2PolygonShape, b2CircleShape} = Box2D.Collision.Shapes
  {b2WeldJointDef, b2PulleyJointDef} = Box2D.Dynamics.Joints

  scale: 20

  constructor: (@world, @width, @height, @pX, @pY, @type) ->
    bodyDef = new b2BodyDef
    bodyDef.type = @type
    bodyDef.position.Set(@pX / @scale, @pY / @scale)

    shape = new b2PolygonShape
    shape.SetAsBox(@width / @scale, @height / @scale)

    fixtureDef = new b2FixtureDef
    fixtureDef.density = 1.0
    fixtureDef.friction = 0.2
    #fixtureDef.restitution = 0.4
    fixtureDef.shape = shape

    @body = @world.CreateBody(bodyDef)
    @body.CreateFixture(fixtureDef)

  getBody: -> @body

class Rect extends Entity
  b2Vec2 = Box2D.Common.Math.b2Vec2

  push: ->
    @body.ApplyForce(new b2Vec2(8, 0), @body.GetWorldPoint(new b2Vec2(1, -1)))

class Circle extends Entity
  {b2BodyDef, b2Body, b2FixtureDef, b2Fixture } = Box2D.Dynamics
  {b2MassData, b2CircleShape} = Box2D.Collision.Shapes
  b2Vec2 = Box2D.Common.Math.b2Vec2

  constructor: (@world, @width, @height, @pX, @pY, @type) ->
    bodyDef = new b2BodyDef
    bodyDef.type = @type
    bodyDef.position.Set(@pX / @scale, @pY / @scale)

    shape = new b2CircleShape(@width / @scale)

    fixtureDef = new b2FixtureDef
    fixtureDef.density = 1.0
    fixtureDef.friction = 0.1
    fixtureDef.restitution = 0.2
    fixtureDef.shape = shape

    @body = @world.CreateBody(bodyDef)
    @body.CreateFixture(fixtureDef)

  push: ->
    @body.ApplyImpulse(new b2Vec2(100, 140), @body.GetWorldCenter())



class Utilities
  toRadians: (degrees) ->
    degrees * (Math.PI / 180)

class World
  b2Vec2 = Box2D.Common.Math.b2Vec2
  {b2World, b2DebugDraw, b2Body} = Box2D.Dynamics

  constructor: (@ctx, @maxWidth, @maxHeight) ->
    @inputHandler = new InputHandler(@world)
    @createWorld()
    @enableDebugDraw()
    @mainLoop()

  createWorld: ->
    @world = new b2World(new b2Vec2(0, 10),true)

    w = 480
    h = 320
    leftWall     = new Entity(@world, 2, h, 2, h, b2Body.b2_staticBody)
    rightWall    = new Entity(@world, 2, h, w * 2 - 2, h, b2Body.b2_staticBody)
    topWall      = new Entity(@world, w - 4, 2, w, 2, b2Body.b2_staticBody)
    bottomWall   = new Entity(@world, w - 4, 2, w, h * 2 - 2, b2Body.b2_staticBody)

    platform   = new Rect(@world, w , 2, w - 60  , h / 2 , b2Body.b2_staticBody)

    bX = 50
    bSpacing = 20

    @firstBrick = new Rect(@world, 4, 12, bX - bSpacing, h / 2 , b2Body.b2_dynamicBody)

    #row 1
    for i in [1..41]
      new Rect(@world, 4, 12, bX, h / 2 - 1 , b2Body.b2_dynamicBody)
      bX += bSpacing

    new Circle(@world, 12, 12, bX, h / 2  , b2Body.b2_dynamicBody)

    #row 2
    platform   = new Rect(@world, w , 2, w + 80  , h / 2 + 100 , b2Body.b2_staticBody)
    bX = 100
    for i in [1..44]
      new Rect(@world, 4, 12, bX, h / 2 + 99 , b2Body.b2_dynamicBody)
      bX += bSpacing


    #row 3
    bX = 50
    platform   = new Rect(@world, w , 2, w - 60  , h / 2 + 200 , b2Body.b2_staticBody)
    for i in [1..41]
      new Rect(@world, 4, 12, bX, h / 2 + 198  , b2Body.b2_dynamicBody)
      bX += bSpacing

    new Circle(@world, 12, 12, bX + 8, h / 2 + 198  , b2Body.b2_dynamicBody)

    #row 4
    platform   = new Rect(@world, w , 2, w + 80  , h / 2 + 300 , b2Body.b2_staticBody)
    bX = 102
    for i in [1..45]
      new Rect(@world, 4, 12, bX, h / 2 + 297 , b2Body.b2_dynamicBody)
      bX += bSpacing

    #table
    bX = 694
    bSpacing = 40
    for i in [1..6]
      new Rect(@world, 4, 22, bX, h / 2 + 460 , b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 794
    new Rect(@world, 120, 4, bX , h / 2 + 420 , b2Body.b2_dynamicBody)

    #pyramid
    bX = 702
    bSpacing = 8
    for i in [1..24]
      new Rect(@world, 4, 4, bX, h / 2 + 410, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 718
    for i in [1..20]
      new Rect(@world, 4, 4, bX, h / 2 + 400, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 734
    for i in [1..16]
      new Rect(@world, 4, 4, bX, h / 2 + 390, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 750
    for i in [1..12]
      new Rect(@world, 4, 4, bX, h / 2 + 380, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 766
    for i in [1..8]
      new Rect(@world, 4, 4, bX, h / 2 + 370, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 782
    for i in [1..4]
      new Rect(@world, 4, 4, bX, h / 2 + 360, b2Body.b2_dynamicBody)
      bX += bSpacing

    bX = 790
    for i in [1..2]
      new Rect(@world, 4, 4, bX, h / 2 + 350, b2Body.b2_dynamicBody)
      bX += bSpacing


    @wreckingBall = new Circle(@world, 22, 12, 200, h / 2 + 440  , b2Body.b2_dynamicBody)

    document.addEventListener "mousedown", (e) =>
      @firstBrick.push()
      @wreckingBall.push()

  enableDebugDraw: ->
    debugDraw = new b2DebugDraw
    debugDraw.SetSprite(@ctx)
    debugDraw.SetDrawScale(20.0)
    debugDraw.SetFillAlpha(0.5)
    debugDraw.SetLineThickness(1.0)
    debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
    @world.SetDebugDraw(debugDraw)

  #draw: ->


  update: ->
    @world.Step(1/30,10,10)
    @world.DrawDebugData()
    @world.ClearForces()

  mainLoop: =>
    @update()
    requestAnimFrame(@mainLoop)
    #@draw()

class Playground
  constructor: ->
    @ctx = @createCanvas()
    new World(@ctx, @canvas.width, @canvas.height)

  createCanvas: ->
    @canvas = document.createElement("canvas")
    @canvas.width = 960
    @canvas.height = 640
    container = document.getElementById("container")
    container.appendChild(@canvas)
    @canvas.getContext("2d")

class InputHandler
  keysDown: {}

  constructor: (@world) ->
    window.addEventListener "keydown", (event) =>
      @keysDown[event.keyCode] = true

    window.addEventListener "keyup", (event) =>
      delete @keysDown[event.keyCode]

  update: ->
    #@world.up()    if 38 of @keysDown
    #@world.down()  if 40 of @keysDown
    #@world.left()  if 37 of @keysDown
    #@world.right() if 39 of @keysDown


window.Utilities = new Utilities
window.onload = new Playground
