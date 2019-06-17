var ID_COUNT = 9000;

var Option = function(component, data) {

    data = def(data, {});

    //var option = this;

    var id          = def(data.id, ++ID_COUNT);
    var image_url   = def(data.image_url, null);
    var large_price = def(data.large_price, 0);
    var name        = def(data.name, "");
    var price       = def(data.price, 0);
    var show        = def(data.show, true);
    var small_price = def(data.small_price, 0);

    //region Getter/Setter/Property Change
    var on_id_change          = [];
    var on_image_url_change   = [];
    var on_large_price_change = [];
    var on_name_change        = [];
    var on_price_change       = [];
    var on_show_change        = [];
    var on_small_price_change = [];

    this.getId = function() {
        return id;
    };

    this.getImageUrl = function() {
        return image_url;
    };

    this.getLargePrice = function() {
        return large_price;
    };

    this.getName = function() {
        return name;
    };

    this.getPrice = function() {
        return price;
    };

    this.getShow = function() {
        return show;
    };

    this.getSmallPrice = function() {
        return small_price;
    };


    this.onIdChange = function (callback) {
        if (typeof callback === 'function') {
            on_id_change.push(callback);
        }
    };

    this.onImageUrlChange = function (callback) {
        if (typeof callback === 'function') {
            on_image_url_change.push(callback);
        }
    };

    this.onLargePriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_large_price_change.push(callback);
        }
    };

    this.onNameChange = function (callback) {
        if (typeof callback === 'function') {
            on_name_change.push(callback);
        }
    };

    this.onPriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_price_change.push(callback);
        }
    };

    this.onShowChange = function (callback) {
        if (typeof callback === 'function') {
            on_show_change.push(callback);
        }
    };

    this.onSmallPriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_small_price_change.push(callback);
        }
    };


    this.setId = function (newVal) {
        if (id != newVal) {
            for (var i = 0; i < on_id_change.length; i++) {
                var oldVal = id;
                id = newVal;
                on_id_change[i](oldVal, newVal);
            }
        }
    };

    this.setImageUrl = function (newVal) {
        if (image_url != newVal) {
            for (var i = 0; i < on_image_url_change.length; i++) {
                var oldVal = image_url;
                image_url = newVal;
                on_image_url_change[i](oldVal, newVal);
            }
        }
    };

    this.setLargePrice = function (newVal) {
        if (large_price != newVal) {
            for (var i = 0; i < on_large_price_change.length; i++) {
                var oldVal = large_price;
                large_price = newVal;
                on_large_price_change[i](oldVal, newVal);
            }
        }
    };

    this.setName = function (newVal) {
        if (name != newVal) {
            for (var i = 0; i < on_name_change.length; i++) {
                var oldVal = name;
                name = newVal;
                on_name_change[i](oldVal, newVal);
            }
        }
    };

    this.setPrice = function (newVal) {
        if (price != newVal) {
            for (var i = 0; i < on_price_change.length; i++) {
                var oldVal = price;
                price = newVal;
                on_price_change[i](oldVal, newVal);
            }
        }
    };

    this.setShow = function (newVal) {
        if (show != newVal) {
            for (var i = 0; i < on_show_change.length; i++) {
                var oldVal = show;
                show = newVal;
                on_show_change[i](oldVal, newVal);
            }
        }
    };

    this.setSmallPrice = function (newVal) {
        if (small_price != newVal) {
            for (var i = 0; i < on_small_price_change.length; i++) {
                var oldVal = small_price;
                small_price = newVal;
                on_small_price_change[i](oldVal, newVal);
            }
        }
    };
    //endregion

    /**
     * Gets the component this option belongs to.
     * @returns {Component}
     */
    this.getParentComponent = function() {
        return component;
    };

    this.toJSON = function() {
        return {
            id: id,
            image_url: image_url,
            large_price: large_price,
            name: name,
            price: price,
            show: show,
            small_price: small_price
        }
    };
    
};

/**
 *
 * @param {Subsection} subsection
 * @param data
 * @constructor
 */
var Component = function(subsection, data) {

    data = def(data, {});

    var component = this;

    /** @type {boolean} */
    var duplicate         = def(data.duplicate, false);
    /** @type {string} */
    var form_type         = def(data.form_type , '');
    /** @type {number} */
    var id                = def(data.id , ++ID_COUNT);
    /** @type {string|null} */
    var image_url         = def(data.image_url , null);
    /** @type {number} */
    var large_price       = def(data.large_price , 0);
    /** @type {string} */
    var name              = def(data.name , '');
    /** @type {Option[]} */
    var options           = def(data.options , []);
    /** @type {number} */
    var price             = def(data.price, 0);
    /** @type {string} */
    var pricing_type      = def(data.pricing_type, 'each');
    /** @type {number} */
    var quantity          = def(data.quantity, 0);
    /** @type {boolean} */
    var requires_quantity = def(data.requires_quantity, true);
    /** @type {boolean} */
    var show              = def(data.show, true);
    /** @type {number} */
    var small_price       = def(data.small_price, 0);
    /** @type {*} */
    var value             = def(data.value, null);

    for (var i = 0; i < options.length; i++) {
        var o = options[i];
        if (o.constructor !== Option) {
            options[i] = new Option(this, o);
        }
    }

    //region Getter/Setter/Property Change Support
    /** @type{function[]} */
    var on_duplicate_change         = [];
    /** @type{function[]} */
    var on_form_type_change         = [];
    /** @type{function[]} */
    var on_id_change                = [];
    /** @type{function[]} */
    var on_image_url_change         = [];
    /** @type{function[]} */
    var on_large_price_change       = [];
    /** @type{function[]} */
    var on_name_change              = [];
    /** @type{function[]} */
    var on_options_change           = [];
    /** @type{function[]} */
    var on_price_change             = [];
    /** @type{function[]} */
    var on_pricing_type_change      = [];
    /** @type{function[]} */
    var on_quantity_change          = [];
    /** @type{function[]} */
    var on_requires_quantity_change = [];
    /** @type{function[]} */
    var on_show_change              = [];
    /** @type{function[]} */
    var on_small_price_change       = [];
    /** @type{function[]} */
    var on_value_change             = [];

    /**
     * I have no idea what this field is for.
     * @returns {boolean}
     */
    this.getDuplicate = function() {
        return duplicate;
    };

    /**
     * Gets the form type.
     * @returns {string}
     */
    this.getFormType = function() {
        return form_type;
    };

    /**
     * Gets the id.
     * @returns {number}
     */
    this.getId = function() {
        return id;
    };

    /**
     * Gets the image url, or null if there isn't one.
     * @returns {string|null}
     */
    this.getImageUrl = function() {
        return image_url;
    };

    /**
     * Gets the large price?
     * @returns {number}
     */
    this.getLargePrice = function() {
        return large_price;
    };

    /**
     * Gets the name.
     * @returns {string}
     */
    this.getName = function() {
        return name;
    };

    /**
     * Gets the options.
     * @returns {Option[]}
     */
    this.getOptions = function() {
        return copyOf(options);
    };

    /**
     * Gets the price.
     * @returns {number}
     */
    this.getPrice = function() {
        return price;
    };

    /**
     * Gets the pricing type.
     * @returns {string}
     */
    this.getPricingType = function() {
        return pricing_type;
    };

    /**
     * Gets whether or not this requires a quantity. This field is unused?
     * @returns {boolean}
     */
    this.getRequiresQuantity = function() {
        return requires_quantity;
    };

    /**
     * Gets whether or not to show this field.
     * @returns {boolean}
     */
    this.getShow = function() {
        return show;
    };

    /**
     * Gets the small price?
     * @returns {number}
     */
    this.getSmallPrice = function() {
        return small_price;
    };

    /**
     * Gets the value??
     * @returns {number}
     */
    this.getValue = function() {
        return value;
    };


    /**
     * The callback function is called when duplicate is changed.
     * @param {function} callback
     */
    this.onDuplicateChange = function (callback) {
        if (typeof callback === 'function') {
            on_duplicate_change.push(callback);
        }
    };

    /**
     * The callback function is called when form type is changed.
     * @param {function} callback
     */
    this.onFormTypeChange = function (callback) {
        if (typeof callback === 'function') {
            on_form_type_change.push(callback);
        }
    };

    /**
     * The callback function is called when id is changed.
     * @param {function} callback
     */
    this.onIdChange = function (callback) {
        if (typeof callback === 'function') {
            on_id_change.push(callback);
        }
    };

    /**
     * The callback function is called when image url is changed.
     * @param {function} callback
     */
    this.onImageUrlChange = function (callback) {
        if (typeof callback === 'function') {
            on_image_url_change.push(callback);
        }
    };

    /**
     * The callback function is called when large price is changed.
     * @param {function} callback
     */
    this.onLargePriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_large_price_change.push(callback);
        }
    };

    /**
     * The callback function is called when name is changed.
     * @param {function} callback
     */
    this.onNameChange = function (callback) {
        if (typeof callback === 'function') {
            on_name_change.push(callback);
        }
    };

    /**
     * The callback function is called when the options are changed.
     * @param {function} callback
     */
    this.onOptionsChange = function (callback) {
        if (typeof callback === 'function') {
            on_options_change.push(callback);
        }
    };

    /**
     * The callback function is called when price is changed.
     * @param {function} callback
     */
    this.onPriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_price_change.push(callback);
        }
    };

    /**
     * The callback function is called when quantity is changed.
     * @param {function} callback
     */
    this.onQuantityChange = function(callback) {
        if (typeof callback === 'function') {
            on_quantity_change.push(callback);
        }
    };

    /**
     * The callback function is called when pricing type is changed.
     * @param {function} callback
     */
    this.onPricingTypeChange = function (callback) {
        if (typeof callback === 'function') {
            on_pricing_type_change.push(callback);
        }
    };

    /**
     * The callback function is called when requires quantity is changed.
     * @param {function} callback
     */
    this.onRequiresQuantityChange = function (callback) {
        if (typeof callback === 'function') {
            on_requires_quantity_change.push(callback);
        }
    };

    /**
     * The callback function is called when show is changed.
     * @param {function} callback
     */
    this.onShowChange = function (callback) {
        if (typeof callback === 'function') {
            on_show_change.push(callback);
        }
    };

    /**
     * The callback function is called when small price is changed.
     * @param {function} callback
     */
    this.onSmallPriceChange = function (callback) {
        if (typeof callback === 'function') {
            on_small_price_change.push(callback);
        }
    };

    /**
     * The callback function is called when value is changed.
     * @param {function} callback
     */
    this.onValueChange = function (callback) {
        if (typeof callback === 'function') {
            on_value_change.push(callback);
        }
    };

    /**
     * Sets duplicate to a new value.
     * @param {boolean} newVal
     */
    this.setDuplicate = function (newVal) {
        if (duplicate != newVal) {
            var oldVal = duplicate;
            duplicate = newVal;
            for (var i = 0; i < on_duplicate_change.length; i++) {
                on_duplicate_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets form type to a new value.
     * @param {string} newVal
     */
    this.setFormType = function (newVal) {
        if (form_type != newVal) {
            var oldVal = form_type;
            form_type = newVal;
            for (var i = 0; i < on_form_type_change.length; i++) {
                on_form_type_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets id to a new value.
     * @param {number} newVal
     */
    this.setId = function (newVal) {
        if (id != newVal) {
            var oldVal = id;
            id = newVal;
            for (var i = 0; i < on_id_change.length; i++) {
                on_id_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets image url to a new value.
     * @param {string|null} newVal
     */
    this.setImageUrl = function (newVal) {
        if (image_url != newVal) {
            var oldVal = image_url;
            image_url = newVal;
            for (var i = 0; i < on_image_url_change.length; i++) {
                on_image_url_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets large price to a new value.
     * @param {number} newVal
     */
    this.setLargePrice = function (newVal) {
        if (large_price != newVal) {
            var oldVal = large_price;
            large_price = newVal;
            for (var i = 0; i < on_large_price_change.length; i++) {
                on_large_price_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets name to a new value.
     * @param {string} newVal
     */
    this.setName = function (newVal) {
        if (name != newVal) {
            var oldVal = name;
            name = newVal;
            for (var i = 0; i < on_name_change.length; i++) {
                on_name_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets options to a new value.
     * @param {Option[]} newVal
     */
    this.setOptions = function (newVal) {
        var oldVal = copyOf(options);
        options = newVal;
        var i;
        for (i = 0; i < options.length; i++) {
            if (options[i].constructor !== Option) {
                options[i] = new Option(component, options[i]);
            }
        }
        for (i = 0; i < on_options_change.length; i++) {
            on_options_change[i](oldVal, newVal);
        }
    };

    /**
     * Sets price to a new value.
     * @param {number} newVal
     */
    this.setPrice = function (newVal) {
        if (price != newVal) {
            var oldVal = price;
            price = newVal;
            for (var i = 0; i < on_price_change.length; i++) {
                on_price_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets pricing type to a new value.
     * @param {string} newVal
     */
    this.setPricingType = function (newVal) {
        if (pricing_type != newVal) {
            var oldVal = pricing_type;
            pricing_type = newVal;
            for (var i = 0; i < on_pricing_type_change.length; i++) {
                on_pricing_type_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets requires quantity to a new value.
     * @param {boolean} newVal
     */
    this.setRequiresQuantity = function (newVal) {
        if (requires_quantity != newVal) {
            var oldVal = requires_quantity;
            requires_quantity = newVal;
            for (var i = 0; i < on_requires_quantity_change.length; i++) {
                on_requires_quantity_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets show to a new value.
     * @param {boolean} newVal
     */
    this.setShow = function (newVal) {
        if (show != newVal) {
            var oldVal = show;
            show = newVal;
            for (var i = 0; i < on_show_change.length; i++) {
                on_show_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets small price to a new value.
     * @param {number} newVal
     */
    this.setSmallPrice = function (newVal) {
        if (small_price != newVal) {
            var oldVal = small_price;
            small_price = newVal;
            for (var i = 0; i < on_small_price_change.length; i++) {
                on_small_price_change[i](oldVal, newVal)
            }
        }
    };

    /**
     * Sets value to a new value.
     * @param {*} newVal
     */
    this.setValue = function (newVal) {
        if (value != newVal) {
            var oldVal = value;
            value = newVal;
            for (var i = 0; i < on_value_change.length; i++) {
                on_value_change[i](oldVal, newVal)
            }
        }
    };

    //endregion

    //region Quantity Support



    /**
     * Gets an option by its id.
     * @param {number} id The id to look for.
     * @returns {Option|null}
     */
    this.getOptionById = function(id) {
        for (var i = 0; i < options.length; i++) {
            if (options[i].getId() == id) {
                return options[i];
            }
        }
        return null;
    };

    /**
     * Gets an option by its index.
     * @param {number} index The index.
     * @returns {Option|null} The option, or null if index is out of bounds.
     */
    this.getOptionByIndex = function(index) {
        if (index < 0 || index > options.length) {
            return null;
        }
        return options[index];
    };

    /**
     * Gets the index of an option given its id.
     * @param {number} id The id to search for.
     * @returns {number} The index, or -1 if not found.
     */
    this.getOptionIndexById = function(id) {
        for (var i = 0; i < options.length; i++) {
            if (options[i].getId() == id) {
                return i;
            }
        }
        return -1;
    };

    /**
     *
     * @returns {Option|null}
     */
    this.getSelectedOption = function() {
        return component.getOptionByIndex(def(value, -1));
    };

    /**
     *
     * @param {Option|number} option
     */
    this.setSelectedOption = function(option) {
        if (typeof option === 'number') {
            var o = component.getOptionById(option);
            if (o == null) {
                o = component.getOptionByIndex(option);
            }
            if (o != null) {
                component.setValue(option.getId());
            }
        } else if (option.constructor === Option) {
            if (option.getParentComponent() === component) {
                component.setValue(option.getId());
            }
        }
    };

    var qRadio = function() {
        var id = def(value, null);
        if (id === null) {
            return 0;
        }
        var o = component.getOptionById(id);
        // The last option is used to indicate none.
        if (o == -1 || o == (options.length - 1)) {
            return 0;
        }
        return 1;
    };

    var qCheck = function() {
        var val = def(value, false);
        val = (val == null ? false : val);
        return (val === false) ? 0 : 1;
    };

    var qNumeric = function() {
        return def(value, 0);
    };

    var qSelect = function() {
        var ind = def(value, 0);
        if (ind == null) ind = 0;
        if (!requires_quantity) {
            return ind > 0 ? 1 : 0;
        }
        var q = def(quantity, 0);
        if (q == null) q = 0;
        return q;
    };

    var qText = function() {
        var text = def(value, '');
        if (text == null) {
            text = '';
        }
        if (!requires_quantity) {
            return text.length > 0;
        }
        return def(quantity, 0);
    };

    this.getQuantity = function() {
        var f = form_type;
        var q = 0;
        if (f.startsWith("check")) q = qCheck();
        else if (f == 'radio') q = qRadio();
        else if (f == 'numeric') q = qNumeric();
        else if (f == 'select') q = qSelect();
        else if (f == 'text') q = qText();
        if (q == null || typeof q === 'undefined') q = 0;
        return q;
    };

    this.canIncreaseQuantity = function() {
        var f = form_type;
        if (f.startsWith("check")) {
            return !qCheck();
        } else if (f == 'radio') {
            return !qRadio();
        } else if (f == 'numeric') {
            return true;
        } else if (f == 'select') {
            if (requires_quantity) {
                return true;
            }
            return !qSelect();
        } else if (f == 'text') {
            if (requires_quantity) {
                return true;
            }
            return !qText();
        }
        return false;
    };

    this.canDecreaseQuantity = function() {
        return component.getQuantity() > 0;
    };


    var quantityChanged = function(oldVal, newVal) {
        for (var i = 0; i < on_quantity_change.length; i++) {
            on_quantity_change[i](oldVal, newVal);
        }
    };

    this.incrementQuantity = function() {
        var f = form_type;
        if (!component.canIncreaseQuantity()) {
            return false;
        }
        var oldVal = component.getQuantity();
        if (f.startsWith("check")) {
            component.setValue(true);
        } else if (f == 'radio') {
            if (oldVal > 0) {
                return false;
            }
            if (options.length == 0) {
                return false;
            }
            component.setValue(0);
        } else if (f == 'numeric') {
            value = def(value, 0);
            value = +value;
            component.setValue(value + 1);
        } else if (f == 'select') {
            if (requires_quantity) {
                quantity = def(quantity, 0);
                quantity = +quantity;
                quantity++;
            } else {
                if (oldVal > 0) {
                    return false;
                }
                if (options.length == 0) {
                    return false;
                }
                component.setValue(0);
            }
        } else if (f == 'text') {
            if (requires_quantity) {
                quantity = def(quantity, 0);
                quantity = +quantity;
                quantity++;
            }
        }
        var newVal = component.getQuantity();
        if (oldVal != newVal) {
            quantityChanged(oldVal, newVal);
        }
    };

    this.decrementQuantity = function() {
        var f = form_type;
        var oldVal = component.getQuantity();
        if (oldVal == 0) {
            return false;
        }
        if (f.startsWith("check")) {
            component.setValue(false);
        } else if (f == 'radio') {
            component.setValue(options.length - 1);
        } else if (f == 'numeric') {
            value = def(value, 0);
            value = +value;
            component.setValue(value - 1);
        } else if (f == 'select') {
            if (requires_quantity) {
                quantity = def(quantity, 0);
                quantity = +quantity;
                quantity--;
                if (quantity < 0) {
                    quantity = 0;
                }
            } else {
                component.setValue(options.length - 1);
            }
        } else if (f == 'text') {
            if (requires_quantity) {
                quantity = def(quantity, 0);
                quantity = +quantity;
                quantity--;
                if (quantity < 0) {
                    quantity = 0;
                }
            }
        }
        var newVal = component.getQuantity();
        if (oldVal != newVal) {
            quantityChanged(oldVal, newVal);
        }
    };
    //endregion

    /**
     * Gets the display price for this component.
     * @returns {string}
     */
    this.getDisplayPrice = function() {

        var price = 0;

        var opt = component.getSelectedOption();
        if (opt != null) {
            price = opt.getPrice();
        } else {
            price = component.getPrice();
        }
        price = +price;

        if (price == 0) {
            return '';
        } else {

            var types = {
                'sq_ft': 'sq. ft.',
                'ln_ft': 'ln. ft.',
                'each': 'ea.',
                'percent': '%'
            };

            if (types.hasOwnProperty(component.getPricingType())) {
                if (component.getPricingType() == "percent") {
                    return "[" + price + "%]";
                } else {
                    return "[" + price.toMoneyString() + " /" + types[component.getPricingType()] + "]";
                }
            } else {
                return "[" + price.toMoneyString() + "]";
            }

        }
    };

    /**
     * Gets the subsection this component is held in.
     * @returns {Subsection}
     */
    this.getParentSubsection = function() {
        return subsection;
    };

    /**
     *
     * @param {Component} comp
     * @returns {boolean}
     */
    this.equals = function(comp) {
        if (!comp || comp.constructor !== Component) {
            return false;
        }
        return (this === comp) || (id == comp.getId() && name == comp.getName() && subsection.getName() == comp.getParentSubsection().getName());
    };

    this.toJSON = function() {
        return {
            form_type: form_type,
            id: id,
            image_url: image_url,
            large_price: large_price,
            name: name,
            options: options,
            price: price,
            pricing_type: pricing_type,
            requires_quantity: requires_quantity,
            show: show,
            small_price: small_price,
            value: value
        }
    };

};

var Subsection = function(addition, data) {

    data = def(data, {});

    /** @type {Subsection} */
    var subsection = this;

    /** @type {Component[]} */
    var components = def(data.components, []);
    /** @type {string} */
    var name = def(data.name, '');
    /** @type {boolean} */
    var show = def(data.show, true);
    /** @type {boolean} */
    var subcategory_show = def(data.subcategory_show, true);

    var checkComponents = function() {
        for (var i = 0; i < components.length; i++) {
            var c = components[i];
            if (c.constructor !== Component) {
                c = new Component(this, c);
                components[i] = c;
            }
        }
    };

    checkComponents();

    // TODO setter, on custom add support.

    //region Getter/Setter/Change Support

    var on_components_change = [];
    var on_name_change = [];
    var on_show_change = [];
    var on_subcategory_show_change = [];

    /**
     * Gets the components.
     * @param {function(Component)} filter
     * @returns {Component[]}
     */
    this.getComponents = function(filter) {
        if (typeof filter !== 'function') {
            filter = function() { return true; }
        }
        var ret = [];
        for (var i = 0; i < components.length; i++) {
            if (filter(components[i])) {
                ret.push(components[i]);
            }
        }
        return ret;
    };

    /**
     * Gets the name.
     * @returns {string}
     */
    this.getName = function() {
        return name;
    };

    /**
     * Gets show.
     * @returns {boolean}
     */
    this.getShow = function() {
        return show;
    };

    /**
     * Gets subcategory show.
     * @returns {boolean}
     */
    this.getSubcategoryShow = function() {
        return subcategory_show;
    };

    this.onComponentsChange = function (callback) {
        if (typeof callback === 'function') {
            on_components_change.push(callback);
        }
    };

    this.onNameChange = function (callback) {
        if (typeof callback === 'function') {
            on_name_change.push(callback);
        }
    };


    this.onShowChange = function (callback) {
        if (typeof callback === 'function') {
            on_show_change.push(callback);
        }
    };

    this.onSubcategoryShowChange = function (callback) {
        if (typeof callback === 'function') {
            on_subcategory_show_change.push(callback);
        }
    };


    //endregion

    /**
     *
     * @param {Component} comp
     * @return {number} index, or -1 if not found.
     */
    this.indexOfComponent = function(comp) {
        for (var i = 0; i < components.length; i++) {
            if (components[i].equals(comp)) {
                return i;
            }
        }
        return -1;
    };

    var customNameRegex = /^(.*?)(\s*)(\d*)$/;

    /**
     *
     * @param {Component} [comp]
     */
    this.addCustomField = function(comp) {
        if (comp && comp.constructor === Component) {
            var index = subsection.indexOfComponent(comp);
            var append = index == -1;
            var base = customNameRegex.exec(comp.getName())[1];
            var sharedBases = subsection.getComponents(function(c) {
                return c.getName().startsWith(base);
            });


        } else {
            var customs = subsection.getComponents(function(comp) {
                return comp.getFormType() == "text";
            });
            var custom = {
                name: "Custom Field",
                id: ++ID_COUNT,
                price: 0,
                form_type: "text",
                requires_quantity: true,
                value: '',
                duplicate: false,
                image_url: null,
                show: true
            };
            if (customs.length > 0) {
                for (var i = 0; i < customs.length; i++) {
                    customs[i].setName("Custom Field " + (i + 1));
                }
                custom.name += " " + (customs.length + 1);
            }
            checkComponents();
        }
    };

    /**
     *
     * @returns {Addition}
     */
    this.getParentAddition = function() {
        return addition;
    };

    /**
     *
     * @returns {{components: Component[], name: string, show: boolean, subcategory_show: boolean}}
     */
    this.toJSON = function() {
        return {
            components: components,
            name: name,
            show: show,
            subcategory_show: subcategory_show
        }
    }

};

var Addition = function(manager, data) {

    data = def(data, {});

    var addition = this;
    /** @type {string} */
    var name = def(data.name, '');
    /** @type {Subsection[]} */
    var subsections = def(data.subsections, []);

    for (var i = 0; i < subsections.length; i++) {
        var s = subsections[i];
        if (s.constructor !== Subsection) {
            s = new Subsection(this, s);
            subsections[i] = s;
        }
    }

    /**
     *
     * @returns {Subsection[]}
     */
    this.getSubsections = function() {
        var ret = [];
        for (var i = 0; i < subsections.length; i++) {
            ret.push(subsections[i]);
        }
        return ret;
    };

    this.setName = function(newVal) {
        name = newVal;
    };

    this.setSubsections = function(newVal) {
        subsections = newVal;
        for (var i = 0; i < subsections.length; i++) {
            if (subsections[i].constructor !== Subsection) {
                subsections[i] = new Subsection(addition, subsections[i]);
            }
        }
    };

    /**
     *
     * @returns {ComponentManager}
     */
    this.getParentManager = function() {
        return manager;
    };

    this.toJSON = function() {
        return {
            name: name,
            subsections: subsections
        }
    }

};

var ComponentManager = function(data) {


    /** @type {Option[]} */
    var options = [];
    /** @type {Component[]} */
    var components = [];
    /** @type{Subsection[]} */
    var subsections = [];

    /** @type {Addition[]} */
    var additions = def(data.additions, []);

    var comp_ids = {};

    for (var i = 0; i < additions.length; i++) {
        if (additions[i].constructor !== Addition) {
            additions[i] = new Addition(this, additions[i]);
        }
    }

    var comp_change = [];

    this.onComponentChange = function(callback) {
        if (typeof callback === 'function') {
            comp_change.push(callback);
        }
    };

    var on_comp_callback = function(comp, field, oldValue, newValue) {
        for (var i = 0; i < comp_change.length; i++) {
            comp_change[i](comp, field, oldValue, newValue);
        }
    };

    var comp_callback = function(comp, field) {
        return function(oldVal, newVal) {
            on_comp_callback(comp, field, oldVal, newVal);
        }
    };

    /**
     *
     * @param {Component} comp
     */
    var pushCompId = function(comp) {
        var id = "id_" + comp.getId();
        if (comp_ids.hasOwnProperty(id)) {
            if (isArray(comp_ids[id])) {
                var contains = false;
                for (var i = 0; i < comp_ids[id].length; i++) {
                    if (comp_ids[id][i].getId() == comp.getId()) {
                        contains = true;
                        break;
                    }
                }
                if (!contains) {
                    comp_ids[id].push(comp);
                }
            } else {
                var c_tmp = comp_ids[id];
                comp_ids[id] = [];
                comp_ids[id].push(c_tmp);
            }
        } else {
            comp_ids[id] = comp;
        }
    };

    var loadArrays = function() {
        options = [];
        components = [];
        subsections = [];
        for (var ai = 0; ai < additions.length; ai++) {
            var a = additions[ai];
            var subs = a.getSubsections();
            for (var si = 0; si < subs.length; si++) {
                var sub = subs[si];
                subsections.push(sub);
                var comps = sub.getComponents();
                for (var ci = 0; ci < comps.length; ci++) {
                    var comp = comps[ci];
                    components.push(comp);
                    pushCompId(comp);
                    // Set up events for component changes.
                    comp.onDuplicateChange(comp_callback(comp, "duplicate"));
                    comp.onFormTypeChange(comp_callback(comp, "form_type"));
                    comp.onIdChange(comp_callback(comp, "id"));
                    comp.onImageUrlChange(comp_callback(comp, "image_url"));
                    comp.onLargePriceChange(comp_callback(comp, "large_price"));
                    comp.onNameChange(comp_callback(comp, "name"));
                    comp.onOptionsChange(comp_callback(comp, "options"));
                    comp.onPriceChange(comp_callback(comp, "price"));
                    comp.onPricingTypeChange(comp_callback(comp, "pricing_type"));
                    comp.onQuantityChange(comp_callback(comp, "quantity"));
                    comp.onRequiresQuantityChange(comp_callback(comp, "requires_quantity"));
                    comp.onShowChange(comp_callback(comp, "show"));
                    comp.onSmallPriceChange(comp_callback(comp, "small_price"));
                    comp.onValueChange(comp_callback(comp, "value"));
                    var opts = comp.getOptions();
                    for (var oi = 0; oi < opts.length; oi++) {
                        var op = opts[oi];
                        options.push(op);
                    }
                }

            }
        }
    };

    loadArrays();


    this.getAllAdditions = function(filter) {
        var ret = [];
        if (typeof filter !== 'function') {
            filter = function() { return true; }
        }
        for (var i = 0; i < additions.length; i++) {
            if (filter(additions[i])) {
                ret.push(additions[i]);
            }
        }
        return ret;
    };

    this.getAllSubsections = function(filter) {
        var ret = [];
        if (typeof filter !== 'function') {
            filter = function() { return true; }
        }
        for (var i = 0; i < subsections.length; i++) {
            if (filter(subsections[i])) {
                ret.push(subsections[i]);
            }
        }
        return ret;
    };

    this.getAllComponents = function(filter) {
        var ret = [];
        if (typeof filter !== 'function') {
            filter = function() { return true; }
        }
        for (var i = 0; i < components.length; i++) {
            if (filter(components[i])) {
                ret.push(components[i]);
            }
        }
        return ret;
    };

    this.getAllComponentsById = function(filter) {
        var ret = {};
        if (typeof filter !== 'function') {
            filter = function() { return true; }
        }
        for (var ci in comp_ids) {
            if (comp_ids.hasOwnProperty(ci)) {
                if (filter(comp_ids[ci])) {
                    ret[ci] = comp_ids[ci];
                }
            }
        }
        return ret;
    };

    this.getComponentById = function(id) {
        if (comp_ids.hasOwnProperty("id_" + id)) {
            return comp_ids["id_" + id];
        }
        return null;
    };

    this.allOptions = function(filter) {
        var ret = [];
        if (typeof filter !== 'function') {
            filter = function () {
                return true;
            }
        }
        for (var i = 0; i < options.length; i++) {
            if (filter(options[i])) {
                ret.push(options[i]);
            }
        }
        return ret;
    }



};


var test = {
    "version": 2,
    "options": {
        "style": "Cottage",
        "size": {"width": 8, "len": 10, "sq_feet": 80, "ln_feet": 36},
        "feature": "Deluxe",
        "zone": 2,
        "build_type": "AOS",
        "finish": "",
        "orientation": "",
        "side_out": "",
        "prebuilt_available": false
    },
    "additions": [{
        "name": "Structural",
        "subsections": [{
            "name": "Structural",
            "subcategory_show": true,
            "components": [{
                "name": "Higher Sidewall for Wooden Buildings",
                "id": 755,
                "price": 4.5,
                "large_price": 4.8,
                "small_price": 4.5,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:464"
            }, {
                "name": "Higher Sidewall for Vinyl Buildings",
                "id": 756,
                "price": 5.75,
                "large_price": 6,
                "small_price": 5.75,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:465"
            }, {
                "name": "16 OC",
                "id": 757,
                "price": 3,
                "large_price": 3,
                "small_price": 3,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "percent",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:466"
            }, {
                "name": "Roof Pitch",
                "id": 758,
                "price": 0.85,
                "large_price": 0.8,
                "small_price": 0.85,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "max": 12,
                "min": 5,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:467"
            }, {
                "name": "Runner Upgrade",
                "id": 759,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "check_price",
                "requires_quantity": true,
                "pricing_type": "len",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:468"
            }, {
                "name": "4x4 Runner",
                "id": 760,
                "price": 2,
                "large_price": 2,
                "small_price": 2,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "len",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:469"
            }, {
                "name": "4x6 Runner",
                "id": 761,
                "price": 3.2,
                "large_price": 3.2,
                "small_price": 3.2,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "len",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:470"
            }],
            "show": true,
            "$$hashKey": "object:459"
        }, {
            "name": " Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 762,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:493",
                "quantity": 1
            }],
            "show": true,
            "$$hashKey": "object:460"
        }],
        "$$hashKey": "object:48"
    }, {
        "name": "Doors",
        "subsections": [{
            "name": "Default Doors",
            "subcategory_show": true,
            "components": [{
                "name": "Default Door",
                "id": 763,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "36\" 9-lite Steel Entry Door",
                    "id": 1227,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1227.png",
                    "show": true
                }, {
                    "name": "No Door",
                    "id": 1228,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/763.png",
                "show": false,
                "$$hashKey": "object:119"
            }, {
                "name": "Double Door Set",
                "id": 764,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "4'",
                    "id": 1229,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1229.png",
                    "show": true,
                    "$$hashKey": "object:127"
                }, {
                    "name": "5'",
                    "id": 1230,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1230.png",
                    "show": true,
                    "$$hashKey": "object:128"
                }, {
                    "name": "6'",
                    "id": 1231,
                    "price": 70,
                    "large_price": 75,
                    "small_price": 70,
                    "image_url": "/image_editor/component_option/1231.png",
                    "show": true,
                    "$$hashKey": "object:129"
                }, {
                    "name": "7'",
                    "id": 1232,
                    "price": 70,
                    "large_price": 75,
                    "small_price": 70,
                    "image_url": "/image_editor/component_option/1232.png",
                    "show": true,
                    "$$hashKey": "object:130"
                }, {
                    "name": "No Door",
                    "id": 1233,
                    "price": -170,
                    "large_price": -175,
                    "small_price": -170,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:131"
                }],
                "value": 1229,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:120"
            }, {
                "name": "Man Door",
                "id": 765,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "30\"",
                    "id": 1234,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1234.png",
                    "show": true,
                    "$$hashKey": "object:139"
                }, {
                    "name": "36\"",
                    "id": 1235,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1235.png",
                    "show": true,
                    "$$hashKey": "object:140"
                }, {
                    "name": "No Door",
                    "id": 1236,
                    "price": -90,
                    "large_price": -95,
                    "small_price": -90,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:141"
                }],
                "value": 1234,
                "image_url": "image_editor/component/765.png",
                "show": true,
                "$$hashKey": "object:121"
            }],
            "show": true,
            "$$hashKey": "object:104"
        }, {
            "name": "Extra Doors",
            "subcategory_show": true,
            "components": [{
                "name": "30\"",
                "id": 766,
                "price": 90,
                "large_price": 90,
                "small_price": 90,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/766.png",
                "show": true,
                "$$hashKey": "object:146"
            }, {
                "name": "36\"",
                "id": 767,
                "price": 90,
                "large_price": 90,
                "small_price": 90,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/767.png",
                "show": true,
                "$$hashKey": "object:147"
            }, {
                "name": "4'",
                "id": 768,
                "price": 170,
                "large_price": 170,
                "small_price": 170,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/768.png",
                "show": true,
                "$$hashKey": "object:148"
            }, {
                "name": "5'",
                "id": 769,
                "price": 170,
                "large_price": 170,
                "small_price": 170,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/769.png",
                "show": true,
                "$$hashKey": "object:149"
            }, {
                "name": "6'",
                "id": 770,
                "price": 240,
                "large_price": 240,
                "small_price": 240,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/770.png",
                "show": true,
                "$$hashKey": "object:150"
            }, {
                "name": "7'",
                "id": 771,
                "price": 240,
                "large_price": 240,
                "small_price": 240,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/771.png",
                "show": true,
                "$$hashKey": "object:151"
            }, {
                "name": "10'W x 7'H Sliding Wooden Door",
                "id": 772,
                "price": 0,
                "large_price": 695,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/772.png",
                "show": false,
                "$$hashKey": "object:152"
            }, {
                "name": "10'w x 7'H Sliding Wooden Door with Transom",
                "id": 773,
                "price": 0,
                "large_price": 940,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/773.png",
                "show": false,
                "$$hashKey": "object:153"
            }, {
                "name": "90\" Triple Door System",
                "id": 774,
                "price": 635,
                "large_price": 655,
                "small_price": 635,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/774.png",
                "show": true,
                "$$hashKey": "object:154"
            }, {
                "name": "108\" Triple Door System",
                "id": 775,
                "price": 710,
                "large_price": 730,
                "small_price": 710,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/775.png",
                "show": true,
                "$$hashKey": "object:155"
            }],
            "show": true,
            "$$hashKey": "object:105"
        }, {
            "name": "Steel Entry Door",
            "subcategory_show": true,
            "components": [{
                "name": "36\" 6-Panel Steel Entry Door",
                "id": 776,
                "price": 360,
                "large_price": 360,
                "small_price": 360,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/776.png",
                "show": true,
                "$$hashKey": "object:183"
            }, {
                "name": "36\" 9-lite Steel Entry Door",
                "id": 777,
                "price": 415,
                "large_price": 415,
                "small_price": 415,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/777.png",
                "show": true,
                "$$hashKey": "object:184"
            }, {
                "name": "36\" 15-lite Steel Entry Door",
                "id": 778,
                "price": 620,
                "large_price": 620,
                "small_price": 620,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/778.png",
                "show": true,
                "$$hashKey": "object:185"
            }, {
                "name": "36\" 6-lite Steel Entry Door w/ Dentil Shelf",
                "id": 779,
                "price": 805,
                "large_price": 805,
                "small_price": 805,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:186"
            }, {
                "name": "72\" 6-panel Steel Entry Door",
                "id": 780,
                "price": 740,
                "large_price": 740,
                "small_price": 740,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:187"
            }, {
                "name": "72\" 9-lite Steel Entry Door",
                "id": 781,
                "price": 995,
                "large_price": 995,
                "small_price": 995,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:188"
            }, {
                "name": "72\" 15-lite Steel Entry Door",
                "id": 782,
                "price": 1150,
                "large_price": 1150,
                "small_price": 1150,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:189"
            }],
            "show": true,
            "$$hashKey": "object:106"
        }, {
            "name": "Door Add-Ons",
            "subcategory_show": true,
            "components": [{
                "name": "Dead Bolt",
                "id": 783,
                "price": 45,
                "large_price": 45,
                "small_price": 45,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:582"
            }, {
                "name": "Cane Bolt",
                "id": 784,
                "price": 20,
                "large_price": 20,
                "small_price": 20,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:583"
            }, {
                "name": "Ramp",
                "id": 907,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "3' Depth Ramp",
                    "id": 1473,
                    "price": 75,
                    "large_price": 75,
                    "small_price": 75,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "4' Depth Ramp",
                    "id": 1474,
                    "price": 100,
                    "large_price": 100,
                    "small_price": 100,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "5' Depth Ramp",
                    "id": 1475,
                    "price": 125,
                    "large_price": 125,
                    "small_price": 125,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:584"
            }],
            "show": true,
            "$$hashKey": "object:107"
        }, {
            "name": "Overhead Door",
            "subcategory_show": true,
            "components": [{
                "name": "8'W x 7'H Overhead Door",
                "id": 785,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "8'W x 7'H Overhead Door - Non-Insulated",
                    "id": 1237,
                    "price": 825,
                    "large_price": 825,
                    "small_price": 825,
                    "image_url": "/image_editor/component_option/1237.png",
                    "show": true
                }, {
                    "name": "8'W x 7'H Overhead Door - Economy Insulated",
                    "id": 1238,
                    "price": 930,
                    "large_price": 930,
                    "small_price": 930,
                    "image_url": "/image_editor/component_option/1238.png",
                    "show": true
                }, {
                    "name": "8'W x 7'H Overhead Door - Standard Insulated",
                    "id": 1239,
                    "price": 1120,
                    "large_price": 1120,
                    "small_price": 1120,
                    "image_url": "/image_editor/component_option/1239.png",
                    "show": true
                }, {
                    "name": "8'W x 7'H Overhead Door - Carriage House Style",
                    "id": 1240,
                    "price": 1685,
                    "large_price": 1685,
                    "small_price": 1685,
                    "image_url": "/image_editor/component_option/1240.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/785.png",
                "show": true,
                "$$hashKey": "object:208"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 786,
                "price": 240,
                "large_price": 240,
                "small_price": 240,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:209"
            }, {
                "name": "9'W x 7'H Overhead Door",
                "id": 787,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "9'W x 7'H Overhead Door - Non-Insulated",
                    "id": 1241,
                    "price": 855,
                    "large_price": 855,
                    "small_price": 855,
                    "image_url": "/image_editor/component_option/1241.png",
                    "show": true
                }, {
                    "name": "9'W x 7'H Overhead Door - Economy Insulated",
                    "id": 1242,
                    "price": 990,
                    "large_price": 990,
                    "small_price": 990,
                    "image_url": "/image_editor/component_option/1242.png",
                    "show": true
                }, {
                    "name": "9'W x 7'H Overhead Door - Standard Insulated",
                    "id": 1243,
                    "price": 1205,
                    "large_price": 1205,
                    "small_price": 1205,
                    "image_url": "/image_editor/component_option/1243.png",
                    "show": true
                }, {
                    "name": "9'W x 7'H Overhead Door - Carriage House Style",
                    "id": 1244,
                    "price": 1770,
                    "large_price": 1770,
                    "small_price": 1770,
                    "image_url": "/image_editor/component_option/1244.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/787.png",
                "show": true,
                "$$hashKey": "object:210"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 788,
                "price": 240,
                "large_price": 240,
                "small_price": 240,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:211"
            }, {
                "name": "9'W x 8'H Overhead Door",
                "id": 789,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "9'W x 8'H Overhead Door - Non-Insulated",
                    "id": 1245,
                    "price": 955,
                    "large_price": 955,
                    "small_price": 955,
                    "image_url": "/image_editor/component_option/1245.png",
                    "show": true
                }, {
                    "name": "9'W x 8'H Overhead Door - Economy Insulated",
                    "id": 1246,
                    "price": 1120,
                    "large_price": 1120,
                    "small_price": 1120,
                    "image_url": "/image_editor/component_option/1246.png",
                    "show": true
                }, {
                    "name": "9'W x 8'H Overhead Door - Standard Insulated",
                    "id": 1247,
                    "price": 1295,
                    "large_price": 1295,
                    "small_price": 1295,
                    "image_url": "/image_editor/component_option/1247.png",
                    "show": true
                }, {
                    "name": "9'W x 8'H Overhead Door - Carriage House Style",
                    "id": 1248,
                    "price": 1870,
                    "large_price": 1870,
                    "small_price": 1870,
                    "image_url": "/image_editor/component_option/1248.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/789.png",
                "show": true,
                "$$hashKey": "object:212"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 790,
                "price": 240,
                "large_price": 240,
                "small_price": 240,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:213"
            }, {
                "name": "10'W x 7'H Overhead Door",
                "id": 791,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "10'W x 7'H Overhead Door - Non-Insulated",
                    "id": 1249,
                    "price": 985,
                    "large_price": 985,
                    "small_price": 985,
                    "image_url": "/image_editor/component_option/1249.png",
                    "show": true
                }, {
                    "name": "10'W x 7'H Overhead Door - Economy Insulated",
                    "id": 1250,
                    "price": 1110,
                    "large_price": 1110,
                    "small_price": 1110,
                    "image_url": "/image_editor/component_option/1250.png",
                    "show": true
                }, {
                    "name": "10'W x 7'H Overhead Door - Standard Insulated",
                    "id": 1251,
                    "price": 1290,
                    "large_price": 1290,
                    "small_price": 1290,
                    "image_url": "/image_editor/component_option/1251.png",
                    "show": true
                }, {
                    "name": "10'W x 7'H Overhead Door - Carriage House Style",
                    "id": 1252,
                    "price": 1860,
                    "large_price": 1860,
                    "small_price": 1860,
                    "image_url": "/image_editor/component_option/1252.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/791.png",
                "show": true,
                "$$hashKey": "object:214"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 792,
                "price": 295,
                "large_price": 295,
                "small_price": 295,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:215"
            }, {
                "name": "10'W x 8'H Overhead Door",
                "id": 793,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "10'W x 8'H Overhead Door - Non-Insulated",
                    "id": 1253,
                    "price": 1060,
                    "large_price": 1060,
                    "small_price": 1060,
                    "image_url": "/image_editor/component_option/1253.png",
                    "show": true
                }, {
                    "name": "10'W x 8'H Overhead Door - Economy Insulated",
                    "id": 1254,
                    "price": 1240,
                    "large_price": 1240,
                    "small_price": 1240,
                    "image_url": "/image_editor/component_option/1254.png",
                    "show": true
                }, {
                    "name": "10'W x 8'H Overhead Door - Standard Insulated",
                    "id": 1255,
                    "price": 1380,
                    "large_price": 1380,
                    "small_price": 1380,
                    "image_url": "/image_editor/component_option/1255.png",
                    "show": true
                }, {
                    "name": "10'W x 8'H Overhead Door - Carriage House Style",
                    "id": 1256,
                    "price": 1950,
                    "large_price": 1950,
                    "small_price": 1950,
                    "image_url": "/image_editor/component_option/1256.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/793.png",
                "show": true,
                "$$hashKey": "object:216"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 794,
                "price": 295,
                "large_price": 295,
                "small_price": 295,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:217"
            }, {
                "name": "12'W x 7'H Overhead Door",
                "id": 795,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "12'W x 7'H Overhead Door - Non-Insulated",
                    "id": 1257,
                    "price": 1140,
                    "large_price": 1140,
                    "small_price": 1140,
                    "image_url": "/image_editor/component_option/1257.png",
                    "show": true
                }, {
                    "name": "12'W x 7'H Overhead Door - Economy Insulated",
                    "id": 1258,
                    "price": 1260,
                    "large_price": 1260,
                    "small_price": 1260,
                    "image_url": "/image_editor/component_option/1258.png",
                    "show": true
                }, {
                    "name": "12'W x 7'H Overhead Door - Standard Insulated",
                    "id": 1259,
                    "price": 1545,
                    "large_price": 1545,
                    "small_price": 1545,
                    "image_url": "/image_editor/component_option/1259.png",
                    "show": true
                }, {
                    "name": "12'W x 7'H Overhead Door - Carriage House Style",
                    "id": 1260,
                    "price": 2370,
                    "large_price": 2370,
                    "small_price": 2370,
                    "image_url": "/image_editor/component_option/1260.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/795.png",
                "show": true,
                "$$hashKey": "object:218"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 796,
                "price": 355,
                "large_price": 355,
                "small_price": 355,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:219"
            }, {
                "name": "12'W x 8'H Overhead Door",
                "id": 797,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "12'W x 8'H Overhead Door - Non-Insulated",
                    "id": 1261,
                    "price": 1275,
                    "large_price": 1275,
                    "small_price": 1275,
                    "image_url": "/image_editor/component_option/1261.png",
                    "show": true
                }, {
                    "name": "12'W x 8'H Overhead Door - Economy Insulated",
                    "id": 1262,
                    "price": 1425,
                    "large_price": 1425,
                    "small_price": 1425,
                    "image_url": "/image_editor/component_option/1262.png",
                    "show": true
                }, {
                    "name": "12'W x 8'H Overhead Door - Standard Insulated",
                    "id": 1263,
                    "price": 1665,
                    "large_price": 1665,
                    "small_price": 1665,
                    "image_url": "/image_editor/component_option/1263.png",
                    "show": true
                }, {
                    "name": "12'W x 8'H Overhead Door - Carriage House Style",
                    "id": 1264,
                    "price": 2490,
                    "large_price": 2490,
                    "small_price": 2490,
                    "image_url": "/image_editor/component_option/1264.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/797.png",
                "show": true,
                "$$hashKey": "object:220"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 798,
                "price": 355,
                "large_price": 355,
                "small_price": 355,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:221"
            }, {
                "name": "16'W x 7'H Overhead Door",
                "id": 799,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "16'W x 7'H Overhead Door - Non-Insulated",
                    "id": 1265,
                    "price": 1260,
                    "large_price": 1260,
                    "small_price": 1260,
                    "image_url": "/image_editor/component_option/1265.png",
                    "show": true
                }, {
                    "name": "16'W x 7'H Overhead Door - Economy Insulated",
                    "id": 1266,
                    "price": 1460,
                    "large_price": 1460,
                    "small_price": 1460,
                    "image_url": "/image_editor/component_option/1266.png",
                    "show": true
                }, {
                    "name": "16'W x 7'H Overhead Door - Standard Insulated",
                    "id": 1267,
                    "price": 1670,
                    "large_price": 1670,
                    "small_price": 1670,
                    "image_url": "/image_editor/component_option/1267.png",
                    "show": true
                }, {
                    "name": "16'W x 7'H Overhead Door - Carriage House Style",
                    "id": 1268,
                    "price": 2730,
                    "large_price": 2730,
                    "small_price": 2730,
                    "image_url": "/image_editor/component_option/1268.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/799.png",
                "show": true,
                "$$hashKey": "object:222"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 800,
                "price": 475,
                "large_price": 475,
                "small_price": 475,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:223"
            }, {
                "name": "16'W x 8'H Overhead Door",
                "id": 801,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "16'W x 8'H Overhead Door - Non-Insulated",
                    "id": 1269,
                    "price": 1410,
                    "large_price": 1410,
                    "small_price": 1410,
                    "image_url": "/image_editor/component_option/1269.png",
                    "show": true
                }, {
                    "name": "16'W x 8'H Overhead Door - Economy Insulated",
                    "id": 1270,
                    "price": 1630,
                    "large_price": 1630,
                    "small_price": 1630,
                    "image_url": "/image_editor/component_option/1270.png",
                    "show": true
                }, {
                    "name": "16'W x 8'H Overhead Door - Standard Insulated",
                    "id": 1271,
                    "price": 1870,
                    "large_price": 1870,
                    "small_price": 1870,
                    "image_url": "/image_editor/component_option/1271.png",
                    "show": true
                }, {
                    "name": "16'W x 8'H Overhead Door - Carriage House Style",
                    "id": 1272,
                    "price": 2920,
                    "large_price": 2920,
                    "small_price": 2920,
                    "image_url": "/image_editor/component_option/1272.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/801.png",
                "show": true,
                "$$hashKey": "object:224"
            }, {
                "name": "Window Lites for Non, Economy, or Standard Insulated Doors",
                "id": 802,
                "price": 475,
                "large_price": 475,
                "small_price": 475,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:225"
            }],
            "show": true,
            "$$hashKey": "object:108"
        }, {
            "name": "Overhead Door Add-Ons",
            "subcategory_show": true,
            "components": [{
                "name": "Overhead Door Opener w/ One Remote",
                "id": 803,
                "price": 395,
                "large_price": 395,
                "small_price": 395,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Additional Remote",
                "id": 804,
                "price": 50,
                "large_price": 50,
                "small_price": 50,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }],
            "show": false,
            "$$hashKey": "object:109"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 805,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:660"
            }],
            "show": true,
            "$$hashKey": "object:110"
        }],
        "$$hashKey": "object:49"
    }, {
        "name": "Windows",
        "subsections": [{
            "name": "Windows",
            "subcategory_show": true,
            "components": [{
                "name": "2' x 2' Single Hung with screen & grids",
                "id": 806,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 2' Single Hung with screen & grids - White",
                    "id": 1273,
                    "price": 80,
                    "large_price": 85,
                    "small_price": 80,
                    "image_url": "/image_editor/component_option/1273.png",
                    "show": true
                }, {
                    "name": "2' x 2' Single Hung with screen & grids – Brown",
                    "id": 1274,
                    "price": 80,
                    "large_price": 85,
                    "small_price": 80,
                    "image_url": "/image_editor/component_option/1274.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/806.png",
                "show": true,
                "$$hashKey": "object:282"
            }, {
                "name": "2' x 3' Single Hung with screen & grids",
                "id": 807,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 3' Single Hung with screen & grids - White",
                    "id": 1275,
                    "price": 90,
                    "large_price": 95,
                    "small_price": 90,
                    "image_url": "/image_editor/component_option/1275.png",
                    "show": true
                }, {
                    "name": "2' x 3' Single Hung with screen & grids - Brown",
                    "id": 1276,
                    "price": 90,
                    "large_price": 95,
                    "small_price": 90,
                    "image_url": "/image_editor/component_option/1276.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/807.png",
                "show": true,
                "$$hashKey": "object:283"
            }, {
                "name": "2' x 4' Single Hung with screen & grids",
                "id": 808,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 4' Single Hung with screen & grids - White",
                    "id": 1277,
                    "price": 120,
                    "large_price": 125,
                    "small_price": 120,
                    "image_url": "/image_editor/component_option/1277.png",
                    "show": true
                }, {
                    "name": "2' x 4' Single Hung with screen & grids - Brown",
                    "id": 1278,
                    "price": 120,
                    "large_price": 125,
                    "small_price": 120,
                    "image_url": "/image_editor/component_option/1278.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/808.png",
                "show": true,
                "$$hashKey": "object:284"
            }, {
                "name": "2' x 3' Window with Transom",
                "id": 809,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 3' Window with Transom - White",
                    "id": 1279,
                    "price": 150,
                    "large_price": 160,
                    "small_price": 150,
                    "image_url": "/image_editor/component_option/1279.png",
                    "show": true
                }, {
                    "name": "2' x 3' Window with Transom - Brown",
                    "id": 1280,
                    "price": 150,
                    "large_price": 160,
                    "small_price": 150,
                    "image_url": "/image_editor/component_option/1280.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/809.png",
                "show": true,
                "$$hashKey": "object:285"
            }, {
                "name": "2' x 3' Vinyl SINGLE HUNG Window with screen & grids",
                "id": 810,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 3' Vinyl SINGLE HUNG Window with screen & grids - White",
                    "id": 1281,
                    "price": 190,
                    "large_price": 200,
                    "small_price": 190,
                    "image_url": "/image_editor/component_option/1281.png",
                    "show": true
                }, {
                    "name": "2' x 3' Vinyl SINGLE HUNG Window with screen & grids - Almond",
                    "id": 1282,
                    "price": 225,
                    "large_price": 235,
                    "small_price": 225,
                    "image_url": "/image_editor/component_option/1282.png",
                    "show": true
                }, {
                    "name": "2' x 3' Vinyl SINGLE HUNG Window with screen & grids - Clay",
                    "id": 1283,
                    "price": 225,
                    "large_price": 235,
                    "small_price": 225,
                    "image_url": "/image_editor/component_option/1283.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/810.png",
                "show": true,
                "$$hashKey": "object:286"
            }, {
                "name": "2' x 4' Vinyl SINGLE HUNG Window with screen & grids",
                "id": 811,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 4' Vinyl SINGLE HUNG Window with screen & grids - White",
                    "id": 1284,
                    "price": 190,
                    "large_price": 230,
                    "small_price": 190,
                    "image_url": "/image_editor/component_option/1284.png",
                    "show": true
                }, {
                    "name": "2' x 4' Vinyl SINGLE HUNG Window with screen & grids - Almond",
                    "id": 1285,
                    "price": 225,
                    "large_price": 265,
                    "small_price": 225,
                    "image_url": "/image_editor/component_option/1285.png",
                    "show": true
                }, {
                    "name": "2' x 4' Vinyl SINGLE HUNG Window with screen & grids - Clay",
                    "id": 1286,
                    "price": 225,
                    "large_price": 265,
                    "small_price": 225,
                    "image_url": "/image_editor/component_option/1286.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/811.png",
                "show": true,
                "$$hashKey": "object:287"
            }, {
                "name": "3' x 4' Vinyl SINGLE HUNG Window with screen & grids",
                "id": 812,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "3' x 4' Vinyl SINGLE HUNG Window with screen & grids - White",
                    "id": 1287,
                    "price": 235,
                    "large_price": 245,
                    "small_price": 235,
                    "image_url": "/image_editor/component_option/1287.png",
                    "show": true
                }, {
                    "name": "3' x 4' Vinyl SINGLE HUNG Window with screen & grids - Almond",
                    "id": 1288,
                    "price": 270,
                    "large_price": 280,
                    "small_price": 270,
                    "image_url": "/image_editor/component_option/1288.png",
                    "show": true
                }, {
                    "name": "3' x 4' Vinyl SINGLE HUNG Window with screen & grids - Clay",
                    "id": 1289,
                    "price": 270,
                    "large_price": 280,
                    "small_price": 270,
                    "image_url": "/image_editor/component_option/1289.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/812.png",
                "show": true,
                "$$hashKey": "object:288"
            }, {
                "name": "2' x 3' Vinyl DOUBLE HUNG Window with screen & grids",
                "id": 813,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 3' Vinyl DOUBLE HUNG Window with screen & grids - White",
                    "id": 1290,
                    "price": 0,
                    "large_price": 270,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1290.png",
                    "show": true
                }, {
                    "name": "2' x 3' Vinyl DOUBLE HUNG Window with screen & grids - Almond",
                    "id": 1291,
                    "price": 0,
                    "large_price": 305,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1291.png",
                    "show": true
                }, {
                    "name": "2' x 3' Vinyl DOUBLE HUNG Window with screen & grids - Clay",
                    "id": 1292,
                    "price": 0,
                    "large_price": 305,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1292.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/813.png",
                "show": false,
                "$$hashKey": "object:289"
            }, {
                "name": "2' x 4' Vinyl DOUBLE HUNG Window with screen & grids",
                "id": 814,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "2' x 4' Vinyl DOUBLE HUNG Window with screen & grids - White",
                    "id": 1293,
                    "price": 0,
                    "large_price": 340,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1293.png",
                    "show": true
                }, {
                    "name": "2' x 4' Vinyl DOUBLE HUNG Window with screen & grids - Almond",
                    "id": 1294,
                    "price": 0,
                    "large_price": 375,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1294.png",
                    "show": true
                }, {
                    "name": "2' x 4' Vinyl DOUBLE HUNG Window with screen & grids - Clay",
                    "id": 1295,
                    "price": 0,
                    "large_price": 375,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1295.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/814.png",
                "show": false,
                "$$hashKey": "object:290"
            }, {
                "name": "3' x 4' Vinyl DOUBLE HUNG Window with screen & grids",
                "id": 815,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "3' x 4' Vinyl DOUBLE HUNG Window with screen & grids - White",
                    "id": 1296,
                    "price": 0,
                    "large_price": 390,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1296.png",
                    "show": true
                }, {
                    "name": "3' x 4' Vinyl DOUBLE HUNG Window with screen & grids - Almond",
                    "id": 1297,
                    "price": 0,
                    "large_price": 425,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1297.png",
                    "show": true
                }, {
                    "name": "3' x 4' Vinyl DOUBLE HUNG Window with screen & grids - Clay",
                    "id": 1298,
                    "price": 0,
                    "large_price": 425,
                    "small_price": 0,
                    "image_url": "/image_editor/component_option/1298.png",
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/815.png",
                "show": false,
                "$$hashKey": "object:291"
            }],
            "show": true,
            "$$hashKey": "object:271"
        }, {
            "name": "Skylight",
            "subcategory_show": true,
            "components": [{
                "name": "2' x 2' Bubble Skylight",
                "id": 816,
                "price": 95,
                "large_price": 95,
                "small_price": 95,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/816.png",
                "show": true,
                "$$hashKey": "object:317"
            }, {
                "name": "2' x 2' Skylight - installed in metal roof",
                "id": 817,
                "price": 180,
                "large_price": 180,
                "small_price": 180,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/817.png",
                "show": true,
                "$$hashKey": "object:318"
            }, {
                "name": "2' x4' Insulated Skylight",
                "id": 818,
                "price": 0,
                "large_price": 565,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/818.png",
                "show": false,
                "$$hashKey": "object:319"
            }, {
                "name": "2' x4' Insulated Skylight - installed in metal roof",
                "id": 819,
                "price": 0,
                "large_price": 665,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/819.png",
                "show": false,
                "$$hashKey": "object:320"
            }],
            "show": true,
            "$$hashKey": "object:272"
        }, {
            "name": "Window Add-ons",
            "subcategory_show": true,
            "components": [{
                "name": "6-lite Wooden Window",
                "id": 820,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "6-lite Wooden Window – Arched",
                    "id": 1299,
                    "price": 120,
                    "large_price": 130,
                    "small_price": 120,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "6-lite Wooden Window – Square",
                    "id": 1300,
                    "price": 120,
                    "large_price": 130,
                    "small_price": 120,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:330"
            }, {
                "name": "Transom Windows",
                "id": 821,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "Transom Windows - White",
                    "id": 1301,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Transom Windows - Brown",
                    "id": 1302,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:331"
            }, {
                "name": "Octagon Window",
                "id": 822,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "Octagon Window - White",
                    "id": 1303,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Octagon Window - Brown",
                    "id": 1304,
                    "price": 60,
                    "large_price": 54,
                    "small_price": 60,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": "image_editor/component/822.png",
                "show": true,
                "$$hashKey": "object:332"
            }],
            "show": true,
            "$$hashKey": "object:273"
        }, {
            "name": "Window Accessories",
            "subcategory_show": true,
            "components": [{
                "name": "Cedar Shutter Set",
                "id": 823,
                "price": 45,
                "large_price": 45,
                "small_price": 45,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/823.png",
                "show": true,
                "$$hashKey": "object:341"
            }, {
                "name": "Cedar Flowerbox",
                "id": 824,
                "price": 40,
                "large_price": 40,
                "small_price": 40,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/824.png",
                "show": true,
                "$$hashKey": "object:342"
            }, {
                "name": "Cedar Shutter Set & Flowerbox",
                "id": 825,
                "price": 85,
                "large_price": 85,
                "small_price": 85,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/825.png",
                "show": true,
                "$$hashKey": "object:343"
            }, {
                "name": "Vinyl Shutter Set Panel Style",
                "id": 826,
                "price": 50,
                "large_price": 55,
                "small_price": 50,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/826.png",
                "show": true,
                "$$hashKey": "object:344"
            }, {
                "name": "Vinyl Flowerbox",
                "id": 827,
                "price": 45,
                "large_price": 45,
                "small_price": 45,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/827.png",
                "show": true,
                "$$hashKey": "object:345"
            }, {
                "name": "Vinyl Shutter Set & Flowerbox",
                "id": 828,
                "price": 95,
                "large_price": 100,
                "small_price": 95,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/828.png",
                "show": true,
                "$$hashKey": "object:346"
            }, {
                "name": "Vinyl Flowerbox Color",
                "id": 908,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Black",
                    "id": 1476,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cherrywood",
                    "id": 1477,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chestnut Brown",
                    "id": 1478,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dove Gray",
                    "id": 1479,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Green",
                    "id": 1480,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Weatherwood",
                    "id": 1481,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1482,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:347"
            }, {
                "name": "Vinyl Shutter Color",
                "id": 909,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Black",
                    "id": 1483,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bordeaux",
                    "id": 1484,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bright White",
                    "id": 1485,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bugundy Red",
                    "id": 1486,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Classic Blue",
                    "id": 1487,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1488,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Federal Brown",
                    "id": 1489,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Forest Green",
                    "id": 1490,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Midnight Blue",
                    "id": 1491,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Midnight Green",
                    "id": 1492,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Musket Brown",
                    "id": 1493,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Tuxedo Gray",
                    "id": 1494,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wedgewood Blue",
                    "id": 1495,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1496,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wicker",
                    "id": 1497,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wineberry",
                    "id": 1498,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:348"
            }],
            "show": true,
            "$$hashKey": "object:274"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 829,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:747"
            }],
            "show": true,
            "$$hashKey": "object:275"
        }],
        "$$hashKey": "object:50"
    }, {
        "name": "Cupolas",
        "subsections": [{
            "name": "Cupolas Style",
            "subcategory_show": true,
            "components": [{
                "name": "Cupola Style",
                "id": 830,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "Windowpane Style",
                    "id": 1305,
                    "price": 265,
                    "large_price": 275,
                    "small_price": 265,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:769"
                }, {
                    "name": "Traditional Style",
                    "id": 1306,
                    "price": 265,
                    "large_price": 275,
                    "small_price": 265,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:770"
                }, {
                    "name": "None",
                    "id": 1307,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:771"
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:762"
            }, {
                "name": "Copper Colored Metal Roof",
                "id": 831,
                "price": 75,
                "large_price": 80,
                "small_price": 75,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:763"
            }],
            "show": true,
            "$$hashKey": "object:753"
        }, {
            "name": "Weathervane",
            "subcategory_show": true,
            "components": [{
                "name": "Weathervane",
                "id": 832,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "Rooster",
                    "id": 1308,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:785"
                }, {
                    "name": "Horse & Carriage",
                    "id": 1309,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:786"
                }, {
                    "name": "Horse  ",
                    "id": 1310,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:787"
                }, {
                    "name": "Eagle",
                    "id": 1311,
                    "price": 60,
                    "large_price": 65,
                    "small_price": 60,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:788"
                }, {
                    "name": "None",
                    "id": 1312,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:789"
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:781"
            }],
            "show": true,
            "$$hashKey": "object:754"
        }, {
            "name": "Add-Ons",
            "subcategory_show": true,
            "components": [{
                "name": "Add 110v Light Inside Cupola",
                "id": 833,
                "price": 30,
                "large_price": 30,
                "small_price": 30,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:801"
            }],
            "show": true,
            "$$hashKey": "object:755"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 834,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:806"
            }],
            "show": true,
            "$$hashKey": "object:756"
        }],
        "$$hashKey": "object:51"
    }, {
        "name": "Shelves",
        "subsections": [{
            "name": "Shelves",
            "subcategory_show": true,
            "components": [{
                "name": "8' x 1' (2 x 4 Joists)",
                "id": 835,
                "price": 35,
                "large_price": 35,
                "small_price": 35,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/835.png",
                "show": true,
                "$$hashKey": "object:376"
            }, {
                "name": "10' x 1' (2 x 4 Joists)",
                "id": 836,
                "price": 40,
                "large_price": 40,
                "small_price": 40,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/836.png",
                "show": true,
                "$$hashKey": "object:377"
            }, {
                "name": "12' x 1' (2 x 6 Joists)",
                "id": 837,
                "price": 50,
                "large_price": 50,
                "small_price": 50,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/837.png",
                "show": true,
                "$$hashKey": "object:378"
            }, {
                "name": "14' x 1' (2 x 6 Joists)",
                "id": 838,
                "price": 55,
                "large_price": 55,
                "small_price": 55,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/838.png",
                "show": true,
                "$$hashKey": "object:379"
            }, {
                "name": "16' x 1' (2 x 6 Joists)",
                "id": 839,
                "price": 65,
                "large_price": 65,
                "small_price": 65,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/839.png",
                "show": true,
                "$$hashKey": "object:380"
            }, {
                "name": "8' x 2' (2 x 4 Joists)",
                "id": 840,
                "price": 45,
                "large_price": 45,
                "small_price": 45,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/840.png",
                "show": true,
                "$$hashKey": "object:381"
            }, {
                "name": "10' x 2' (2 x 4 Joists)",
                "id": 841,
                "price": 55,
                "large_price": 55,
                "small_price": 55,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/841.png",
                "show": true,
                "$$hashKey": "object:382"
            }, {
                "name": "12' x 2' (2 x 6 Joists)",
                "id": 842,
                "price": 75,
                "large_price": 80,
                "small_price": 75,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/842.png",
                "show": true,
                "$$hashKey": "object:383"
            }, {
                "name": "14' x 2' (2 x 6 Joists)",
                "id": 843,
                "price": 85,
                "large_price": 90,
                "small_price": 85,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/843.png",
                "show": true,
                "$$hashKey": "object:384"
            }, {
                "name": "16' x 2' (2 x 6 Joists)",
                "id": 844,
                "price": 95,
                "large_price": 100,
                "small_price": 95,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/844.png",
                "show": true,
                "$$hashKey": "object:385"
            }],
            "show": true,
            "$$hashKey": "object:369"
        }, {
            "name": "Work Bench",
            "subcategory_show": true,
            "components": [{
                "name": "8 x 2 work bench ",
                "id": 845,
                "price": 125,
                "large_price": 130,
                "small_price": 125,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:847"
            }, {
                "name": "10 x 2 work bench",
                "id": 846,
                "price": 145,
                "large_price": 155,
                "small_price": 145,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:848"
            }, {
                "name": "12 x 2 work bench",
                "id": 847,
                "price": 165,
                "large_price": 175,
                "small_price": 165,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:849"
            }],
            "show": true,
            "$$hashKey": "object:370"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 848,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:860"
            }],
            "show": true,
            "$$hashKey": "object:371"
        }],
        "$$hashKey": "object:52"
    }, {
        "name": "Lofts",
        "subsections": [{
            "name": "Lofts",
            "subcategory_show": true,
            "components": [{
                "name": "8' x 4' (2 x 4 Joists 24\" O/C)",
                "id": 849,
                "price": 65,
                "large_price": 65,
                "small_price": 65,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/849.png",
                "show": true,
                "$$hashKey": "object:423"
            }, {
                "name": "10' x 4' (2 x 4 Joists 24\" O/C)",
                "id": 850,
                "price": 75,
                "large_price": 75,
                "small_price": 75,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/850.png",
                "show": true,
                "$$hashKey": "object:424"
            }, {
                "name": "12' x 4' (2 x 6 Joists 24\" O/C)",
                "id": 851,
                "price": 110,
                "large_price": 115,
                "small_price": 110,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/851.png",
                "show": true,
                "$$hashKey": "object:425"
            }, {
                "name": "14' x 4' (2 x 8 Joists 16\" O/C)",
                "id": 852,
                "price": 135,
                "large_price": 145,
                "small_price": 135,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/852.png",
                "show": true,
                "$$hashKey": "object:426"
            }, {
                "name": "16' x 4' (2 x 8 Joists 16\" O/C)",
                "id": 853,
                "price": 155,
                "large_price": 165,
                "small_price": 155,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": "image_editor/component/853.png",
                "show": true,
                "$$hashKey": "object:427"
            }, {
                "name": "2 x 8 Joists w/ 5/8\" Plywood",
                "id": 854,
                "price": 0,
                "large_price": 3,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:428"
            }, {
                "name": "2 x 10 Joists w/ 3/4\" Plywood",
                "id": 855,
                "price": 0,
                "large_price": 3.65,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:429"
            }, {
                "name": "I-Joists w/ 3/4\" Plywood",
                "id": 856,
                "price": 0,
                "large_price": 4.5,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:430"
            }],
            "show": true,
            "$$hashKey": "object:416"
        }, {
            "name": "Steps",
            "subcategory_show": true,
            "components": [{
                "name": "Loft Steps With Handrail",
                "id": 857,
                "price": 0,
                "large_price": 455,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Loft Steps With Landing & Handrail",
                "id": 858,
                "price": 0,
                "large_price": 680,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "1 x 4 Pine Railing",
                "id": 859,
                "price": 0,
                "large_price": 600,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Risers on Steps",
                "id": 860,
                "price": 0,
                "large_price": 105,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Pull-Down Steps",
                "id": 861,
                "price": 0,
                "large_price": 286,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Stair Ladder",
                "id": 862,
                "price": 0,
                "large_price": 280,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Exterior Treated Landing w/ 3 Treads",
                "id": 863,
                "price": 0,
                "large_price": 286,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Additional Exterior Tread",
                "id": 864,
                "price": 0,
                "large_price": 45,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Additional Exterior  Landing",
                "id": 865,
                "price": 0,
                "large_price": 370,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false
            }],
            "show": false,
            "$$hashKey": "object:417"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 866,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:889"
            }],
            "show": true,
            "$$hashKey": "object:418"
        }],
        "$$hashKey": "object:53"
    }, {
        "name": "Roof",
        "subsections": [{
            "name": "Roof",
            "subcategory_show": true,
            "components": [{
                "name": "Roof",
                "id": 867,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [{
                    "name": "15# Felt Paper",
                    "id": 1313,
                    "price": 0.3,
                    "large_price": 0.3,
                    "small_price": 0.3,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:910"
                }, {
                    "name": "Metal Roof",
                    "id": 1314,
                    "price": 2.05,
                    "large_price": 2.05,
                    "small_price": 2.05,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:911"
                }, {
                    "name": "Metal Roof on Mini & Craftsman",
                    "id": 1315,
                    "price": 4.1,
                    "large_price": 4.1,
                    "small_price": 4.1,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:912"
                }, {
                    "name": "Metal Roof on Garage & Cedar Brooke",
                    "id": 1316,
                    "price": 1.65,
                    "large_price": 1.65,
                    "small_price": 1.65,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:913"
                }, {
                    "name": "Metal Roof on Dutch Barn & Cabin",
                    "id": 1317,
                    "price": 2.95,
                    "large_price": 2.95,
                    "small_price": 2.95,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:914"
                }, {
                    "name": "None",
                    "id": 1318,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:915"
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:904"
            }, {
                "name": "Metal Roof Color",
                "id": 868,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Black",
                    "id": 1319,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brite Red",
                    "id": 1320,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1321,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1322,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Burgundy",
                    "id": 1323,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1324,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1325,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Copper",
                    "id": 1326,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Gallery Blue",
                    "id": 1327,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Galvalume",
                    "id": 1328,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Green",
                    "id": 1329,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Hawiian Blue",
                    "id": 1330,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Light Gray",
                    "id": 1331,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Light Stone",
                    "id": 1332,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Rustic Red",
                    "id": 1333,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Tan",
                    "id": 1334,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1335,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:905"
            }],
            "show": true,
            "$$hashKey": "object:895"
        }, {
            "name": "Shingles",
            "subcategory_show": true,
            "components": [{
                "name": "Shingles",
                "id": 869,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [{
                    "name": "25 Year Shingles",
                    "id": 1336,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:937"
                }, {
                    "name": "30-Year Shingle Upgrade",
                    "id": 1337,
                    "price": 0.5,
                    "large_price": 0.5,
                    "small_price": 0.5,
                    "image_url": null,
                    "show": true,
                    "$$hashKey": "object:938"
                }],
                "value": 1336,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:929"
            }, {
                "name": "Custom Shingles",
                "id": 918,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": false,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:930"
            }, {
                "name": "Shingle Color",
                "id": 870,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Driftwood",
                    "id": 1338,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brownwood",
                    "id": 1339,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Desert Tan",
                    "id": 1340,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Estate Gray",
                    "id": 1341,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Siera Gray",
                    "id": 1342,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Onyx Black",
                    "id": 1343,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chapel Gray",
                    "id": 1471,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Asen Gray",
                    "id": 1472,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chateau Green",
                    "id": 1344,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Teak",
                    "id": 1345,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1714,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:931"
            }],
            "show": true,
            "$$hashKey": "object:896"
        }, {
            "name": "Drip Edge",
            "subcategory_show": true,
            "components": [{
                "name": "Drip Edge Color",
                "id": 871,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Brown",
                    "id": 1346,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1347,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Metal Roof",
                    "id": 1715,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:950"
            }],
            "show": true,
            "$$hashKey": "object:897"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 872,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:956"
            }],
            "show": true,
            "$$hashKey": "object:898"
        }],
        "$$hashKey": "object:54"
    }, {
        "name": "Paint & Stain",
        "subsections": [{
            "name": "Paint",
            "subcategory_show": true,
            "components": [{
                "name": "Paint",
                "id": 873,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [{
                    "name": "Paint Prebuilt Mini & Gable",
                    "id": 1348,
                    "price": 1.8,
                    "large_price": 1.8,
                    "small_price": 1.8,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Paint Prebuilt Estate, Sugarcreek, Cottage, & Craftsman",
                    "id": 1349,
                    "price": 2.35,
                    "large_price": 2.35,
                    "small_price": 2.35,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Paint Prebuilt Highland",
                    "id": 1350,
                    "price": 2.45,
                    "large_price": 2.45,
                    "small_price": 2.45,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "None",
                    "id": 1351,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:977"
            }, {
                "name": "Paint w/Non-Stock Color (add)",
                "id": 874,
                "price": 0.5,
                "large_price": 0.5,
                "small_price": 0.5,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:978"
            }, {
                "name": "Paint for AOS",
                "id": 875,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:979"
            }, {
                "name": "Body Color",
                "id": 876,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1352,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1353,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1354,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1355,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1356,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1357,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1358,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1359,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1360,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1361,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1362,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1363,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1364,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1365,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1366,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1367,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1368,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1369,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1370,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1371,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1372,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1712,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:980"
            }, {
                "name": "Trim Color",
                "id": 877,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1525,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1526,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1527,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1528,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1529,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1530,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1531,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1532,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1533,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1534,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1535,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1536,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1537,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1538,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1539,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1540,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1541,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1542,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1543,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1544,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1545,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1711,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:981"
            }, {
                "name": "Door Color",
                "id": 921,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1601,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1602,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1603,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1604,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1605,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1606,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1607,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1608,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1609,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1610,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1611,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1612,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1613,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1614,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1615,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1616,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1617,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1618,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1619,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1620,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1621,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1709,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:982"
            }, {
                "name": "Shutter Color",
                "id": 922,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1622,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1623,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1624,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1625,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1626,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1627,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1628,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1629,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1630,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1631,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1632,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1633,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1634,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1635,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1636,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1637,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1638,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1639,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1640,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1641,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1642,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:983"
            }],
            "show": true,
            "$$hashKey": "object:962"
        }, {
            "name": "Stain",
            "subcategory_show": true,
            "components": [{
                "name": "Trim Color",
                "id": 910,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1373,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1374,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1375,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1376,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1377,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1378,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1379,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1380,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1381,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1382,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1383,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1384,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1385,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1386,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1387,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1388,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1389,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1390,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1391,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1392,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1393,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Natural",
                    "id": 1697,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Caramel",
                    "id": 1698,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1699,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bark",
                    "id": 1700,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chestnut",
                    "id": 1701,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Smoke",
                    "id": 1702,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1706,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1006"
            }, {
                "name": "Stain",
                "id": 878,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "radio",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [{
                    "name": "Stain Prebuilt Mini & Gable",
                    "id": 1394,
                    "price": 3.3,
                    "large_price": 3.3,
                    "small_price": 3.3,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Stain Prebuilt Estate, Sugarcreek, Cottage, & Craftsman",
                    "id": 1395,
                    "price": 4.7,
                    "large_price": 4.7,
                    "small_price": 4.7,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Stain Prebuilt Highland",
                    "id": 1396,
                    "price": 5,
                    "large_price": 5,
                    "small_price": 5,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "None",
                    "id": 1397,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1007"
            }, {
                "name": "Stain for AOS",
                "id": 879,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1008"
            }, {
                "name": "Body Color",
                "id": 880,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Natural",
                    "id": 1398,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Caramel",
                    "id": 1399,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1400,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bark ",
                    "id": 1401,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chestnut",
                    "id": 1402,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Smoke",
                    "id": 1403,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1713,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1009"
            }, {
                "name": "Door Color",
                "id": 923,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1643,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1644,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1645,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1646,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1647,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1648,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1649,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1650,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1651,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1652,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1653,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1654,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1655,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1656,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1657,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1658,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1659,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1660,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1661,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1662,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1663,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Natural",
                    "id": 1664,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Caramel",
                    "id": 1665,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1666,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bark",
                    "id": 1667,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chestnut",
                    "id": 1668,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Smoke",
                    "id": 1669,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1710,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1010"
            }, {
                "name": "Shutter Color",
                "id": 924,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Navajo White",
                    "id": 1670,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1671,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamestown Red",
                    "id": 1672,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Woodland Green",
                    "id": 1673,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Wild Grasses",
                    "id": 1674,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Avocado",
                    "id": 1675,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1676,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn White",
                    "id": 1677,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jasper Gray",
                    "id": 1678,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Steel Gray",
                    "id": 1679,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1680,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Gray",
                    "id": 1681,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Buckskin",
                    "id": 1682,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1683,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1684,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Shale",
                    "id": 1685,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1686,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1687,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1688,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pinnacle Red",
                    "id": 1689,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mountain Red",
                    "id": 1690,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Natural",
                    "id": 1691,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Caramel",
                    "id": 1692,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bronze",
                    "id": 1693,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Bark",
                    "id": 1694,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chestnut",
                    "id": 1695,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Smoke",
                    "id": 1696,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1011"
            }],
            "show": true,
            "$$hashKey": "object:963"
        }, {
            "name": "Vinyl",
            "subcategory_show": true,
            "components": [{
                "name": "Vinyl Color",
                "id": 881,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "White",
                    "id": 1404,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Linen",
                    "id": 1405,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Birchwood",
                    "id": 1406,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1407,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Antique White",
                    "id": 1408,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandpiper",
                    "id": 1409,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sienna",
                    "id": 1410,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sand   ",
                    "id": 1411,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mist",
                    "id": 1412,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandalwood",
                    "id": 1413,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Gray",
                    "id": 1414,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pewter",
                    "id": 1415,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay ",
                    "id": 1416,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chateau",
                    "id": 1417,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Everest",
                    "id": 1418,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1033"
            }, {
                "name": "Door Color",
                "id": 919,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Gray",
                    "id": 1549,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pewter",
                    "id": 1550,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1551,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Chateau",
                    "id": 1552,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Everest",
                    "id": 1553,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Birchwood",
                    "id": 1554,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1555,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Antique White",
                    "id": 1556,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandpiper",
                    "id": 1557,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sienna",
                    "id": 1558,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sand",
                    "id": 1559,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mist",
                    "id": 1560,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandalwood",
                    "id": 1561,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1547,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Linen",
                    "id": 1548,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1707,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1034"
            }, {
                "name": "Trim Color",
                "id": 920,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "Almond",
                    "id": 1562,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Antique White",
                    "id": 1563,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Ash Gray",
                    "id": 1564,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1565,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Burgundy",
                    "id": 1566,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Burnished Slate",
                    "id": 1567,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Clay",
                    "id": 1568,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Dark Bronze",
                    "id": 1569,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Grecian Green",
                    "id": 1570,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Light Stone",
                    "id": 1571,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Musket Brown",
                    "id": 1572,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Ocean Blue",
                    "id": 1573,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Royal Brown",
                    "id": 1574,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Rustic Red",
                    "id": 1575,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sand",
                    "id": 1576,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandalwood",
                    "id": 1577,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Spice",
                    "id": 1578,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sterling Gray",
                    "id": 1579,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Terratone",
                    "id": 1580,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Tuxedo Gray",
                    "id": 1581,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1582,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Birchwood",
                    "id": 1583,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cream",
                    "id": 1584,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Linen",
                    "id": 1585,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Mist",
                    "id": 1586,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pewter",
                    "id": 1587,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sage",
                    "id": 1588,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sienna",
                    "id": 1589,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "White",
                    "id": 1590,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Barn Red",
                    "id": 1591,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black/Royal Brown",
                    "id": 1592,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Canyon",
                    "id": 1593,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Camel",
                    "id": 1594,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Desert Tan",
                    "id": 1595,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Greystone Granite Gray",
                    "id": 1596,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pacific Blue",
                    "id": 1597,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Pueblo",
                    "id": 1598,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandstone Saddle",
                    "id": 1599,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Scotch Red",
                    "id": 1600,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Custom",
                    "id": 1708,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1035"
            }],
            "show": true,
            "$$hashKey": "object:964"
        }, {
            "name": "Wood Door Color Option",
            "subcategory_show": true,
            "components": [{
                "name": "Wood Door Color Option",
                "id": 882,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "truffle",
                    "id": 1419,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "lemon grass",
                    "id": 1420,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "belmont blue",
                    "id": 1421,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "steel blue",
                    "id": 1422,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "pinnacle red",
                    "id": 1423,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "mountain red",
                    "id": 1424,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "woodland green",
                    "id": 1425,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "wild grasses",
                    "id": 1426,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "pequea green",
                    "id": 1427,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "hunter green",
                    "id": 1428,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "barn white",
                    "id": 1429,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "zook gray",
                    "id": 1430,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "dark gray",
                    "id": 1431,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "black",
                    "id": 1432,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "navajo white",
                    "id": 1433,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "almond",
                    "id": 1434,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "buckskin",
                    "id": 1435,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "clay",
                    "id": 1436,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "shale",
                    "id": 1437,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "brown",
                    "id": 1438,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "non stock paint",
                    "id": 1439,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "natural",
                    "id": 1440,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "caramel",
                    "id": 1441,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "bronze",
                    "id": 1442,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "bark ",
                    "id": 1443,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "chestnut",
                    "id": 1444,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "smoke",
                    "id": 1445,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Wood Door Custom Color Option",
                "id": 883,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": false,
                "image_url": null,
                "show": false
            }],
            "show": false,
            "$$hashKey": "object:965"
        }, {
            "name": "Steel Door Color Option",
            "subcategory_show": true,
            "components": [{
                "name": "Steel Door Color Option",
                "id": 884,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "White",
                    "id": 1446,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Linen",
                    "id": 1447,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Jamocha",
                    "id": 1448,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1449,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sand",
                    "id": 1450,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Terra Clay",
                    "id": 1451,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sable",
                    "id": 1452,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Golden Prairie",
                    "id": 1453,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Midnight Blue",
                    "id": 1454,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Concord Blue",
                    "id": 1455,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Charcoal",
                    "id": 1456,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Tuxedo Gray",
                    "id": 1457,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Evergreen",
                    "id": 1458,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Rustic Red",
                    "id": 1459,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Deep Ruby",
                    "id": 1460,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Cordavan",
                    "id": 1461,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Royal Brown",
                    "id": 1462,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Black",
                    "id": 1463,
                    "price": 155,
                    "large_price": 155,
                    "small_price": 155,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "Steel Door Custom Color Option",
                "id": 885,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": false,
                "image_url": null,
                "show": false
            }],
            "show": false,
            "$$hashKey": "object:966"
        }, {
            "name": "Overhead Door Add-Ons",
            "subcategory_show": true,
            "components": [{
                "name": "OHD Color Option",
                "id": 886,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [{
                    "name": "White",
                    "id": 1464,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Almond",
                    "id": 1465,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Sandstone",
                    "id": 1466,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "Brown",
                    "id": 1467,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": false
            }, {
                "name": "OHD Custom Color Option",
                "id": 887,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": false,
                "image_url": null,
                "show": false
            }],
            "show": false,
            "$$hashKey": "object:967"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 888,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1046"
            }],
            "show": true,
            "$$hashKey": "object:968"
        }],
        "$$hashKey": "object:55"
    }, {
        "name": "Foundation",
        "subsections": [{
            "name": "Foundation",
            "subcategory_show": true,
            "components": [{
                "name": "Site Prep w/Patio Blocks up to 8\" high",
                "id": 889,
                "price": 1.8,
                "large_price": 1.8,
                "small_price": 1.8,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "sq_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1057"
            }, {
                "name": "Post Perimeter Foundation",
                "id": 890,
                "price": 0,
                "large_price": 23,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1058"
            }, {
                "name": "Drop Slope Height",
                "id": 891,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "select_price",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [{
                    "name": "1 – 3 feet",
                    "id": 1468,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "3 – 6 feet",
                    "id": 1469,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }, {
                    "name": "6 – 9 feet",
                    "id": 1470,
                    "price": 0,
                    "large_price": 0,
                    "small_price": 0,
                    "image_url": null,
                    "show": true
                }],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1059"
            }],
            "show": true,
            "$$hashKey": "object:1052"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 892,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1071"
            }],
            "show": true,
            "$$hashKey": "object:1053"
        }],
        "$$hashKey": "object:56"
    }, {
        "name": "Misc Options",
        "subsections": [{
            "name": "Misc",
            "subcategory_show": true,
            "components": [{
                "name": "Cedar Railing",
                "id": 893,
                "price": 23,
                "large_price": 23,
                "small_price": 23,
                "form_type": "check_length",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1082"
            }, {
                "name": "Vinyl Railing",
                "id": 894,
                "price": 46,
                "large_price": 50,
                "small_price": 46,
                "form_type": "check_length",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1083"
            }, {
                "name": "House Wrap",
                "id": 895,
                "price": 0,
                "large_price": 3.25,
                "small_price": 0,
                "form_type": "checkbox",
                "requires_quantity": true,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1084"
            }, {
                "name": "Door Awning for Man Door (56\")",
                "id": 896,
                "price": 0,
                "large_price": 400,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1085"
            }, {
                "name": "Door Awning for Man Door (22')",
                "id": 897,
                "price": 0,
                "large_price": 1090,
                "small_price": 0,
                "form_type": "numeric",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": false,
                "$$hashKey": "object:1086"
            }, {
                "name": "Carry Charge",
                "id": 906,
                "price": 1,
                "large_price": 1,
                "small_price": 1,
                "form_type": "check_length",
                "requires_quantity": false,
                "pricing_type": "ln_ft",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1087"
            }, {
                "name": "Waste Removal",
                "id": 905,
                "price": 45,
                "large_price": 45,
                "small_price": 45,
                "form_type": "checkbox",
                "requires_quantity": false,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1088"
            }],
            "show": true,
            "$$hashKey": "object:1077"
        }, {
            "name": "Custom",
            "subcategory_show": true,
            "components": [{
                "name": "Custom Field",
                "id": 898,
                "price": 0,
                "large_price": 0,
                "small_price": 0,
                "form_type": "text",
                "requires_quantity": true,
                "pricing_type": "each",
                "options": [],
                "value": null,
                "duplicate": true,
                "image_url": null,
                "show": true,
                "$$hashKey": "object:1103"
            }],
            "show": true,
            "$$hashKey": "object:1078"
        }],
        "$$hashKey": "object:57"
    }],
    "fees": {
        "sales_tax": 7.0,
        "delivery": 0,
        "advanced": {"percent": 0, "price": 0, "special": ""},
        "deposit": 0,
        "deposit_type": ""
    },
    "customer": {
        "id": 0,
        "name": "",
        "email": "",
        "primary_phone": "",
        "secondary_phone": "",
        "address": "",
        "county": "",
        "state": "OH",
        "text": "",
        "zip": "",
        "shipping_same": true,
        "shipping": {"address": "", "county": "", "state": "OH", "text": "", "zip": "", "city": ""},
        "city": "",
        "sales_method": "",
        "advertisement": "",
        "status": "1"
    },
    "extra": {
        "date": "",
        "site_ready_date": "",
        "delivery_date": "",
        "estimated_time": "",
        "purchase_date": "",
        "confirmed": false,
        "crew": "",
        "notes": "",
        "site_ready": false,
        "working_on_site": false,
        "scheduled": false,
        "load_complete": false,
        "serial_number": "",
        "reference": "",
        "additional_notes": ""
    },
    "styles": [{"name": "Cottage", "url": "/images/structures/cottage.png", "$$hashKey": "object:17"}, {
        "name": "Gable",
        "url": "/images/structures/gable.png",
        "$$hashKey": "object:18"
    }, {"name": "Estate", "url": "/images/structures/estate.png", "$$hashKey": "object:19"}, {
        "name": "Mini",
        "url": "/images/structures/mini.png",
        "$$hashKey": "object:20"
    }, {
        "name": "Sugarcreek",
        "url": "/images/structures/sugarcreek.png",
        "$$hashKey": "object:21"
    }, {"name": "Highland", "url": "/images/structures/highland.png", "$$hashKey": "object:22"}, {
        "name": "Woodshed",
        "url": "/images/structures/woodshed.png",
        "$$hashKey": "object:23"
    }, {
        "name": "Craftsman",
        "url": "/images/structures/craftsman.png",
        "$$hashKey": "object:24"
    }, {
        "name": "Cambrel Cabin",
        "url": "/images/structures/cambrel_cabin.png",
        "$$hashKey": "object:25"
    }, {
        "name": "A-Frame Cabin",
        "url": "/images/structures/a-frame_cabin.png",
        "$$hashKey": "object:26"
    }, {
        "name": "Cedar Brooke",
        "url": "/images/structures/cedar_brooke.png",
        "$$hashKey": "object:27"
    }, {"name": "Dutch Barn", "url": "/images/structures/dutch_barn.png", "$$hashKey": "object:28"}, {
        "name": "Garage",
        "url": "/images/structures/garage.png",
        "$$hashKey": "object:29"
    }, {
        "name": "Timber Lodge",
        "url": "/images/structures/timber_lodge.png",
        "$$hashKey": "object:30"
    }, {"name": "Custom", "url": "/images/structures/custom.png", "$$hashKey": "object:31"}],
    "sizes": ["Custom", {"width": 8, "len": 10, "sq_feet": 80, "ln_feet": 36}, {
        "width": 8,
        "len": 8,
        "sq_feet": 64,
        "ln_feet": 32
    }, {"width": 8, "len": 12, "sq_feet": 96, "ln_feet": 40}, {
        "width": 10,
        "len": 10,
        "sq_feet": 100,
        "ln_feet": 40
    }, {"width": 10, "len": 12, "sq_feet": 120, "ln_feet": 44}, {
        "width": 10,
        "len": 14,
        "sq_feet": 140,
        "ln_feet": 48
    }, {"width": 10, "len": 16, "sq_feet": 160, "ln_feet": 52}, {
        "width": 10,
        "len": 20,
        "sq_feet": 200,
        "ln_feet": 60
    }, {"width": 10, "len": 18, "sq_feet": 180, "ln_feet": 56}, {
        "width": 12,
        "len": 12,
        "sq_feet": 144,
        "ln_feet": 48
    }, {"width": 12, "len": 14, "sq_feet": 168, "ln_feet": 52}, {
        "width": 12,
        "len": 16,
        "sq_feet": 192,
        "ln_feet": 56
    }, {"width": 12, "len": 18, "sq_feet": 216, "ln_feet": 60}, {
        "width": 12,
        "len": 20,
        "sq_feet": 240,
        "ln_feet": 64
    }, {"width": 12, "len": 24, "sq_feet": 288, "ln_feet": 72}, {
        "width": 14,
        "len": 20,
        "sq_feet": 280,
        "ln_feet": 68
    }, {"width": 14, "len": 24, "sq_feet": 336, "ln_feet": 76}, {
        "width": 16,
        "len": 20,
        "sq_feet": 320,
        "ln_feet": 72
    }, {"width": 16, "len": 24, "sq_feet": 384, "ln_feet": 80}, {
        "width": 16,
        "len": 30,
        "sq_feet": 480,
        "ln_feet": 92
    }, {"width": 16, "len": 32, "sq_feet": 512, "ln_feet": 96}],
    "paint_stain": "",
    "prebuilt_available": true,
    "base_price": 3608,
    "editor_obj": {
        "options": {
            "horizontal_line": {"draw": true, "color": "#000000", "thickness": 2},
            "grid": {"draw": false, "color": "#cccccc", "style": "solid", "size": 1, "snap": false}
        },
        "selected_tab": 0,
        "version": 2,
        "visuals": {
            "version": 2,
            "barn": {
                "dimensions": {"width": 10, "height": 8, "padding": {"x": 3, "y": 3}},
                "image_url": "/floor_plans/8x10.png"
            },
            "id_count": 9000,
            "visuals": {},
            "z_top": 0
        }
    },
    "base64": "",
    "prices": {
        "base": "$3,608.00",
        "tax": "$243.54",
        "tax_rate": 7.0,
        "options_subtotal": "$0.00",
        "subtotal_1": "$3,608.00",
        "subtotal_2": "$3,608.00",
        "subtotal_3": "$3,608.00",
        "subtotal_4": "$3,608.00",
        "total": "$3,851.54",
        "deposit": "$0.00",
        "balance_due": "$3,851.54",
        "discount_total": "$0.00",
        "delivery": "$0.00"
    },
    "custom": {"structure_name": "", "base_price": 0, "size": {"len": 12, "width": 12}, "feature": ""},
    "warnings": {
        "Customer": ["There is no customer selected."],
        "Visual Editor": ["There are still items in the visual editor that need to be placed."],
        "Shingles": ["Shingle Color needs to be selected."],
        "Drip Edge": ["Drip Edge Color needs to be selected."]
    },
    "revisions": null
};

var manager = new ComponentManager(test);
