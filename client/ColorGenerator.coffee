root = global ? window

class root.ColorGenerator
    constructor: (baseColor = '#74DDF2') ->
        @baseColor = jQuery.Color baseColor
        @i = 0
        
    nextColor: (correctHue = true) ->
        if correctHue
            return @baseColor.hue @correctHue(@baseColor.hue() + @phi * @i++)
        else
            return @baseColor.hue (@baseColor.hue() + @phi * @i++)
    
    # The Golden Ratio in degrees
    phi: 0.61803398874989484820 * 360
    
    # Hue correction code from http://vis4.net/labs/colorscales/
    hueCorrection: [
        [5,10]
        [45,30]
        [70,50]
        [94,70]
        [100,110]
        [115,125]
        [148,145]
        [177,160]
        [179,182]
        [185,188]
        [225,210]
        [255,250]
    ]

    correctHue: (hue) ->
        hue = hue * (256/360) % 255
        lx = ly = 0
        for pair in @hueCorrection
            if hue == pair[0]
                return pair[1]
            else if hue < pair[0]
                newHue = ly + (pair[1]-ly)/(pair[0]-lx) * (hue - lx)
                return Math.floor(newHue * 360/256)
                
            lx = pair[0];
            ly = pair[1];