---
---

# startSequence()
# .then(step1)
# .then(step2)
# .then(step3)
# .then(step4)
# .then(step5)
#
# # show composer
# step1 = ->
#   startStep()
#   .then(focusClient)
#   .then(doReply)
#   .then(typeReply)
#   .then(addImage)
#   .then(sendEmail)
#
# step2 = ->
#   startStep()
#   .then(addAccount)
#   .then(focusPicker)
#   .then(selectAccount)
#   .then(swapModes)
#
# step3 = ->
#   startStep()
#   .then(openLabelPicker)
#   .then(typeLabel)
#   .then(applyLabel)
#
# step4 = ->
#   startStep()
#   .then(openInspectorPanel)
#   .then(typeCommand)
#   .then(activateExtension)
#
# step5 = ->
#   startStep()
#   .then(fadeClient)
#   .then(showCta)

animationContainerSize = [0,0]

typeMe = (str, parent, {top, left}) -> new Promise (resolve, reject) ->
  el = $("<div contenteditable=true id='editable'/>")
  parent.append(el)
  el.css {top, left}
  el.focus()
  sequence = Promise.resolve()
  accumulator = ""
  setTimeout ->
    _.each str.split(''), (char, i) ->
      delay = Math.random() * 120 + 10
      sequence = sequence.then -> new Promise (resolve, reject) ->
        accumulator += char
        el.html(accumulator)
        selection = document.getSelection()
        selection?.setBaseAndExtent(selection.anchorNode, accumulator.length, selection.focusNode, accumulator.length)
        setTimeout(resolve, delay)
    sequence.then ->
      resolve()
  , 1500

addFramesToAnimationContainer = (frames, {wrapId}) ->
  i = 0
  frameImgs = _.map frames, ({delay, callback}, frame) ->
    i++
    "<img id='#{frame}' src='images/#{frame}.png' style='z-index: #{i}'/>"
  frameImgs = frameImgs.join('')
  $("#animation-container").append("<div id='#{wrapId}'>#{frameImgs}</div>")
  return

runFrames = (frames) ->
  sequence = Promise.resolve()
  _.each frames, ({delay, callback}, frame) ->
    sequence = sequence.then -> new Promise (resolve, reject) ->
      $("##{frame}").show()
      if callback then callback(delay, resolve)
      else setTimeout(resolve, delay)
  return sequence

window.step1 = ->

  # Need to know the dimensions of the images used in step 1
  animationContainerSize = [1136,823]
  positionAnimationContainer()

  typeInReply = (delay, resolve) ->
    coords =
      top: 449
      left: 608
    typeMe("Wow! Iceland looks awesome!", $("#step1"), coords)
    .then ->
      setTimeout ->
        selection = document.getSelection()
        selection?.setBaseAndExtent(selection.anchorNode, 19, selection.focusNode, 26)
        $("#1-4-hovering-toolbar").addClass("pop-in")
        resolve()
      , delay

  markBold = (delay, resolve) ->
    setTimeout ->
      $("#editable").html("Wow! Iceland looks <strong>awesome</strong>!")
      selection = document.getSelection()
      selection?.setBaseAndExtent(selection.anchorNode, 1000, selection.focusNode, 1000)
      $("#1-4-hovering-toolbar").removeClass("pop-in").addClass("pop-out")
      setTimeout(resolve, 2*delay)
    , delay

  adjustTypedText = (delay, resolve) ->
    $("#editable").removeAttr("contenteditable")
    $("#editable").css top: 428
    setTimeout(resolve, delay)

  showMultiSelectToolbar = (delay, resolve) ->
    $toolbarWrap = $("<div id='toolbar-wrap'><img id='toolbar' class='slide-in-from-top' src='images/2-topbar.png' style='display:block; position: relative' /></div>")
    $("#step2").append($toolbarWrap)
    $toolbarWrap.css
      "display": "block"
      "position": "absolute"
      "overflow": "hidden"
      "z-index": "7"
      "left": "266px"
      "top": "32px"
    setTimeout(resolve, delay)

  postArchiveUpdate = (delay, resolve) ->
    $("#toolbar").removeClass("slide-in-from-top").addClass("slide-out-to-top")
    $("#2-8-hover-archive").hide()
    $("#2-9-depress-archive").hide()
    $("#2-7-select-row-4").hide()
    $("#2-4-select-row-2").hide()
    setTimeout(resolve, delay)

  frames =
    step1:
      "1-1-initial-outlook-base": {delay: 3000}
      "1-2-depress-reply": {delay: 250}
      "1-3-show-reply": {delay: 500, callback: typeInReply}
      "1-4-hovering-toolbar": {delay: 1000, callback: markBold}
      "1-5-depress-send": {delay: 300}
      "1-6-sent-message": {delay: 2000, callback: adjustTypedText}
    step2:
      "2-1-initial-gmail-base": {delay: 2000}
      "2-2-select-row-1": {delay: 400, callback: showMultiSelectToolbar}
      "2-3-cursor-to-row-2": {delay: 400}
      "2-4-select-row-2": {delay: 400}
      "2-5-cursor-to-row-3": {delay: 250}
      "2-6-cursor-to-row-4": {delay: 400}
      "2-7-select-row-4": {delay: 800}
      "2-8-hover-archive": {delay: 1000}
      "2-9-depress-archive": {delay: 250}
      "2-10-updated-threadlist": {delay: 2000, callback: postArchiveUpdate}

  addFramesToAnimationContainer(frames.step1, wrapId: "step1")
  addFramesToAnimationContainer(frames.step2, wrapId: "step2")

  $("##{_.keys(frames.step1)[0]}").show()

  runFrames(frames.step1).then ->
    $("#step1").addClass("slide-out")
    $("#step2").addClass("slide-in")
    $("##{_.keys(frames.step2)[0]}").show()
    $timerFrame = $($("#step1")[0])
    $timerFrame.on "animationend", ->
      $timerFrame.off "animationend"
      $("#step1").remove()
      runFrames(frames.step2).then ->
        console.log "Step 2 done!"

positionAnimationContainer = ->
  winW = $(window).width()
  winH = $(window).height() - $("#nav").height()
  [w,h] = animationContainerSize

  scaleW = 1 - (Math.min(winW - w, 0) / -w)
  scaleH = 1 - (Math.min(winH - h, 0) / -h)
  scale = Math.min(scaleW, scaleH)
  $("#animation-container").css
    "width": "#{w}px"
    "height": "#{h}px"
    "margin-left": "-#{w/2}px"
    "-webkit-transform": "scale(#{scale})"
    "-moz-transform": "scale(#{scale})"
    "-ms-transform": "scale(#{scale})"
    "-o-transform": "scale(#{scale})"
    "transform": "scale(#{scale})"

# To allow for a fixed amount of bleed below the fold regardless of window
# size.
fixHeroHeight = ->
  Math.max(Math.min($("#hero")?.height($(window).height() + 200), 640), 1200)

# To ensure that our overflowing, dynamically sized screenshot pushes the
# remaining content down the correct ammount.
fixHeroMargin = ->
  marginBottom = Math.max(($("#main-screenshot").height() + ($("#main-screenshot").offset().top - $("#hero").offset().top)) - $("#hero").height(), 0)
  $("#hero").css(marginBottom: marginBottom)

# To ensure there's enough white-space between the watercolor images to
# let the hero text show through.
fixWatercolors = ->
  lCutoff = 0.55
  rCutoff = 0.6
  lWidth = $("#watercolor-left").width()
  rWidth = $("#watercolor-right").width()

  heroLeft = $("#hero-text").offset().left
  leftMove = Math.max(Math.min(heroLeft - (lWidth * lCutoff), 0), -lWidth * lCutoff)

  heroRight = $("#hero-text").offset().left + $("#hero-text").width()
  rightMove = Math.max(Math.min(heroRight - (rWidth * rCutoff), 0), -rWidth * rCutoff)

  $("#watercolor-left").css(left: leftMove)
  $("#watercolor-right").css(right: rightMove)

onResize = ->
  fixHeroHeight()
  # fixHeroMargin()
  fixWatercolors()
  positionAnimationContainer()

window.onresize = onResize
window.onload = ->
  onResize()
  $("body").addClass("initial")
  $("#play-intro").on "click", ->
    $("body").addClass("step-0").removeClass("initial")
    step1()
