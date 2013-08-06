#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file:
  #http://jashkenas.github.com/coffee-script/

#------Allows for dynamic resizing with the view window
resetMainDimensions = ($main, $side, openWidth, closedWidth) ->
  winWidth = $(window).width()
  winHeight = $(window).height()
  if $side.hasClass 'menu-closed'
    $main.width(winWidth - closedWidth)
  else
    $main.width(winWidth - openWidth)

  $main.height(winHeight)
  $side.height(winHeight)

#------Ensures all swizzles are displayed in a horizontal list
recalculateSwizzlesWidth = (extra) ->
  $lists = $('.swizzle-board').children()
  $lists.each ->
    swizzleWidth = 0
    $(this).children().each ->
      swizzleWidth += $(this).outerWidth(true) + (extra*2)
    $(this).width(swizzleWidth)

#------infinite scrolling algorithm for the multiple swizzle boards
infiniteSwizzleScrolling = ($thisBoard, extra) ->
  if $('.display-mode').length > 0
    if $thisBoard.hasClass 'top-board'
      $board = $('.top-board')
      $list = $('.top-board .swizzle-list')
      $swizzles = $('.top-board .swizzle-status')
    else
      $board = $('.bottom-board')
      $list = $('.bottom-board .swizzle-list')
      $swizzles = $('.bottom-board .swizzle-status')
  else
    $board = $('.swizzle-board')
    $list = $('.swizzle-list')
    $swizzles = $('.swizzle-status')

  firstWidth = $swizzles.first().outerWidth(true)
  lastWidth = $swizzles.last().outerWidth(true)
  currScroll = $board.scrollLeft()
  listWidth = $list.width()
  windowWidth = $(window).width()
  leftScrollBarrier = 0
  rightScrollBarrier = (listWidth-lastWidth)

  #upon reaching the right edge...
  if (currScroll + windowWidth) >= (rightScrollBarrier)
    $swizzles.last().after $swizzles.first()
    $board.scrollLeft currScroll-firstWidth
  #upon reaching the left edge...
  else if currScroll <= leftScrollBarrier
    $swizzles.first().before $swizzles.last()
    $board.scrollLeft lastWidth

#------activate display mode
displayModeOn = (extra) ->
  $mainBoard = $('.swizzle-board')
  $mainBoard.after($mainBoard.clone().addClass 'top-board')
  $topBoard = $('.top-board')
  $topBoard.addClass 'display-mode'
  $topBoard.after($mainBoard.clone().addClass 'bottom-board')
  $bottomBoard =  $('.bottom-board')
  $bottomBoard.addClass 'display-mode'
  $railss = $('.bottom-board .type-rails')
  $touch2s = $('.top-board .type-touch2')

  $mainBoard.toggle()
  $touch2s.remove()
  $railss.remove()
  $('.top-board .commit-code').remove()
  $('.bottom-board .commit-code').remove()
  recalculateSwizzlesWidth extra

  $('.display-mode').each ->
    $(this).scrollLeft(100)

  activateSwizzleBoardEventHandlers(extra)

#------deactivate display mode
displayModeOff = (start, extra) ->
  $('.display-mode').remove()
  $('.swizzle-board').toggle().scrollLeft(start)
  recalculateSwizzlesWidth extra

activateSwizzleBoardEventHandlers = (extra) ->
  $('.swizzle-board').each ->
    $(this).scroll ->
      infiniteSwizzleScrolling $(this), extra

  $('.swizzle-board').each ->
    $(this).hover(
      ->
        $(this).removeClass 'autoscroll'
      ->
        currScroll = $(this).scrollLeft()
        $(this).addClass 'autoscroll'
        $(this).scrollLeft(currScroll)
    )

setSwizzleScrollSpeed = ($indicator) ->
  newSpeed = $indicator.val()
  speedVal = parseInt(newSpeed)
  if speedVal > 20
    newSpeed = "20"
  else if speedVal < "-20"
    newSpeed = "-20"
  $('.swizzle-board').css
    '-webkit-marquee-increment' : newSpeed + 'px'
  $indicator.val newSpeed

#-----$(document).ready
$ =>
  #variable declarations
  $main = $('.main-wrapper')
  $side = $('.side-wrapper')
  #main buttons
  $sideToggle = $('.side-board-toggle')
  $displayToggle = $('.display-mode-toggle')
  #boards
  $sideBoard = $('.side-menu')
  $swizzleBoard = $('.swizzle-board')
  $panelBoard = $('.panel-board')
  #lists
  $swizzles = $('.swizzle-status')
  $sideBoardList = $('.options-list')
  #other
  sideOpenWidth = 300
  sideClosedWidth = 30
  toggleTime = 200
  extraSwizzleWidth = 15
  startingScroll =
    ($swizzles.first().outerWidth(true) + (extraSwizzleWidth*2))/2

  $main.css
    'width' : ($(window).width() - sideClosedWidth) + 'px'

  recalculateSwizzlesWidth extraSwizzleWidth
  $swizzleBoard.scrollLeft(startingScroll)

  $(window).resize ->
    resetMainDimensions $main, $side, sideOpenWidth, sideClosedWidth

  activateSwizzleBoardEventHandlers(extraSwizzleWidth)

  $sideToggle.click ->
    winWidth = $(window).width()
    if $side.hasClass 'menu-closed'
      $side.removeClass 'menu-closed'
      $main.css
        width: (winWidth - sideOpenWidth) + 'px'
    else
      $side.addClass 'menu-closed'
      $main.css
        width: (winWidth - sideClosedWidth) + 'px'

  $displayToggle.click ->
    if !$panelBoard.hasClass 'display-mode'
      $panelBoard.addClass 'display-mode'
      displayModeOn extraSwizzleWidth
    else
      $panelBoard.removeClass 'display-mode'
      displayModeOff startingScroll, extraSwizzleWidth

  $('.scroll-speed.up').click ->
    $('.speed-indicator').val(parseInt($('.speed-indicator').val()) + 1)
    setSwizzleScrollSpeed $('.speed-indicator')

  $('.scroll-speed.down').click ->
    $('.speed-indicator').val(parseInt($('.speed-indicator').val())- 1)
    setSwizzleScrollSpeed $('.speed-indicator')

  $('.speed-indicator').bind "mousewheel keyup keydown input", ->
    setSwizzleScrollSpeed $(this)

  $('.self-destruct').click ->
    alert 'Why would you click that???'