#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file:
  #http://jashkenas.github.com/coffee-script/

#Allows for dynamic resizing with the view window
resetMainWidth = ($main, $side, openWidth, closedWidth) ->
  winWidth = $(window).width()
  if $side.hasClass 'menu-closed'
    $main.width(winWidth - closedWidth)
  else
    $main.width(winWidth - openWidth)

#Ensures all swizzles are displayed in a horizontal list
recalculateSwizzleWidth = ($swizzles, extra) ->
  swizzleWidth = 0
  $swizzles.each ->
    swizzleWidth += $(this).outerWidth(true) + extra
  $('.swizzle-list').width(swizzleWidth)

infiniteSwizzleScrolling = ($board, $swizzles, startScroll, sWidth, extra) ->
  sLength = $swizzles.length
  currScroll = $board.scrollLeft()
  totalWidth = sWidth + extra*2

  if (currScroll-totalWidth) > totalWidth
    $swizzles.last().after $swizzles.first()
    $('.swizzle-board').scrollLeft(totalWidth)
    recalculateSwizzleWidth $swizzles, extra
  else if currScroll == 0
    $swizzles.first().before $swizzles.last()
    recalculateSwizzleWidth $swizzles, extra
    $('.swizzle-board').scrollLeft(sWidth)

displayModeOn = ->
  console.log 'display: on'

displayModeOff = ->
  console.log 'display: off'

$ =>
  #Variable declarations
  $main = $('.main-wrapper')
  $side = $('.side-wrapper')

  $sideToggle = $('.side-board-toggle')
  $displayToggle = $('.display-mode-toggle')

  $sideBoard = $('.side-menu')
  $swizzleBoard = $('.swizzle-board')
  $panelBoard = $('.panel-board')

  $swizzles = $('.swizzle-status')
  $sideBoardList = $('.options-list')

  swizzleStatusWidth = $('.swizzle-status').outerWidth()
  sideOpenWidth = 300
  sideClosedWidth = 30
  toggleTime = 200
  extraSwizzleWidth = 15
  startScroll = 20

  $main.css
    'width' : ($(window).width() - sideClosedWidth) + 'px'
  $panelBoard.css
    'height' : ($('.panel-board').height())

  recalculateSwizzleWidth $swizzles, extraSwizzleWidth
  $swizzleBoard.scrollLeft(startScroll)

  $(window).resize ->
    resetMainWidth $main, $side, sideOpenWidth, sideClosedWidth

  $swizzleBoard.scroll ->
    $swizzles = $('.swizzle-status')
    infiniteSwizzleScrolling $swizzleBoard, $swizzles,
      startScroll, parseInt(swizzleStatusWidth, 10), extraSwizzleWidth

  $('.swizzle-list').hover(
    ->
      $swizzleBoard.removeAttr 'id'
    ->
      currScroll = $swizzleBoard.scrollLeft()
      $swizzleBoard.attr 'id', 'autoscroll'
      $swizzleBoard.scrollLeft currScroll
  )

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
    console.log 'toggling'
    if !$panelBoard.hasClass 'display-mode'
      $panelBoard.addClass 'display-mode'
      $swizzleBoard.addClass 'display-mode'
      displayModeOn()
    else
      $panelBoard.removeClass 'display-mode'
      $swizzleBoard.removeClass 'display-mode'
      displayModeOff()
