var ComponentManager = function(form) {

    var manager = this;

      /////////////
     // Adding  //
    /////////////

    var addRadio = function(component) {
        var val = def(component.value, -1);
        var option = manager.getOption(component, val);
        if (option == null && component.options.length > 0) {
            component.value = component.options[0].id;
            return true;
        }
        return false;
    };

    var addCheck = function(component) {
        if (def(component.value, false)) return false;
        component.value = true;
        return true;
    };

    var addNumeric = function(component) {
        var max = def(component.max, Infinity);
        var num = def(component.value, 0);
        if (num < max) {
            component.value = num + 1;
            return true;
        }
        return false;
    };

    var addSelect = function(component) {
        if (!component.requires_quantity) return false;
        var max = def(component.max, Infinity);
        var num = def(component.quantity, 0);
        if (num < max) {
            component.quantity = num + 1;
            return true;
        }
        return false;
    };

    var addText = function(component) {
        return addSelect(component);
    };

    this.addComponent = function(component) {
        var f = component.form_type;
        var c = component;
        if (f.startsWith("check")) return addCheck(c);
        else if (f == 'radio') return addRadio(c);
        else if (f == 'numeric') return addNumeric(c);
        else if (f == 'select') return addSelect(c);
        else if (f == 'text') return addText(c);
    };

      //////////////
     // Removing //
    //////////////


    var delRadio = function(component) {
        component.value = component.options[component.options.length - 1];
    };

    var delCheck = function(component) {
        component.value = false;
    };

    var delNumeric = function(component) {
        var min = def(component.min, 0);
        var val = def(component.value, 0);
        if (val > min) component.value = val - 1;
    };

    var delSelect = function(component) {
        if (!component.requires_quantity) {
            component.value = '';
            return;
        }
        var min = def(component.min, 0);
        var num = def(component.quantity, 0);
        if (num > min) component.quantity = num - 1;
    };

    var delText = function(component) {
        delSelect(component);
    };

    this.removeComponent = function(component) {
        var f = component.form_type;
        var c = component;
        if (f.startsWith("check")) delCheck(c);
        else if (f == 'radio') delRadio(c);
        else if (f == 'numeric') delNumeric(c);
        else if (f == 'select') delSelect(c);
        else if (f == 'text') delText(c);
    };

      ///////////////////
     // Custom Fields //
    ///////////////////

    /**
     *  Adds a custom field text box right after the previous custom field.
     */
    this.addCustomField = function (components, component) {
        var num = components.length;
        if (num == 1) component.name = "Custom Field 1";
        var custom = {
            name: "Custom Field " + (num + 1),
            id: num,
            price: 0,
            form_type: component.form_type,
            requires_quantity: component.requires_quantity,
            value: '',
            duplicate: component.duplicate,
            image_url: component.image_url,
            show: component.show
        };
        components.push(custom);
    };

    /**
     *  Removes a custom field at a given index.
     */
    this.deleteCustomField = function (subsection, component) {
        var index = subsection.components.indexOf(component);
        if (index == -1) return;
        subsection.components.splice(index, 1);
        if (subsection.components.length == 1) {
            subsection.components[0].name = "Custom Field";
            return;
        }
        for (var i = 0; i < subsection.components.length; i++) {
            subsection.components[i].name = "Custom Field " + (i + 1);
        }
    };

      //////////////
     // Quantity //
    //////////////


    var qRadio = function(component) {
        var id = def(component.value, false);
        if (id === false) return 0;
        var o = manager.getOptionIndex(component, id);
        if (o == -1 || o == (component.options.length - 1)) return 0;
        return 1;
    };

    var qCheck = function(component) {
        var val = def(component.value, false);
        val = (val == null ? false : val);
        return (val === false) ? 0 : 1;
    };

    var qNumeric = function(component) {
        return def(component.value, 0);
    };

    var qSelect = function(component) {
        var ind = def(component.value, 0);
        if (!component.requires_quantity) return ind > 0 ? 1 : 0;
        return def(component.quantity, 0);
    };

    var qText = function(component) {
        var text = def(component.value, '');
        if (!component.requires_quantity) return text.length > 0;
        return def(component.quantity, 0);
    };

    this.getQuantity = function(component) {
        var f = component.form_type;
        var c = component;
        if (f.startsWith("check")) return qCheck(c);
        else if (f == 'radio') return qRadio(c);
        else if (f == 'numeric') return qNumeric(c);
        else if (f == 'select') return qSelect(c);
        else if (f == 'text') return qText(c);
    };

      /////////////////////////
     // Getting Information //
    /////////////////////////

    /**
     * Gets all of the components
     * @param [show_only = false] If set to true, will only add components that have show=true.
     * @returns {Array} The array of components.
     */
    this.getAllComponents = function(show_only) {
        var components = [];
        for (var ai in form.additions) {
            var section = form.additions[ai];
            for (var ssi in section.subsections) {
                var subsection = section.subsections[ssi];
                for (var ci in subsection.components) {
                    var component = subsection.components[ci];
                    if (show_only && !component.show) continue;
                    components.push(component);
                }
            }
        }
        return components;
    };

    /**
     * Gets a component by its id.
     * @param id The id to look for.
     * @returns {*} The component if found, or null if now.
     */
    this.getComponentById = function (id) {
        for (var addition_index in form.additions) {
            var addition = form.additions[addition_index];
            for (var subsection_index in addition.subsections) {
                var subsection = addition.subsections[subsection_index];
                for (var component_index in subsection.components) {
                    var component = subsection.components[component_index];
                    if (component.id == id) return component;
                }
            }
        }
        // No component with that id was found.
        return null;
    };


    /**
     * Gets the display image for a component. If no image is being displayed,
     * it will return no_image.
     */
    this.getDisplayImage = function(component) {
        // The radio option is the only one that has to be treated special here.
        // If it's not a radio, just check for the image url.
        if (!(component.form_type == 'radio'))
            return component.image_url ? component.image_url : null;

        // This shouldn't happen, but check to see if it has options if no value.
        if (!component.value && component.options.length == 0) return null;

        // Get the value and check if an option with that id exists.
        var val = parseInt(component.value + "");
        var option = false;
        for (var o in component.options) {
            if (component.options[o].id == val) {
                option = component.options[o];
                break;
            }
        }
        // If an option was found, and it has an image url, return it.
        if (option && option.image_url) return option.image_url;

        // Nothing was found.
        return null;
    };


    /**
     * Gets the display price for a component. If the component has options, must pass the option index as well.
     * @param component The component to get the price for.
     * @param [index] The option index.
     * @returns {string} The display price.
     */
    this.displayPrice = function (component, index) {
        // TODO figure out why empty arrays are getting turned into null.
        if (typeof component.options === 'undefined' || !component.options || component.options == null)
            component.options = [];

        var price = 0;

        if (component.options.length > 0) price = component.options[index].price;
        else price = component.price;

        if (price === 0) return '';

        var types = {
            'sq_ft': 'sq. ft.',
            'ln_ft': 'ln. ft.',
            'each': 'ea.',
            'percent': '%'
        };

        var formatted_currency = form.getMoneyString(price);

        if (types.hasOwnProperty(component.pricing_type))
            if (component.pricing_type === 'percent') return "[" + price + "%]";
            else return "[" + formatted_currency + " /" + types[component.pricing_type] + "]";

        return "[" + formatted_currency + "]";
    };

      /////////////
     // Options //
    /////////////

    this.getOptionIndex = function(component, id) {
        for (var i = 0; i < component.options.length; i++) if (component.options[i].id == id) return i;
        return -1;
    };

    this.getOption = function(component, id) {
        var index = manager.getOptionIndex(component, id);
        return index == -1 ? null : component.options[index];
    };

};