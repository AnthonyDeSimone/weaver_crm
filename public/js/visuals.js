

/**
 * Accounts for all of the visuals, dimensions, layout, and pixel-feet conversion.
 * @constructor
 */
var Visuals = function(editor, data) {

    var me = this;

    this.barn = new Barn(this);
    /**
     *
     * @type {{Visual}}
     */
    this.visuals = {};

    this.selected = null;
    this.id_count = 9000;
    this.z_top = 0;

    this.pixels_per_foot = 0;


    this.addVisual = function(component_id, x, y, add, custom, width, height) {
        var id = "visual_" + (++me.id_count);
        if (component_id <= 0) {
            add = false;
        }
        /** @type {(Visual[]|Visual)} */
        var vis;
        // Supposed to add, but unable to. Instead, just move the first visual component with
        // this id to that location and return.
        if (add && !form.addComponent(form.getComponentById(component_id))) {
            vis = me.getVisualsByComponent(component_id);
            if (vis.length > 0) {
                vis[0].setOffset(x, y);
            }
            return;
        }

        // Create a new visual component to add.
        vis = new Visual(me, {
            id: id,
            component_id: component_id,
            rotation: 0,
            z_order: ++me.z_top,
            flipped: false,
            custom: custom,
            version: 'adding'
        });
        vis.setOffset(x, y);
        if (isDefined(width) && isDefined(height)) {
            if (isString(width) && isString(height) && width[0] == 'f' && height[0] == 'f') {
                vis.setFeetSize(width.substr(1), height.substr(1));
            } else {
                vis.setPixelSize(width, height);
            }
        }
        me.visuals[id] = vis;
        me.selectVisual(vis);
    };

    /**
     * Calculates the pixels per foot without centering the barn. For convenience, returns
     * the pixels per foot.
     * @returns {number} The pixels per foot.
     */
    this.calculatePixelsPerFoot = function() {
        var barn = me.barn;
        if (barn.dimensions.width == -1 || barn.dimensions.height == -1) {
            throw new Error("Must choose barn dimensions first.");
        }

        var ov = $("#overlay");

        // Overlay dimensions (pixels)
        var od = {
            width: ov.width(),
            height: ov.height()
        };
        // Barn dimensions with padding (feet)
        var bd = {
            width: barn.dimensions.width + 2 * barn.dimensions.padding.x,
            height: barn.dimensions.height + 2 * barn.dimensions.padding.y
        };
        // Overlay aspect ratio.
        var oa = od.width / od.height;
        // Barn aspect ratio.
        var ba = bd.width / bd.height;

        // The height is the limiting factor in terms of spacing.
        if (ba < oa) {
            me.pixels_per_foot = od.height / bd.height;
        }
        // The width id the limiting factor.
        else {
            me.pixels_per_foot = od.width / bd.width;
        }
        return me.pixels_per_foot;
    };

    /**
     * Calculates the dimensions of the barn in pixels and the pixels per foot conversion.
     */
    this.centerBarn = function() {
        if (!editor.is_open) {
            return;
        }
        var barn = me.barn;
        if (barn.dimensions.width == -1 || barn.dimensions.height == -1) {
            throw new Error("Must choose barn dimensions first.");
        }

        var ov = $("#overlay");

        // Overlay dimensions (pixels)
        var od = {
            width: ov.width(),
            height: ov.height()
        };
        // Barn dimensions with padding (feet)
        var bd = {
            width: barn.dimensions.width + 2 * barn.dimensions.padding.x,
            height: barn.dimensions.height + 2 * barn.dimensions.padding.y
        };
        // Overlay aspect ratio.
        var oa = od.width / od.height;
        // Barn aspect ratio.
        var ba = bd.width / bd.height;

        // The height is the limiting factor in terms of spacing.
        if (ba < oa) {
            me.pixels_per_foot = od.height / bd.height;
        }
        // The width id the limiting factor.
        else {
            me.pixels_per_foot = od.width / bd.width;
        }

        // Convert the barn dimensions to pixels.
        barn.pixels.width = me.convertToPixels(barn.dimensions.width);
        barn.pixels.height = me.convertToPixels(barn.dimensions.height);

        // Center the barn within the overlay.
        barn.pixels.x = od.width / 2 - barn.pixels.width / 2;
        barn.pixels.y = od.height / 2 - barn.pixels.height / 2;
    };

    this.checkVisualOnOpens = function() {
        if (!editor || !editor.is_open) {
            return;
        }
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                /** @type {Visual} */
                var vis = me.visuals[i];
                if (vis.set_on_open != null) {
                    vis.setPixelSize(vis.set_on_open.width, vis.set_on_open.height);
                    vis.set_on_open = null;
                }
            }
        }
    };

    /**
     * Loops through each visual and makes sure that it fits within the overlay's bounds.
     */
    this.checkVisualBounds = function() {
        // TODO implement
    };

    /**
     * Converts pixels to feet.
     * @param pixels The pixels to convert.
     * @returns {number} The feet given the pixels.
     */
    this.convertToFeet = function(pixels) {
        return pixels / me.pixels_per_foot;
    };

    /**
     * Converts feet to pixels.
     * @param feet The feet to convert.
     * @returns {number} The pixels given the feet.
     */
    this.convertToPixels = function(feet) {
        return feet * me.pixels_per_foot;
    };


    /**
     * Gets the minimum bounding box of the visual components, with 3px added to each side so as to include borders.
     * @returns {Rectangle}
     */
    this.getBoundingRectangle = function() {
        if (!editor.is_open) {
            return new Rectangle();
        }
        var barn = $("#barn-outline");
        // Start off with the bounds of the barn, then increase/decrease as needed for
        // the visuals.
        var rect = {
            x: barn.offset().left,
            y: barn.offset().top,
            width: barn.width(),
            height: barn.height()
        };
        // Go through each visual and adjust the bounding rectangle as needed.
        for (var vi in me.visuals) {
            if (me.visuals.hasOwnProperty(vi)) {
                /** @type {Visual} */
                var vis = me.visuals[vi];
                //noinspection SpellCheckingInspection
                var vrect = vis.getBoundingOffset();
                if (vrect.x < rect.x) {
                    rect.width += (rect.x - vrect.x);
                    rect.x = vrect.x;
                }
                if (vrect.y < rect.y) {
                    rect.height += (rect.y - vrect.y);
                    rect.y = vrect.y;
                }
                if (vrect.x + vrect.width > rect.x + rect.width) {
                    rect.width = vrect.x + vrect.width - rect.x;
                }
                if (vrect.y + vrect.height > rect.y + rect.height) {
                    rect.height = vrect.y + vrect.height - rect.y;
                }
            }
        }
        var r = new Rectangle({
            x: +rect.x - 3,
            y: +rect.y - 3,
            width: +rect.width + 6,
            height: +rect.height + 6
        });
        return r;
    };

    /**
     * Gets all of the components that should be waiting in the queued area. The same
     * component may appear multiple times in the list, this signifies that it should
     * have multiple instances in the queued area.
     * @returns {Array}
     */
    this.getQueuedVisuals = function() {
        var qd = [];
        var components = form.getAllComponents();
        // Go through each component in the form, check first if it should be shown,
        // and also check its quantity to find out how many items should be available
        // in the queued area.
        for (var ci in components) {
            if (components.hasOwnProperty(ci)) {
                var comp = components[ci];
                // If the component should not be shown, then do nothing.
                if (!comp.show || comp.id == 0) {
                    continue;
                }
                var img = form.getDisplayImage(comp);
                // If the component has no display image, then do nothing.
                // (Not a visual component)
                if (img == null) {
                    continue;
                }
                // Get how many items are already placed given this component.
                var viss = me.getVisualsByComponent(comp);
                var len = viss ? viss.length : 0;
                // Figure out how many total items should be available.
                var qty = form.getQuantity(comp);
                // Given the difference between placed items and items that should
                // be placed, add that many to the queued components. May be 0.
                // Pushing the same component multiple times means that there should
                // be multiple of that component in the queued list.
                for (var i = 0; i < (qty - len); i++) {
                    qd.push(comp);
                }
            }
        }
        // At this point, the qd array should have all of the components that should be
        // waiting in the queued area, even if it is empty.
        return qd;
    };

    /**
     * Gets an array of visuals by the component, or its id.
     * @param component A component or its id.
     * @returns {Array} An array of visual components. May be empty.
     */
    this.getVisualsByComponent = function(component) {
        var cid;
        if (typeof component == 'number') {
            cid = component;
        } else {
            cid = component.id;
        }
        var viss = [];
        for (var vid in me.visuals) {
            if (me.visuals.hasOwnProperty(vid)) {
                var vis = me.visuals[vid];
                if (vis.component_id == cid) {
                    viss.push(vis);
                }
            }
        }
        return viss;
    };

    this.getVisualsByZ = function() {
        var viss = [];
        for (var vid in me.visuals) {
            if (me.visuals.hasOwnProperty(vid)) {
                viss.push(me.visuals[vid]);
            }
        }
        viss.sort(function(a,b) {
            return b.z_order - a.z_order;
        });
        return viss;
    };

    /**
     * Checks if a visual is the currently selected one.
     * @param visual {Visual}
     * @returns {boolean} True if selected, false if not.
     */
    this.isSelected = function(visual) {
        return me.selected == visual;
    };

    /**
     * Sets the maximum number of visuals for a specific component. For example, if there
     * are only 3 of component x on the form, but there are 4 visuals for it, this will
     * remove one.
     * @param component
     * @param quantity
     */
    this.setMaxOf = function(component, quantity) {
        if (component.id == 0) {
            return;
        }
        var count = 0;
        for (var vid in me.visuals) {
            if (me.visuals.hasOwnProperty(vid)) {
                var vis = me.visuals[vid];
                if (vis.component_id == component.id) {
                    count++;
                    if (count > quantity) {
                        me.visuals[vid] = null;
                    }
                }
            }
        }
        if (count <= quantity) {
            return;
        }
        var newvis = {};
        for (var vid in me.visuals) {
            if (me.visuals.hasOwnProperty(vid)) {
                if (me.visuals[vid] != null) {
                    newvis[vid] = me.visuals[vid];
                }
            }
        }
        me.visuals = newvis;
    };

    /**
     * Removes a visual from the list of visuals.
     * @param {(string|Visual)} visual
     */
    this.removeVisual = function(visual) {
        // Get the visual and its id based on input parameter.
        var vid, vis;
        if (typeof visual === 'undefined') {
            throw new Error("Need a parameter.");
        } else if (typeof visual === 'string') {
            vid = visual;
            if (!me.visuals.hasOwnProperty(vid)) {
                return;
            }
            vis = me.visuals[vid];
        } else if (visual.constructor === Visual) {
            vid = visual.id;
            vis = visual;
        } else {
            throw new Error("Unknown parameter type.");
        }
        // If the visual is not contained in this container, then there is nothing to do.
        if (!me.visuals.hasOwnProperty(vid)) {
            return;
        }
        // Get the component of the visual. This will be null if it is a custom visual.
        var component = vis.getComponent();
        delete me.visuals[vid];
        // If the component exists, remove one of it.
        if (component) {
            form.removeComponent(component);
        }
        if (vis == me.selected) {
            me.selectVisual(null);
        }
    };

    this.selectVisual = function(visual) {
        me.selected = visual;
        editor.updateVisualOption();
    };

    /**
     *
     * @param visual {Visual}
     */
    this.setZTop = function(visual) {
        if (!visual) {
            return;
        }
        var top = 0;
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                /** @type {Visual} */
                var vis = me.visuals[i];
                if (vis === visual) {
                    continue;
                }
                if (vis.z_order > top) {
                    top = vis.z_order;
                }
                if (vis.z_order > visual.z_order) {
                    vis.z_order--;
                }
            }
        }
        visual.z_order = top;
    };

    /**
     *
     * @param visual {Visual}
     */
    this.setZBottom = function(visual) {
        if (!visual) {
            return;
        }
        var bottom = Math.pow(2, 30);
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                /** @type {Visual} */
                var vis = me.visuals[i];
                if (vis === visual) {
                    continue;
                }
                if (vis.z_order < bottom) {
                    bottom = vis.z_order;
                }
                if (vis.z_order < visual.z_order) {
                    vis.z_order++;
                }
            }
        }
        visual.z_order = bottom;
    };

    /**
     *
     * @param visual {Visual}
     */
    this.setZUp = function(visual) {
        if (!visual) {
            return;
        }
        var arr = [];
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                /** @type {Visual} */
                var vis = me.visuals[i];
                arr.push(vis);
            }
        }
        arr.sort(function(a, b) {
            return a.z_order - b.z_order;
        });
        var i = arr.indexOf(visual);
        if ((i != -1) && (i != (arr.length - 1))) {
            var tmp = arr[i + 1].z_order;
            arr[i + 1].z_order = visual.z_order;
            visual.z_order = tmp;
        }
    };

    /**
     *
     * @param visual {Visual}
     */
    this.setZDown = function(visual) {
        if (!visual) {
            return;
        }
        var arr = [];
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                /** @type {Visual} */
                var vis = me.visuals[i];
                arr.push(vis);
            }
        }
        arr.sort(function(a, b) {
            return a.z_order - b.z_order;
        });
        var i = arr.indexOf(visual);
        if ((i != -1) && (i > 0)) {
            var tmp = arr[i - 1].z_order;
            arr[i - 1].z_order = visual.z_order;
            visual.z_order = tmp;
        }
    };

    this.size = function() {
        var count = 0;
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                count++;
            }
        }
        return count;
    };

    this.unplaceVisual = function(visual) {
        var vid, vis;
        if (typeof visual === 'undefined') {
            throw new Error("Need a parameter.");
        } else if (typeof visual === 'string') {
            vid = visual;
            if (!me.visuals.hasOwnProperty(vid)) {
                return;
            }
            vis = me.visuals[vid];
        } else if (visual.constructor === Visual) {
            vid = visual.id;
            vis = visual;
        } else {
            throw new Error("Unknown parameter type.");
        }
        // If the visual is not contained in this container, then there is nothing to do.
        if (!me.visuals.hasOwnProperty(vid)) {
            return;
        }
        // Unplace the visual.
        delete me.visuals[vid];

        if (vis == me.selected) {
            me.selectVisual(null);
        }
    };

    /**
     *
     * @returns {{barn: *, id_count: number, visuals: *, z_top: number}}
     */
    this.toJSON = function() {
        var cpy = {};
        for (var i in me.visuals) {
            if (me.visuals.hasOwnProperty(i)) {
                cpy[i] = me.visuals[i].toJSON();
            }
        }

        return {
            version: VERSION_NUMBER,
            barn: copyOf(me.barn.toJSON()),
            id_count: me.id_count,
            visuals: copyOf(cpy),
            z_top: me.z_top
        };
    };


    if (isDefined(data)) {
        data = copyOf(data);
        me.pixels_per_foot = data.pixels_per_foot;
        me.barn = new Barn(me, data.barn);
        for (var i in data.visuals) {
            //noinspection JSUnresolvedFunction
            if (data.visuals.hasOwnProperty(i)) {
                me.visuals[i] = new Visual(me, data.visuals[i]);
            }
        }
        me.id_count = data.id_count;
        me.z_top = data.z_top;
    }

};
