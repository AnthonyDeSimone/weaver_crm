/**
 *
 * @constructor
 */
var Barn = function(data) {

    var me = this;

    /**
     * A callback for when a change has occurred.
     */
    var changed = function(){};

    /**
     * The barn's dimensions in feet.
     * @type {{width: number, height: number, padding: {x: number, y: number}}}
     */
    this.dimensions = {
        width: -1,
        height: -1,
        padding: {
            x: 3,
            y: 3
        }
    };

    /**
     * The barn's placement in pixels.
     * @type {{x: number, y: number, width: number, height: number}}
     */
    this.pixels = {
        x: 0,
        y: 0,
        width: 0,
        height: 0
    };

    /**
     * The image url if there is a barn outline image for this size. Null otherwise.
     * @type {string}
     */
    this.image_url = null;

    this.toJSON = function() {
        return {
            dimensions: copyOf(me.dimensions),
            image_url: me.image_url
        };
    };

    if (isDefined(data)) {
        if (isDefined(data.dimensions)) {
            me.dimensions = data.dimensions;
        }
        if (isDefined(data.image_url)) {
            me.image_url = data.image_url;
        }
    }

    /**
     * Gets the style of the barn outline. May or may not include the background image..
     */
    this.getOutlineStyle = function() {
        var style = {
            "position": "absolute",
            "box-sizing": "border-box",
            "left": me.pixels.x + "px",
            "top": me.pixels.y + "px",
            "width": me.pixels.width + "px",
            "height": me.pixels.height + "px",
            "background-color": "white"
        };
        if (me.image_url) {
            style["background-image"] = "url('" + me.image_url + "')";
            style["background-size"] = "100% 100%";
        } else {
            style["border"] = "3px solid #374b5f";
        }
        return style;
    };

    /**
     * Gets the style of the barn outline if there is no image and it is a studio style.
     */
    this.getStudioOutlineStyle = function() {
        var foot = data.convertToPixels(1);
        foot = parseInt(foot * 2);
        var style = {
            "position": "absolute",
            "box-sizing": "border-box",
            "left": me.pixels.x + "px",
            "top": parseInt(me.pixels.y * 1 + me.pixels.height * 1 - foot),
            "width": me.pixels.width + "px",
            "height": "3px",
            "background-color": "#374b5f"
        };
        return style;
    };

    /**
     * Sets a function to be called upon any change taking place to the barn.
     * This is useful to get feedback when the image url has been changed, since
     * a watch may not be triggered between digestions. This allows the barn object
     * to be independent of angular while still having the ability to update the
     * form upon a change.
     * @param {function} cb
     */
    this.onChange = function(cb) {
        if (!isFunction(cb)) {
            throw "On change must be a function.";
        }
        changed = cb;
    };

    /**
     * Sets the dimensions of the barn.
     * @param {(number|{width:number,height:number})} width The width of the barn, or an object containing a width and height field.
     * @param {number} [height]
     */
    this.setDimensions = function(width, height) {
        console.log("height: ")
        console.log(height)
        console.log("width: ")
        console.log(width)

        var w, h;
        if (typeof width === 'undefined') {
            throw "Must give parameters.";
        }
        if (typeof height === 'undefined') {
            w = width.width;
            h = width.height;
            style = width.style
        } else {
            w = width;
            h = height;
        }


        // This is terrible...
        // Styles have the 'real_property" boolean that should be used
        // Currently only on the backend
        if(['Dutch Garage', 'Rockport Garage', 'The Classic Garage', 'Willow Creek Garage'].includes(form.options.style)){
            form.fees.sales_tax = 0;
        }


        // Set the dimensions.
        me.dimensions.width = w;
        me.dimensions.height = h;
        // Try to load the image if it exists.
        if(style == 'Studio'){
            me.dimensions.height = h + 2;
            var url = "/floor_plans/studio_" + h + "x" + w + ".png";
        }
        // else if(style == 'Rockport Garage'){
        //     me.dimensions.width = h;
        //     me.dimensions.height = w;

        //     w = me.dimensions.width;
        //     h = me.dimensions.height;
        // }

        else{
            var url = "/floor_plans/" + h + "x" + w + ".png";
        }
        $("<img src='" + url + "'/>").load(function() {
            // The image was found and loaded. Use an image instead of the default outline.
            me.image_url = url;
            changed();
        }).error(function() {
            me.image_url = null;
            changed();
        });
    };

    /**
     * Sets the padding.
     * @param {number} x The horizontal padding, or all padding if vertical is not given.
     * @param {number} [y] The optional vertical padding.
     */
    this.setPadding = function(x, y) {
        if (typeof x === 'undefined') {
            throw "Must supply at least one argument.";
        }
        if (typeof y === 'undefined') {
            //noinspection JSSuspiciousNameCombination
            y = x;
        }
        me.dimensions.padding = {x:x,y:y};
        changed();
    }

};