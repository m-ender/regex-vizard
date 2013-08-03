regex = null
matcher = null
renderer = null
regexString = ''
targetString = ''

colGen = new ColorGenerator(
    hue: 180
    saturation: 1
    lightness: 0.7
    alpha: 1
)

setupEngine = () ->
    regexString = $('#input-pattern').val()
    regex = new Regex regexString
    targetString = $('#input-target').val()
    matcher = regex.getMatcher targetString

    renderer = new Renderer regex, targetString

    $('#output-target').html targetString
    $('#output-pattern').html regexString
    $('#button-step-fw').visible()

stepForward = () ->
    s = matcher.subject
    if matcher.stepForward()
        if matcher.state.tokens[0].status is Failed
            i = matcher.state.startingPosition - 1
            $('#output-target').html "<span style='color: #888;'>#{targetString.substring(0, i)}</span>#{targetString.substring(i)}"
            $('#output-pattern').html "<span style='color: #f55;'>#{regexString}</span>"
        else
            [targetHtml, patternHtml] = renderer.render matcher.state
            $('#output-target').html targetHtml
            $('#output-pattern').html patternHtml
    else
        $('#button-step-fw').invisible()
        if matcher.success
            result = matcher.state
            startPos = result.startingPosition - 1
            length = result.captures[0].length
            highlight = "<span style='color: #888;'>#{s.substring 0, startPos}<span class='match'>#{s.substr startPos, length}</span>#{s.substr (startPos + length)}</span>"
            $('#output-target').html highlight
            $('#output-pattern').html "<span class='match'>#{regexString}</span>"
        else
            $('#output-target').html "<span class='nomatch'>#{s}</span>"

$(document).ready () ->
    JQueryHelper.addJQueryPlugins()

    $('#button-start').on 'click', setupEngine
    $('#button-step-fw').on 'click', stepForward
