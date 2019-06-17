/**
 *
 * @param container {Visuals}
 * @param data {*}
 * @constructor
 */
var Visual = function(container, data) {

    var me = this;

    /**
     * The id of the component.
     * @type {number}
     */
    this.component_id = -1;

    /**
     * A reference to the actual component.
     * @type {null}
     */
    this.component = null;

    this.overlapping = [];

    this.add_overlapping = function(visual) {
        if (me.overlapping.indexOf(visual) === -1) {
            me.overlapping.push(visual);
        }
    };

    this.remove_overlapping = function(visual) {
        var index = me.overlapping.indexOf(visual);
        if (index !== -1) {
            me.overlapping.splice(index, 1);
        }
    }

    this.intersection = function(other) {
        let bounds = me.getRotatedBounds();
        let compare = other.getRotatedBounds();
        return bounds.intersection(compare);
    };

    this.overlaps = function(other, percent) {
        percent = percent || .6;
        if (other.z_order < me.z_order) {
            var intersection = me.intersection(other);
            if (intersection && intersection.area > (other.getBounds().area * percent)) {
                return intersection;
            }
        }
        return false;
    }

    this.check_overlapping = function() {
        for (var i in container.visuals) {
            if (container.visuals.hasOwnProperty(i)) {
                var other = container.visuals[i];
                if (other !== me) {
                    if (me.overlaps(other)) {
                        me.add_overlapping(other);
                    } else {
                        me.remove_overlapping(other);
                    }
                    if (other.overlaps(me)) {
                        other.add_overlapping(me);
                    } else {
                        other.remove_overlapping(me);
                    }
                }
            }
        }
    }

    /**
     *
     * @type {{is_custom: boolean, text: string, stretch: boolean, border: boolean, border_color: string, filled: boolean, bg_color: string, size: string}}
     */
    this.custom = {
        is_custom: false,
        text: 'Sample Text',
        has_text: true,
        stretch: false,
        border: true,
        border_color: "#374b5f",
        filled: false,
        bg_color: "white",
        size: "specify"
    };

    /**
     * Whether or not this visual has been flipped.
     * @type {boolean}
     */
    this.flipped = false;

    /**
     * The id of this visual and its span element.
     * @type {string}
     */
    this.id = '-1';

    /**
     * The image url associated with this visual.
     * @type {string}
     */
    this.image_url = '';

    /**
     * If hovering over the icon of this visual.
     * @type {boolean}
     */
    this.is_hovering = false;

    /**
     * This will be set to true while it is resizing.
     * @type {boolean}
     */
    this.is_resizing = false;

    /**
     * The z order of this visual.
     * @type {number}
     */
    this.z_order = 0;

    /**
     * The bounds of this visual.
     * @type {Rectangle}
     */
    var bounds = new Rectangle();

    /**
     * The rotation of this visual.
     * @type {number}
     */
    var rotation = 0;

    this.set_on_open = null;

    /**
     * Flips this visual.
     */
    this.flip = function() {
        me.flipped = !me.flipped;
        if (container.isSelected(me)) {
            editor.updateVisualOption();
        }
    };

    this.getRotatedBounds = function() {
        let rect = new Rectangle(me.getBounds());
        if (rotation % 2 === 1) {
            let tmp = rect.width;
            rect.width = rect.height;
            rect.height = tmp;
        }
        return rect;
    }

    /**
     * Gets the bounding rectangle of this visual as an offset (top left of document) in pixels.
     * @returns {{x: number, y: number, width: number, height: number}}
     */
    this.getBoundingOffset = function() {
        var span = $("#" + me.id);
        var off = span.offset();
        var dim = {
            width: span.outerWidth(),
            height: span.outerHeight()
        };
        if (rotation % 2 == 1) {
            var tmp = dim.width;
            //noinspection JSSuspiciousNameCombination
            dim.width = dim.height;
            dim.height = tmp;
        }
        var foo = {
            x: + off.left,
            y: + off.top,
            width: + dim.width,
            height: + dim.height
        };
        return foo;
    };

    /**
     * Gets the bounds of this visual in feet based on top left of barn.
     * @returns Rectangle
     */
    this.getBounds = function() {
        return bounds;
    };

    /**
     * Gets the reference to the actual component held by this visual.
     * @returns {null}
     */
    this.getComponent = function() {
        if (me.component == null) {
            me.component = form.getComponentById(me.component_id);
        }
        return me.component;
    };

    /**
     * Gets the display URL for the component.
     * @returns {*}
     */
    this.getDisplayUrl = function() {
        return form.getDisplayImage(me.getComponent());
    };

    this.getImageStyle = function() {
        var style = {
            display: "block"
        };
        var width = container.convertToPixels(bounds.size.width);
        var height = container.convertToPixels(bounds.size.height);
        if (me.is_hovering) {
            width -= 9;
            height -= 10;
        } else if (container.isSelected(me)) {
            width--;
            height -= 2;
        }
        style["width"] = width + "px";
        style["height"] = height + "px";
        style["min-width"] = style["max-width"] = style["width"];
        style["min-height"] = style["max-height"] = style["height"];
        return style;
    };

    this.getRotation = function() {
        return rotation;
    };

    /**
     * Gets a simple JSON representation of this object. This object can be instantiated
     * given this save object.
     * @returns {
     *   {
     *      version: number,
     *      bounds: {
     *          x: number,
     *          y: number,
     *          width: number,
     *          height: number
     *      },
     *      component_id: number,
     *      custom: {
     *          is_custom: boolean,
     *          text: string,
     *          stretch: boolean,
     *          border: boolean,
     *          auto_size: boolean,
     *          id: string
     *      },
     *      flipped: boolean,
     *      id: string,
     *      image_url: string,
     *      rotation: number,
     *      z_order: number
     *   }
     * }
     */
    this.getSaveObject = function() {
        return {
            version: VERSION_NUMBER,
            bounds: bounds.toJson(),
            component_id: me.component_id,
            custom: JSON.parse(JSON.stringify(me.custom)),
            flipped: me.flipped,
            id: me.id,
            image_url: me.image_url,
            rotation: rotation,
            z_order: me.z_order
        }
    };

    /**
     * Gets the span style for custom visuals.
     */
    this.getSpanStyle = function() {
        var style = {
            display: "block"
        };

        var width = container.convertToPixels(bounds.size.width);
        var height = container.convertToPixels(bounds.size.height);

        if (me.custom.border) {
            width -= 14;
            height -= 11;
        }

        if (me.is_hovering) {
            width -= 10;
            height -= 10;
        }

        style["width"] = width + "px";

        style["position"] = "relative";

        style["top"] = 0;
        style["left"] = 0;

        var span = $("#" + me.id).find("span").first();

        if (rotation % 4 == 0) {
            style["top"] = height / 2 - span.height() / 2 + "px";
        } else if (rotation % 4 == 1) {
            style["left"] = height / 2 - span.height() / 2 + "px";
        } else if (rotation % 4 == 2) {
            style["top"] = height / 2 - span.height() / 2 + "px";
        } else if (rotation % 4 == 3) {
            style["top"] = 0;
            style["left"] = height / 2 - span.height() / 2 + "px";
        }

        style["font-size"] = "1.5em";

        style["text-align"] = "center";

        return style;
    };

    /**
     *
     * @returns {{}}
     */
    this.getStyle = function() {
        var style = {};
        style["position"] = "absolute";
        style["box-sizing"] = "border-box";
        var p = {
            x: container.convertToPixels(bounds.position.x),
            y: container.convertToPixels(bounds.position.y)
        };
        var s = {
            w: container.convertToPixels(bounds.size.width),
            h: container.convertToPixels(bounds.size.height)
        };

        var barn = $("#barn-outline");

        p.x += barn.position().left;
        p.y += barn.position().top;

        style["left"] = p.x + "px";
        style["top"] = p.y + "px";

        style["z-index"] = container.selected == me
            ? 9998
            : 8000 + me.z_order;

        if (me.is_resizing) {
            style["border"] = "3px solid #666";
            return style;
        }

        if (me.is_hovering) {
            style["z-index"] = 9999;
        }

        style["cursor"] = "grab";

        if (rotation % 2 == 0) {
            style["width"] = s.w + "px";
            style["height"] = s.h + "px";
        } else {
            style["width"] = s.h + "px";
            style["height"] = s.w + "px";
        }

        if (me.custom.is_custom) {
            if (me.custom.border) {
                style["border"] = "2px solid " + me.custom.border_color;
                style["padding"] = "5px";
            } else {
                style["border"] = "none";
            }
        }

        if (me.custom.filled) {
            style["background-color"] = me.custom.bg_color;
        }

        if (me.is_hovering) {
            style["border"] = "5px solid gold";
        }

        return style;
    };

    /**
     * Rotates this visual.
     */
    this.rotate = function() {
        me.setRotation((rotation + 1) % 4);
    };

    /**
     * Sets the position of this visual as an offset in pixels.
     * @param {(number|{x:number,y:number}|{left:number,top:number})} x
     * @param {number} [y]
     */
    this.setOffset = function(x, y) {
        if (typeof x === 'undefined') {
            throw new Error("Need a parameter to set offset.");
        }
        if (typeof y === 'undefined') {
            y = x.hasOwnProperty("y")
                ? x.y
                : x.top;
            x = x.hasOwnProperty("x")
                ? x.x
                : x.left;
        }
        var barn = $("#barn-outline");
        me.setFeetPosition(container.convertToFeet(x - barn.offset().left), container.convertToFeet(y - barn.offset().top));
        me.check_overlapping();
    };

    /**
     * Sets the feet position of this visual as based on the top left of the barn in feet.
     * @param {(number|{x:number,y:number}|{left:number,top:number})} x
     * @param {number} [y]
     */
    this.setFeetPosition = function(x, y) {
        if (typeof x === 'undefined') {
            throw new Error("Need a parameter to set position.");
        }
        if (typeof y === 'undefined') {
            y = x.hasOwnProperty("y")
                ? x.y
                : x.top;
            x = x.hasOwnProperty("x")
                ? x.x
                : x.left;
        }
        x = +(+ x).toFixed(2);
        y = +(+ y).toFixed(2);
        bounds.position.x = x;
        bounds.position.y = y;
        if (container.isSelected(me)) {
            editor.updateVisualOption();
        }
        me.check_overlapping();
    };

    this.setFeetSize = function(width, height) {
        width = +(+ width).toFixed(2);
        height = +(+ height).toFixed(2);
        if (width < .1) {
            width = .1;
        }
        if (height < .1) {
            height = .1;
        }
        if (width > 100) {
            width = 100;
        }
        if (height > 100) {
            height = 100;
        }
        bounds.size.width = width;
        bounds.size.height = height;
        if (container.isSelected(me)) {
            editor.updateVisualOption();
        }
    };

    this.select = function() {
        container.selectVisual(me);
    };

    this.setPixelSize = function(width, height) {
        me.setFeetSize(container.convertToFeet(width), container.convertToFeet(height));
    };

    /**
     * Sets the rotation for this visual to a specific value.
     * @param rot The value (0-3) to set it to.
     */
    this.setRotation = function(rot) {
        rot = rot % 4;
        rotation = rot;
        if (container.isSelected(me)) {
            editor.updateVisualOption();
        }
    };

    this.toJSON = function() {
        return {
            bounds: bounds,
            component_id: me.component_id,
            custom: copyOf(me.custom),
            flipped: me.flipped,
            id: me.id,
            image_url: me.image_url,
            rotation: rotation,
            z_order: me.z_order,
            version: VERSION_NUMBER
        };
    };

    // Load up given options.
    if (isDefined(data)) {
        if (data.hasOwnProperty("version") && data.version == 'adding') {
            // Data being loaded from drop into visual editor.
            me.id = data.id;
            me.component_id = data.component_id;
            me.rotation = data.rotation;
            me.z_order = data.z_order;
            me.flipped = data.flipped;
            if (isDefined(data.custom) && data.custom !== null) {
                me.custom = data.custom;
            } else {
                me.image_url = me.getDisplayUrl();
            }
        } else {
            bounds = new Rectangle(data.bounds);
            me.component_id = data.component_id;
            for (var i in data.custom) {
                //noinspection JSUnresolvedFunction
                if (data.custom.hasOwnProperty(i) && me.custom.hasOwnProperty(i)) {
                    me.custom[i] = data.custom[i];
                }
            }
            me.flipped = data.flipped;
            me.id = data.id;
            me.image_url = data.image_url;
            rotation = data.rotation;
            me.z_order = data.z_order;
        }
    }

    // Ignore auto size.
    me.custom.size = "specify";

};

Visual.intersection = function(b1, b2) {}
