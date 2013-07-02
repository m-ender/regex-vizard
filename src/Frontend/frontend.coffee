$(document).ready () ->
    JQueryHelper.addJQueryPlugins()
    
    messageBox = $('#output-message')
    messageBox.visible()
    
    regex = new Regex('(z)((a+)?(b+)?(c))*')
    messageBox.html regex.match('zaacbbbcac')[0]
    
    console.log regex