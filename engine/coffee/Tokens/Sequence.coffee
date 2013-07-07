root = global ? window

# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends root.Token
    constructor: () ->
        super()

    reset: () ->
        super()
        @i = 0 # the first subtoken to try upon calling nextMatch
        @pos = [] # "current" positions that were used by successful subtokens

    nextMatch: (state, report) ->
        if @i == -1
            @reset()
            return false

        if @subtokens.length == 0
            --@i
            return state.currentPosition

        result = @subtokens[@i].nextMatch(state, report)
        switch result
            when false
                --@i
                if @pos.length > 0
                    state.currentPosition = @pos.pop()
                return 0
            when -1, 0
                return result
            else
                if @i == @subtokens.length - 1
                    return result
                else
                    ++@i
                    @pos.push(state.currentPosition)
                    state.currentPosition = result
                    return -1
