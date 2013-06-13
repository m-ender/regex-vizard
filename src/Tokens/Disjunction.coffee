root = global ? window

class root.Disjunction extends root.Token
    constructor: (token) ->
        super(token)
        
    reset: () ->
        super()
        @i = 0 # the first subtoken to try upon calling nextMatch

    nextMatch: (state, report) ->
        if @i == @subtokens.length
            @reset()
            return false
            
        result = @subtokens[@i].nextMatch(state, report)
        
        if result != false
            return result
        else
            ++@i
            return 0