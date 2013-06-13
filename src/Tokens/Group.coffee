root = global ? window

class root.Group extends root.Token
    constructor: (token, @index) ->
        super(token)
        
    reset: () ->
        super()
        @result = 0
        @firstPosition = false
        
    nextMatch: (state, report) ->
        if @result isnt 0
            result = @result
            if result is false
                @reset()
            else
                @result = 0
            return result
            
        if @firstPosition is false
            @firstPosition = state.currentPosition
            
        result = @subtokens[0].nextMatch(state, report)
        switch result
            when 0, -1
                return result
            when false
                @result = false
                state.captures[@index] = undefined
                return 0
            else
                state.captures[@index] = state.input[@firstPosition...result].join("")
                @result = result
                return -1