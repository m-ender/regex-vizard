root = global ? window

class root.Helper

    # Taken from http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning and slightly modified
    @clone: (obj) ->
        if not obj? or typeof obj isnt 'object'
            return obj

        newInstance = new obj.constructor()

        for key of obj
            newInstance[key] = @clone(obj[key])

        return newInstance