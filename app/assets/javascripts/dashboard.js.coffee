#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file:
  #http://jashkenas.github.com/coffee-script/

#------Allows for dynamic resizing with the view window
resetMainDimensions = ($main, $side, openWidth, closedWidth, extra) ->
  winWidth = $(window).width()
  winHeight = $(window).height()
  if $side.hasClass 'menu-closed'
    $main.width(winWidth - closedWidth)
  else
    $main.width(winWidth - openWidth)

  $main.height(winHeight)
  $side.height(winHeight)
  $('.panel-board').height(winHeight-$('.swizzle-board').height())

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
  recalculateSwizzlesWidth extra
  $('.speed-indicator').val(3)
  setSwizzleScrollSpeed $('.speed-indicator')

  $('.display-mode').each ->
    $(this).scrollLeft(100)

  activateSwizzleBoardEventHandlers extra
  refreshSwizzleData extra

#------deactivate display mode
displayModeOff = (start, extra) ->
  $('.display-mode').remove()
  $('.swizzle-board').toggle().scrollLeft(start)
  recalculateSwizzlesWidth extra
  $('.speed-indicator').val(1)
  setSwizzleScrollSpeed $('.speed-indicator')

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

#---Updates the swizzle data
refreshSwizzleData = (extra) ->
  $.ajax
    type: 'GET'
    dataType: "json"
    url: './refresh_data'
    success: (data)->
      newData = false
      swizzles = $('.swizzle-status')
      for newSwizzle in data
        newTitle = newSwizzle.title
        newSwizzleTitleToID = newTitle.toLowerCase().replace(':','-')
        if newSwizzle.isDown == 1
          newSwizzleTitleToID = newTitle.toLowerCase().replace(':','-').substr(0, newTitle.indexOf(' '))
          downedSwizzle = newTitle.substr 0, newTitle.indexOf ' '
          oldSwizzles = $('h1:contains(' + downedSwizzle + ')').parent().parent().parent()
          oldSwizzles.each ->
            if $(this).hasClass 'swizzle-error'
              console.log '     ERROR: ' + downedSwizzle + ' is still not responding'
            else
              $(this).addClass 'swizzle-error'
              $(this).find('.title h1').text(newTitle)
              console.log '     ERROR: ' + downedSwizzle + ' is not responding'
              board = $(this).parent().parent()
              recalculateSwizzlesWidth extra
              scrollToSwizzle $(this).attr 'id', board
              newData = true
        else
          for oldSwizzles in swizzles
            oldSwizzles = $(oldSwizzles)
            oldSwizzles.each ->
              if (newSwizzle.commitCode != $(this).find('.commit-code p').text()) && (newSwizzleTitleToID == $(this).attr 'id')
                if $(this).hasClass 'swizzle-error'
                  $(this).removeClass 'swizzle-error'
                console.log '     Updating ' + newSwizzle.title + '...'
                $(this).find('.title h1').text(newSwizzle.title)
                $(this).find('.deployed-date p').text(newSwizzle.date)
                $(this).find('.deployer p').text(newSwizzle.deployer)
                $(this).find('.commit-code p').text(newSwizzle.commitCode)
                newGitURL = "http://git.labs.sabre.com:88/?p=" + newSwizzle.type + ".git;a=commitdiff;h=" + newSwizzle.commitCode
                $(this).find('.commit-code a').attr('href', newGitURL)
                $(this).find('.branch h1').text(newSwizzle.branch)

                console.log '       ' + newSwizzle.branch + ' has been deployed to ' + newSwizzle.title
                board = $(this).parent().parent()
                recalculateSwizzlesWidth extra
                scrollToSwizzle $(this).attr('id'), board
                newData = true
      if !newData
        console.log "     Nothing new to report, captain"
      else
        console.log ''
    error: ->
      console.log "     DANGER WILL ROBINSON: AJAX FAILURE\n"

#---Scrolls to any updated swizzle and triggers the wiggle animation
scrollToSwizzle = (name, $board) ->
  winWidth = $(window).width()
  console.log $board
  if $board.hasClass 'top-board'
    $swizzle = $('.top-board #'+name)
    $board.animate
      'scrollLeft': $swizzle.position().left - (winWidth/5)
      200
      'swing'
      ->
        updatedSwizzleAnimation $swizzle
  else if $board.hasClass 'bottom-board'
    $swizzle = $('.bottom-board #'+name)
    $board.animate
      'scrollLeft': $swizzle.position().left - (winWidth/5)
      200
      'swing'
      ->
        updatedSwizzleAnimation $swizzle
  else
    $swizzle = $('#'+name)
    console.log $swizzle.position()
    $board.animate
      'scrollLeft': $swizzle.position().left - (winWidth/3)
      200
      'swing'
      ->
        updatedSwizzleAnimation $swizzle

#---Wiggles the Swizzles
updatedSwizzleAnimation = ($swizzle) ->
        wiggleEffect $swizzle, 10
        setTimeout ->
          wiggleEffect($swizzle, -10)
        , 100
        setTimeout ->
          wiggleEffect($swizzle, 7)
        , 200
        setTimeout ->
          wiggleEffect($swizzle, -5)
        , 300
        setTimeout ->
          wiggleEffect($swizzle, 3)
        , 400
        setTimeout ->
          wiggleEffect($swizzle, 0)
        , 500

#---Individual wiggle function
wiggleEffect = ($swizzle, rot) ->
  $swizzle.css
    '-webkit-transform-origin': '50% 50%'
    "-webkit-transform": 'rotate(' + rot + 'deg)'
    'transform-origin': '50% 50%'
    'transform': 'rotate(' + rot + 'deg)'

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
  $panelList = $('.panel-list')
  #other
  sideOpenWidth = 300
  sideClosedWidth = 30
  toggleTime = 200
  extraSwizzleWidth = 15
  startingScroll = ($swizzles.first().outerWidth(true) + (extraSwizzleWidth*2))/2

  # Initial swizzle board setup
  recalculateSwizzlesWidth extraSwizzleWidth
  $swizzleBoard.scrollLeft(startingScroll)

  # Initial main wrapper and panel board setup
  $main.width $(window).width() - sideClosedWidth
  $panelBoard.height $(window).height()-$swizzleBoard.height()

  # Fix dimensions on window resize
  $(window).resize ->
    resetMainDimensions $main, $side, sideOpenWidth, sideClosedWidth

  activateSwizzleBoardEventHandlers(extraSwizzleWidth)

  # Refresh the Swizzle Data every 10 seconds
  setInterval ->
    refreshSwizzleData(extraSwizzleWidth)
  , 10000

  # Controlls the animations for opening the side board when the toggle button is clicked
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

  # Refreshes the SwizzleData on demand
  $('.refresh').click ->
    console.log "Refreshing Swizzle data..."
    refreshSwizzleData(extraSwizzleWidth)

  # Will eventually open the swizzle edit page to CRUD swizzles
  $('.edit-config').click ->

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
    $('body').remove();
    $('html').addClass 'desolation'
    $('html').append '<p>WELL, WHAT DID YOU EXPECT TO HAPPEN???!!1</p>'

    setInterval ->
      x = Math.random(300) * 100;
      y = Math.random(500) * 100;
      p = Math.floor((Math.random()*3)+2);
      $('.desolation').css
        'background-size' : x + 'px ' + y + 'px'
        'padding' : p + '%'
    1

  $('.panel').each ->
    $handle = $(this).find('.panel-header')
    $(this).draggable
      handle: $handle
      grid: [ 10, 10]
      containment: 'parent'
      scroll: 'true'
      start: ->
        $(this).css 'box-shadow' : '#000 20px 20px 20px'
      stop: ->
        $(this).css 'box-shadow' : '#000 10px 10px 10px'
