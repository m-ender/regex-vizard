root = global ? window

defaultColor = jQuery.Color "white"
skipColor = jQuery.Color "#888"
pendingColor = defaultColor
failedColor = jQuery.Color "#f55"

class root.Renderer
    constructor: (@regex, @target) ->
        @tokens = []
        @colGen = new ColorGenerator(
            hue: 180
            saturation: 1
            lightness: 0.7
            alpha: 1
        )

        collect = (token) =>
            id = token.debug.id
            @tokens[id] = token
            for subtoken in token.subtokens
                collect(subtoken)

        collect @regex.regex

        @colors = ((@getColorOf token if token?) for token in @tokens)

    getColorOf: (token) ->
        switch
            when token instanceof BasicToken
                return @colGen.nextColor(true)
            else
                return defaultColor

    render: (state) ->
        console.log state
        targetHtml = ''
        patternHtml = ''

        i = state.startingPosition - 1

        skipTarget = @target.substring(0, i)
        targetHtml += "<span style='color: #{skipColor.toHexString()};'>#{skipTarget}</span>"

        for token in @tokens
            unless token?
                continue

            switch
                when token instanceof Character
                    [n,color,p] = @renderCharacter(state, token)
                    targetHtml += if n > 0 then "<span style='color: #{color};'>#{@target.substr(i,n)}</span>" else ''
                    i += n
                    patternHtml += p

        remainingTarget = @target.substring(i)
        targetHtml += "<span style='color: #{pendingColor.toHexString()}'>#{remainingTarget}</span>"

        return [targetHtml, patternHtml]

    renderCharacter: (state, token) ->
        id = token.debug.id
        source = token.debug.source
        tokenState = state.tokens[id]

        switch tokenState.status
            when Inactive
                color = pendingColor.toHexString()
                n = 0
            when Failed
                color = failedColor.toHexString()
                n = 1
            when Matched
                color = @colors[id].toHexString()
                n = 1

        return [n, color, "<span style='color: #{color};'>#{source}</span>"]
