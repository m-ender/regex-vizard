root = global ? window

class root.JQueryHelper
    @addJQueryPlugins: () ->
        jQuery.fn.visible = () ->
            return @css('visibility', 'visible')

        jQuery.fn.invisible = () ->
            return @css('visibility', 'hidden')

        jQuery.fn.toggleInvisibility = () ->
            return @css('visibility', (i, visibility) ->
                return if (visibility is 'visible') then 'hidden' else 'visible'
            )