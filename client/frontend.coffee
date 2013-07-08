regex = null
matcher = null
subjectString = ''

colGen = new ColorGenerator(
    hue: 180
    saturation: 1
    lightness: 0.7
    alpha: 1
)

setupEngine = () ->
    regexString = $('#input-pattern').val()
    regex = new Regex regexString
    subjectString = $('#input-subject').val()
    matcher = regex.getMatcher subjectString

    $('#output-subject').html subjectString
    $('#output-pattern').html regexString
    $('#button-step-fw').visible()

stepForward = () ->
    s = matcher.subject
    if matcher.stepForward()
        color = colGen.nextColor().toHexString()
        $('#output-subject').html "<span style='color:#{color};'>#{s}</span>"
    else
        if matcher.success
            $('#button-step-fw').invisible()
            result = matcher.state
            startPos = matcher.startingPosition - 1
            length = result.captures[0].length
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