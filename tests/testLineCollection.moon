LineCollection = require 'a-mo.LineCollection'
Line = require 'a-mo.Line'
log = require 'a-mo.logging'

ourLines = {
	defaults: {
		actor: "", class: "dialogue", comment: false, effect: "banner",
		start_time: 0, end_time: 1000, extra: {}, layer: 0,
		margin_l: 0, margin_r: 0, margin_t: 0, section: "[Events]"
		style: "Default"
		text: "Hi, I am a line."
	}

	theLines: {
		{ }
		{ start_time: 1000, end_time:2000
		  text: "{\\fad(150,300)}I am fading out of existence." }
		{ start_time: 2000, end_time:3000
		  text: "{\\t(\\1c&HFF0000&)}I {\\t(0,0,\\1c&H00FF00&)}am {\\t(2.345,\\1c&H0000FF&)}transforming." }
		{ start_time: 4000, end_time:5000
		  text: "We are Identical." }
		{ start_time: 3500, end_time:4000
		  text: "We are Identical." }
		{ start_time: 3000, end_time:3500
		  text: "We are Identical." }
		{ start_time: 5000, end_time:6000
		  text: "{\\pos(280,237)\\clip(80,185,425,247.5)}I have been clipped" }
		{ start_time: 6000, end_time:7000
		  text: "{\\pos(280,237)\\clip(3,m 80 185 l 320 212 425 247 45 244)}I have been clipped too" }
	}

	iterator: =>
		i = 1
		n = #@theLines
		return ->
			if i <= n
				theLine = @theLines[i]
				i += 1
				for k,v in pairs @defaults
					theLine[k] = theLine[k] or v
				return theLine
}


testLineCollection = ( subtitles, selectedLines, activeLine ) ->
	-- We're just going to insert our subtitles here because it's
	-- guaranteed to be valid.
	first = selectedLines[1]

	-- Generate our the lines to insert using the template.
	theLines = [ line for line in ourLines\iterator! ]

	-- Actually insert the lines.
	subtitles.insert first, unpack theLines

	-- "Select" the lines we just inserted by generating a table of their
	-- indices.
	newSelLines = [ i for i = first, #theLines + first - 1 ]

	-- Instantiate our LineCollection class.
	ourLineCollection = LineCollection subtitles, newSelLines

	-- test munging.
	ourLineCollection\mungeLinesForFBF!

	-- convert our transforms into FBF Approved Format™
	for line in *ourLineCollection.lines
		i = 1
		line.text = line.text\gsub "\\t%b()", ( transform ) ->
			{ transStart, transEnd, transExp, transEffect } = line.transformations[i]
			i+=1
			return "\\t(#{transStart},#{transEnd},#{transExp},#{transEffect})"

	-- test cleanup (transforms must be in FBF Approved Format™ or this
	-- does not work.)
	ourLineCollection\cleanLines!

	-- Do an in-place replace of the lines we have just abused.
	ourLineCollection\replaceLines!

aegisub.register_macro "Test LineCollection", "Tests LineCollection and Line classes.", testLineCollection
