root = global ? window

root.Indeterminate = "indeterminate"
root.Failure = "failure"
root.Success = "success"

class root.Result
    constructor: (@type, @nextPosition = null) ->

    @failureInstance: new Result(Failure)
    @Failure: ->
        return @failureInstance

    @indeterminateInstance: new Result(Indeterminate)
    @Indeterminate: ->
        return @indeterminateInstance

    @Success: (nextPosition) ->
        return new Result(Success, nextPosition)
