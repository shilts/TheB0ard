#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file:
  #http://jashkenas.github.com/coffee-script/

#animation controller for opening and closing the side menu
sideMenuToggle = ($main, $side, $menu, $menuList, $target, mainOpenWidth,
                  mainClosedWidth, sideOpenWidth, sideClosedWidth, distance) ->
  if $side.css('width') is sideClosedWidth + 'px'
    $side.width(sideOpenWidth)
    $main.width(mainOpenWidth)
    $menu.css 'width' : '90%'
    $menuList.css 'left' : '0px'
    $target.css 'left' : distance + 'px'
  else
    $side.width(sideClosedWidth)
    $main.width(mainClosedWidth)
    $menu.width(0)
    $menuList.css 'left' : '-100%'
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

$ =>
  #Variable declarations
  $main = $('.main-wrapper')
  $side = $('.side-wrapper')
  $menu = $('.side-menu')
  $menuList = $('.options-list')
  $toggle = $('.side-menu-toggle')
  $swizzleBoard = $('.swizzle-board')
  $swizzles = $('.swizzle-status')
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
  $toggle.css
    left: '-3px'
    width: sideClosedWidth + 'px'
  $main.css
    width: mainWidthMenuClosed

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

  $('.side-menu-toggle').click (event) ->
    sideMenuToggle $main, $side, $menu, $menuList, $(event.target),
      mainWidthMenuOpen, mainWidthMenuClosed, sideOpenWidth,
        sideClosedWidth, toggleButtonDistance