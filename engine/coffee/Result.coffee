root = global ? window

root.Indeterminate = "indeterminate"
root.Failure = "failure"
root.Success = "success"

class root.Result
    constructor: (@type, @nextPosition = null) ->
