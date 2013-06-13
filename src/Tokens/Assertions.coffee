root = global ? window

class root.StartAnchor extends root.Token    
    constructor: (debug) ->
        super(debug)
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition - 1] == StartGuard
            @attempted = true
            return state.currentPosition
        return false
        
class root.EndAnchor extends root.Token    
    constructor: (debug) ->
        super(debug)
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted   
            @reset()
            return false
            
        if state.input[state.currentPosition] == EndGuard
            @attempted = true
            return state.currentPosition
        return false
        
class root.WordBoundary extends root.Token
    constructor: (debug, @negated = false) ->
        super(debug)
        @wordClass = new WordClass()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        leftChar = state.input[state.currentPosition-1]
        rightChar = state.input[state.currentPosition]
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
            @attempted = true
            return state.currentPosition
        return false           