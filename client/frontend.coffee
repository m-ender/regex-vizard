regex = null
subjectString = ''

setupEngine = () ->
    regexString = $('#input-pattern').val()
    regex = new Regex regexString
    subjectString = $('#input-subject').val()

    $('#output-subject').html subjectString
    $('#output-pattern').html regexString
    $('#button-step-fw').visible()

stepForward = () ->
    result = regex.match subjectString, true

    if result
        startPos = result.startingPosition - 1
        length = result.captures[0].length
        s = $('#output-subject').html()
        console.log s.slice 0, startPos
        console.log s.slice startPos, startPos + length
        console.log s.slice (startPos + length)
        highlight = "#{s.slice 0, startPos}<span class='match'>#{s.slice startPos, startPos + length}</span>#{s.slice (startPos + length)}"
        $('#output-subject').html highlight
    else
        $('#output-subject').html "<span class='nomatch'>#{s}</span>"

$(document).ready () ->
    JQueryHelper.addJQueryPlugins()

    $('#button-start').on 'click', setupEngine
    $('#button-step-fw').on 'click', stepForward

    colors = [
        "aqua"
        "black"
        "blue"
        "fuchsia"
        "gray"
        "green"
        "lime"
        "maroon"
        "navy"
        "olive"
        "purple"
        "red"
        "silver"
        "teal"
        "white"
        "yellow"
    ]



    colGen = new ColorGenerator(
        hue: 180
        saturation: 1
        lightness: 0.7
        alpha: 1
    )
    for i in [1..50]
        color = colGen.nextColor().toHexString()
        $('#output-colortest').append "<span style='color:#{color};'>#{colors[Math.floor(Math.random()*colors.length)]}</span><wbr />"
    $('#output-colortest').append "<br /><br />"
    colGen = new ColorGenerator(
        hue: 180
        saturation: 1
        lightness: 0.7
        alpha: 1
    )
    for i in [1..50]
        color = colGen.nextColor(false).toHexString()
        $('#output-colortest').append "<span style='color:#{color};'>#{colors[Math.floor(Math.random()*colors.length)]}</span><wbr />"
