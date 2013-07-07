root = global ? window

# This represents a single literal character
class root.Character extends root.Token
    constructor: (debug, @character) ->
        super(debug)

    reset: () ->
        super()
        @attempted = false

    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false

        if state.input[state.currentPosition] == @character
            @attempted = true
            return state.currentPosition + 1
        return false