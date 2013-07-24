#Place all the behaviors and hooks related to the matching controller here.
#All this logic will automatically be available in application.js.
#You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

sideMenuOpen = (main, side, target, openWidth, closedWidth, sideWidth, distance) ->
	if side.css('width') is '50px'
		side.css 'width' : sideWidth + 'px'
		main.css 'width' : openWidth
		target.css 'left' : distance
	else
		side.css
			'width' : '50px'
		main.css 'width' : closedWidth
		target.css 'left' : '-3px'

resetMainWidth = (main, side, sideWidth) ->
	main.css
		'-webkit-transition': 'width 0'
		'transition': 'width 0'

	if side.css('width') is '50px'
		main.width($(window).width() - 50)
	else
		main.width($(window).width() - sideWidth)

	main.css
		'-webkit-transition': 'width 200ms'
		'transition': 'width 200ms'

$ =>
	#variable declarations
	$main = $('.main-wrapper')
	$side = $('.side-wrapper')
	$toggle = $('.side-menu-toggle')
	windowWidth = $(window).width()
	sideWidth = 200
	openMenuWidth = windowWidth - 200 + 'px'
	closedMenuWidth = windowWidth - 50 + 'px'
	toggleButtonDistance = sideWidth - 55 + 'px'



	$side.css
		width : '50px'
		'min-width' : '50px'
	$toggle.css
		left: '-3px'
		width: '50px'
	$main.css
		width: closedMenuWidth

	$('')


	$('.side-menu-toggle').click (event) =>
		sideMenuOpen $main, $side, $(event.target), openMenuWidth, closedMenuWidth, sideWidth, toggleButtonDistance

	$(window).resize =>
		resetMainWidth $main, $side