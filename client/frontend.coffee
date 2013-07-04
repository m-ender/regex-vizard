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
    result = regex.match subjectString
    
    $('#output-message').visible()
    
    if result
        $('#output-message').html "Match found: #{result[0]}"
    else
        $('#output-message').html "No match! :-("
    
$(document).ready () ->
    JQueryHelper.addJQueryPlugins()
    
    $('#button-start').on 'click', setupEngine
    $('#button-step-fw').on 'click', stepForward
    