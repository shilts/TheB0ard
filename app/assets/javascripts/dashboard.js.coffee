#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file:
  #http://jashkenas.github.com/coffee-script/

#animation controller for opening and closing the side sideBoard
sideMenuToggle = ($main, $side, $sideBoard, $sideBoardList, $target, mainOpenWidth,
                  mainClosedWidth, sideOpenWidth, sideClosedWidth, distance) ->
  if $side.css('width') is sideClosedWidth + 'px'
    $side.width(sideOpenWidth)
    $main.width(mainOpenWidth)
    $sideBoard.css 'width' : '90%'
    $sideBoardList.css 'left' : '0px'
    $target.css 'left' : distance + 'px'
  else
    $side.width(sideClosedWidth)
    $main.width(mainClosedWidth)
    $sideBoard.width(0)
    $sideBoardList.css 'left' : '-100%'
    $target.css 'left' : '-3px'

#Allows for dynamic resizing with the view window
resetMainWidth = ($main, $side, openWidth, closedWidth) ->
  if $side.css('width') is closedWidth + 'px'
    $main.width($(window).width() - closedWidth)
  else
    $main.width($(window).width() - openWidth)

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

  $sideBoard = $('.side-board')
  $swizzleBoard = $('.swizzle-board')
  $panelBoard = $('.panel-board')

  $sideToggle = $('.side-board-toggle')
  $displayToggle = $('.display-mode-toggle')

  $swizzles = $('.swizzle-status')
  $sideBoardList = $('.options-list')

  windowWidth = $(window).width()
  swizzleStatusWidth = $('.swizzle-status').outerWidth()
  sideOpenWidth = 300
  sideClosedWidth = 25
  mainWidthMenuOpen = windowWidth - sideOpenWidth
  mainWidthMenuClosed = windowWidth - sideClosedWidth
  toggleButtonDistance = sideOpenWidth - (sideClosedWidth + 6)
  extraSwizzleWidth = 15
  startScroll = 20

  $side.css
    width : sideClosedWidth + 'px'
    'min-width' : sideClosedWidth + 'px'
  $sideToggle.css
    left: '-3px'
    width: sideClosedWidth + 'px'
  $main.css
    width: mainWidthMenuClosed
  panelHeight = $panelBoard.height();
  $panelBoard.css
    'height' : panelHeight;

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
      $swizzleBoard.removeAttr('id')
    ->
      currScroll = $swizzleBoard.scrollLeft();
      $swizzleBoard.attr('id', 'autoscroll')
      $swizzleBoard.scrollLeft(currScroll)
  )

  $sideToggle.click (event) ->
    sideMenuToggle $main, $side, $sideBoard, $sideBoardList, $(event.target),
      mainWidthMenuOpen, mainWidthMenuClosed, sideOpenWidth,
        sideClosedWidth, toggleButtonDistance

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
