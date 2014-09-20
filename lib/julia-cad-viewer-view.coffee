{View} = require 'atom'

THREE = require 'three'

# Current incarnation taken from https://atom.io/packages/animation-showcase

module.exports =
class JuliaCadViewerView extends View
  mouseX: 0
  mouseY: 0
  windowHalfX: window.innerWidth / 2
  windowHalfY: window.innerHeight / 2
  SEPARATION: 200
  AMOUNTX: 10
  AMOUNTY: 10
  camera: null
  scene: null
  renderer: null

  @content: ->
    @div =>
      @div class: "viewer", mousemove: 'onDocumentMouseMove', outlet: "threeContainer"

  initialize: (serializeState) ->
    atom.workspaceView.command "julia-cad-viewer:show", => @toggle()
    @threeInit()
    @animate()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
      @threeInit()
      @animate()

  getTitle: -> 'Julia CAD'
  getUri: -> 'cad-jl://test'
  threeInit: ->

    separation = 100
    amountX = 50
    amountY = 50
    particles = null
    particle = null

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    @camera.position.z = 100

    @scene = new THREE.Scene()
    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @threeContainer.empty()
    @threeContainer.append(@renderer.domElement)


    #particles
    PI2 = Math.PI * 2
    options =
      color: 0xffffff
      program: (context) ->
        context.beginPath()
        context.arc(0, 0, 0.5, 0, PI2, true)
        context.fill()

    material = new THREE.SpriteCanvasMaterial options

    geometry = new THREE.Geometry()

    for n in [0...100]

      particle = new THREE.Sprite material
      particle.position.x = Math.random() * 2 - 1
      particle.position.y = Math.random() * 2 - 1
      particle.position.z = Math.random() * 2 - 1
      particle.position.normalize()
      particle.position.multiplyScalar(Math.random() * 10 + 450)
      particle.scale.x = particle.scale.y = 10
      @scene.add particle
      geometry.vertices.push particle.position

    # lines
    line = new THREE.Line(geometry, new THREE.LineBasicMaterial({color: 0xffffff, opacity: 0.5}))
    @scene.add line

  animate: =>

    try
      requestAnimationFrame @animate
    catch error
      console.error "The error was #{error}"
    @render()

  render: ->

    @camera.position.x += (@mouseX - @camera.position.x) * .05
    @camera.position.y += (-@mouseY + 200 - @camera.position.y) * .05
    @camera.lookAt(@scene.position)
    @renderer.render(@scene, @camera)

  onDocumentMouseMove: (event) ->
    if event?
      @mouseX = event.clientX - @windowHalfX
      @mouseY = event.clientY - @windowHalfY
    else
      console.error "something went wrong"
      console.error event
