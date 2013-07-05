root = global ? window

class root.ColorGenerator
    constructor: (baseColor = '#74DDF2') ->
        @baseColor = jQuery.Color baseColor
        @i = 0
        
    nextColor: () ->
        @baseColor.hue "+=#{@phi * @i++}"
    
    # The Golden Ratio in degrees
    phi: 0.61803398874989484820 * 360