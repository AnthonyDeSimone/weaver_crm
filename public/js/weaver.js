/**
 * Checks if a variable is a function.
 *
 * (from http://stackoverflow.com/a/7356528)
 * @param functionToCheck The function to check.
 * @returns {boolean} True if found, false if not.
 */
function isFunction(functionToCheck) {
    var getType = {};
    return (functionToCheck && getType.toString.call(functionToCheck) === '[object Function]') ? true : false;
}

/**
 * Checks if a variable is a string.
 * @param str The string to check.
 * @returns {boolean} Returns true if it is a string, and false if not.
 */
function isString(str) {
    return (typeof str !== 'undefined') && (typeof str == 'string' || str instanceof String);
}

/**
 * Checks if a variable is an array.
 * @param arr The array to check.
 * @returns {boolean} Returns true if it is an array, false if not.
 */
function isArray(arr) {
    return (typeof arr !== 'undefined') && (arr.constructor === Array);
}

/**
 * Checks if a variable is defined AND not null.
 * @param obj The object to check.
 * @returns {boolean} True if it is something, false if not.
 */
function isSomething(obj) {
    if (typeof obj === 'undefined' || obj == null) return false;
    return true;
}

/**
 * An easy way of getting the url parameters.
 *
 * (from http://stackoverflow.com/a/8649003/2990656)
 * @returns {*} Returns an object where each key is a key from the parameters,
 * and each value is its corresponding value.
 */
function getURLParameters() {
    var search = location.search.substring(1);
    return (
        search ? JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}',
            function (key, value) {
                return key === "" ? value : decodeURIComponent(value)
            }) : {}
    )
}

/**
 * Does the check for undefined and stuff.
 * @param field The field to check.
 * @param value The default value to give it if it isn't defined.
 */
function def(field, value) {
    return (typeof field === 'undefined') ? value : field;
}


/**
 * Checks if a field in an object in an array contains a value.
 *
 * Example, given an array (arr):
 *      [ {first: 'a', second: 'b'}, {first: 'c', second: 'd'} ]
 * Calling hasFieldVal(arr, 'first', 'a') will return true, and calling hasFieldVar(arr, 'first', 'b') will
 * return false.
 * @param arr The array to check.
 * @param field The field in the object in the array.
 * @param val The value of the field in the object in the array.
 * @returns {boolean} True if found, false if not.
 */
var hasFieldVal = function (arr, field, val) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i][field] == val) return true;
    }
    return false;
};

/**
 * Gets an object from an array that has a field equal to a value, or null if not found.
 *
 * Example, given an array (arr):
 *      [ {first: 'a', second: 'b'}, {first: 'c', second: 'd'} ]
 * Calling getIn(arr, 'first', 'a') will return {first: 'a', second: 'b'},
 * and calling getIn(arr, 'first', 'b') will return null.
 * @param arr The array to look in.
 * @param field The field to look for.
 * @param val The value the field should be.
 * @returns {*|null} Returns the object if found, or null if not.
 */
var getIn = function(arr, field, val) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i][field] == val) return arr[i];
    }
    return false;
};

/**
 * Removes an object from an array with a field equal to a value.
 *
 * Example, given an array (arr):
 *      [ {first: 'a', second: 'b'}, {first: 'c', second: 'd'} ]
 * Calling removeFrom(arr, 'first', 'a') will result in arr being [ {first: 'c', second: 'd'} ]
 * and calling removeFrom(arr, 'first', 'b') will result in no change.
 * @param arr The array to look through.
 * @param field The field to check for.
 * @param val The value to compare against.
 */
var removeFrom = function(arr, field, val) {
    for (var i = 0; i < arr.length; i++) if (arr[i][field] == val) arr.splice(i, 1);
};

if (typeof String.prototype.startsWith != 'function') {
    // see below for better implementation!
    String.prototype.startsWith = function (str){
        return this.indexOf(str) == 0;
    };
}var ComponentManager = function(form) {

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

};/**
 * Manages api calls with timeouts. This was created to avoid making too many api
 * calls in quick succession.
 * @param api_url The base url of the api to call. Can be changed later.
 * @param $http The angular http object for sending calls.
 * @constructor
 */
var ApiCalls = function(api_url, $http) {

    this.base_url = api_url;

    var api_calls = this;

    // The timers for calls currently being executed.
    var timeouts = [];

    // The list of calls that can be made.
    var calls = [];

    var can_make_calls = true;

    this.log_activity = true;

    var log = function() {
        if (!api_calls.log_activity) return;
        log.apply(this, arguments);
    }

      /////////////////////
     // Call Management //
    /////////////////////

    /**
     * Registers a new call for the api.
     * @param name The name to use the call by. Can be any string.
     * @param method The method to use (post/get/jsonp).
     * @param string The route to use for the api call.
     * @param timeout The timeout to use between calls.
     * @param requires_data True if this call needs data, false if not.
     */
    this.addCall = function(name, method, string, timeout, requires_data) {
        if (hasFieldVal(calls, "name", name)) {
            log("Can't add call " + name + ", because it is already registered.");
            return;
        }
        if (!validMethod(method)) {
            log("Can't add call " + name + ", because '" + method + "' isn't a valid method.");
            return;
        }
        if (typeof timeout === 'undefined') timeout = 1000;
        if (typeof requires_data === 'undefined') requires_data = true;
        calls.push({
            name: name,
            method: method,
            string: string,
            has_params: string.indexOf('{0}') != -1,
            requires_data: requires_data,
            timeout: timeout
        });
    };

    /**
     * Cancels every call that is pending.
     */
    this.cancelAll = function() {
        for (var i = 0; i < timeouts.length; i++) {
            window.clearTimeout(timeouts[i].timeout);
        }
        timeouts = [];
    };

    /**
     * Stops the execution of a specific call.
     * @param call The call to stop.
     */
    var stopCall = function(call) {
        var timeout = getIn(timeouts, 'call', call);
        if (!timeout) return;
        clearTimeout(timeout.timeout);
        removeFrom(timeouts, 'call', call);
    };

    /**
     * Prevents this object from making any more calls. The calls already pending will
     * still be executed unless cancelAll is called first.
     */
    this.stopAddingCalls = function() {
        can_make_calls = false;
    };

    /**
     * Lets this object start making calls again.
     */
    this.startAddingCalls = function() {
        can_make_calls = true;
    };

      ///////////
     // Misc. //
    ///////////

    /**
     * Checks if a given method is valid. Currently, only get/post/jsonp.
     * @param method The method to check.
     * @returns {boolean} True if it is valid, false if not.
     */
    var validMethod = function(method) {
        return isSomething(method) && (method == 'get' || method == 'post' || method == 'jsonp');
    };

    /**
     * Replaces the placeholders in the route string with the parameters. The number of parameters
     * in the string AND the number of parameters given MUST match, or the call will not go through.
     * @param str The route string.
     * @param params The parameters to place into the string.
     * @returns {string|boolean} The string if all went well, or false if not.
     */
    var replaceParams = function(str, params) {
        var i = 0;
        var s = str + "";
        while (s.indexOf("{" + i + "}") != -1) {
            if (params.length <= i) return false;
            s = s.replace("{" + i + "}", params[i]);
            i++;
        }
        return s;
    };

    /**
     * Called once a call has been made to the api. Removes the timeout id from the list,
     * and performs the callback with the data.
     * @param call The call to complete.
     * @param data The data received.
     * @param cb The callback function.
     */
    var done = function(call, data, cb) {
        removeFrom(timeouts, 'call', call);
        cb(data);
    };

      /////////////////////
     // Making the Call //
    /////////////////////

    /**
     * If able to make the call, this function makes it. Returns a reference to itself so that
     * success and error calls can be chained from it.
     * @param name The name of the call to make.
     * @param data The data to pass to the call. Can be null or undefined if no data is needed for the call.
     * @param params The parameters to place in the url. Can be null or undefined if no parameters are needed.
     * @returns A reference to this function for success and error chaining.
     */
    this.makeCall = function(name, data, params) {

        if (!can_make_calls) return this;

          ////////////
         // Fields //
        ////////////

        var make_call = this;

        var s_callback = null;
        var e_callback = null;

        var call_str = null;

        var has_error = false;

        var call = getIn(calls, 'name', name);

          ////////////////
         // Validation //
        ////////////////

        var err_ret = function(str) {
            log("Can't make call '" + name + "', because " + str);
            has_error = true;
            return make_call;
        };

        // First, make sure the call that they're trying to make exists.
        if (!call) return err_ret("it isn't registered.");

        // Check to make sure data was given.
        if (call.requires_data && !isSomething(data)) return err_ret("no data was given.")

        // Check if call needs parameters changed.
        if (call.has_params) {
            if (isString(params)) params = [params];
            if (!isArray(params)) return err_ret("it requires parameters, but none were given.");
            var s = replaceParams(call.string, params);
            if (!s) return err_ret("it requires more parameters than were given.");
            call_str = s;
        } else call_str = call.string;


          ///////////////////////
         // Callback Chaining //
        ///////////////////////

        // This will be called internally on success.
        var suc = function(data) {
            if (isFunction(s_callback)) s_callback(data);
        };

        // This will be called internally on error.
        var err = function(data) {
            if (isFunction(e_callback)) e_callback(data);
        };

        // Called on success.
        this.success = function(callback) {
            if (!isFunction(callback)) return make_call;
            s_callback = callback;
            return make_call;
        };

        // Called on error.
        this.error = function(callback) {
            if (!isFunction(callback)) return make_call;
            if (has_error) {
                // There is already an error detected. Call the error function now, since
                // it won't get called in the future.
                callback("Call never sent.");
            }
            e_callback = callback;
            return make_call;
        };

          /////////////////////
         // Making the Call //
        /////////////////////

        // Start the timeout for new calls.
        timeoutCall(call, call_str, data, suc, err);

        // After initial call, return a reference to itself for chaining.
        return make_call;
    };

    /**
     * Called internally by makeCall. This starts the timeout for a new api call and will call the
     * success or error callback functions upon completion.
     * @param call The call to be made.
     * @param str The complete url string to use.
     * @param data The data to send.
     * @param suc A success callback.
     * @param err An error callback.
     */
    var timeoutCall = function(call, str, data, suc, err) {
        // Stop the current call if one is in progress.
        stopCall(call);

        // Set up the new timeout for the call.
        var t = setTimeout(function() {
            log("Making api call to '" + api_calls.base_url + str + "' with the following data: ", data);
            $http[call.method](api_calls.base_url + str, data)
                .success(function (data) {
                    log("The api call to '" + api_calls.base_url + str + "' was a success!", data);
                    done(call, data, suc);
                })
                .error(function (data, b, c, d) {
                    log("BLAH", data, b, c, d);
                    log("The api call to '" + api_calls.base_url + str + "' failed!", data);
                    done(call, data, err);
                });
        }, call.timeout);

        // Add it to the timeouts.
        timeouts.push({
            call: call,
            timeout: t
        });
    };

};

/**
 *  The order app.
 */
var app = angular.module('order', []);

app.controller('FormController', function ($scope, $filter, $timeout, $http) {

    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Constants and Variables //////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    this.antony = "http://76.115.226.174/";
    this.hero = "http://peaceful-beyond-1028.herokuapp.com/";

    this.BASE_URL = this.antony;
    //this.BASE_URL = "http://76.115.226.174/"; // Anthony's IP.

    var form = this;

    this.manager = new ComponentManager(this);


    this.section = 0;

      /////////////////////////////////
     // Loading and Available Flags //
    /////////////////////////////////

    this.next_section_loading = false;
    this.next_section_available = false;
    this.calculating_price = false;
    this.is_loading_prev_order = false;
    this.changes_made = true;
    this.has_been_saved = false;
    this.is_saving = false;
    this.loading_additions = false;


    ///////////////////
    // The Form Data //
    ///////////////////

    /**
     *  This array holds all of the information of the form.
     */
    this.additions = [];
    this.styles = [];
    this.sizes = [];
    this.prebuilt_available = false;
    this.features = ['Duratemp', 'Solid Pine', 'Vinyl', 'Eco Pro'];
    this.noFeature = ['Porch', 'Porch 12/12 Pitch', 'Leanto'];
    this.base_price = 0;
    this.totals = {};
    this.options = {style: '', size: '', feature: '', zone: 0, build_type: ''};
    this.fees = {sales_tax: 0, delivery: 0, advanced: {percent: 0, price: 0} };
    this.customer = { name: '', id: false };
    this.extra = {date: '', site_ready_date: '', delivery_date: '', estimated_time: '', confirmed: false, crew: ''};
    this.order_id = null;
    this.base64 = null;


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////// API Calls ///////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Manages api calls with a timeout to prevent excessive api calling.
    var api = new ApiCalls(this.BASE_URL, $http);
    api.addCall("calculate", "post", "calculate_price/", 2000, true);
    api.addCall("components", "post", "components/", 500, true);
    api.addCall("prices", "jsonp", "prices/?callback=JSON_CALLBACK", 50, true);
    api.addCall("styles", "jsonp", "styles_with_images/?callback=JSON_CALLBACK", 10, false);
    api.addCall("sizes", "jsonp", "sizes/?callback=JSON_CALLBACK", 50, true);
    api.addCall("prebuilt", "jsonp", "prebuilt_available/?callback=JSON_CALLBACK", 10, true);
    api.addCall("save", "post", "sales_orders/save/", 500, true);
    api.addCall("load", "jsonp", "sales_orders/{0}/load/?callback=JSON_CALLBACK", 100, false);

    this.calculatePrice = function() {
        form.calculating_price = true;
        var data = {
            options: form.options,
            additions: form.additions,
            fees: form.fees
        };
        api.makeCall("calculate", data).success(function(data) {
            form.calculating_price = false;
            form.totals = data;
        }).error(function(data) {
            form.calculating_price = false;
        });
    };

    this.getAdditions = function() {
        form.loading_additions = true;
        var data = {
            options: form.options,
            additions: form.additions,
            fees: form.fees
        };
        api.makeCall("components", data).success(function(data) {
            form.additions = data;
            form.loading_additions = false;
        }).error(function(data) {
            form.loading_additions = false;
        });
    };


    this.getPrices = function() {
        form.calculating_price = true;
        var data = {
            style: form.options.style,
            width: form.options.size.width,
            len: form.options.size.len,
            feature: form.options.feature,
            zone: form.options.zone,
            build_type: form.options.build_type
        };
        api.makeCall("prices", data).success(function(data) {
            form.base_price = data.base_price;
            form.getAdditions();
        }).error(function(data) {
            form.calculating_price = false;
        });
    };

    this.getSizes = function() {
        form.sizes = [];
        form.options.size = '';
        form.options.build_type = '';
        var data = {params: {style: form.options.style}};
        api.makeCall("sizes", data).success(function(data) {
            form.sizes = data;
        }).error(function(data) {
            // TODO ?
        });
    };

    this.getPrebuilt = function() {
        form.options.build_type = '';
        var data = {
            params: {
                style: form.options.style,
                width: form.options.size.width,
                len: form.options.size.len
            }
        };
        api.makeCall("prebuilt", data).success(function(data) {
            form.prebuilt_available = data ? data : "AOS";
        }).error(function(data) {
            // TODO ?
        });
    };

    this.saveForm = function() {
        // TODO stuff
    };

    this.loadForm = function(id) {
        // TODO stuff
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////// Watches ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    // Any change to the additions or the fees requires a re-calculation of prices.
    $scope.$watch(
        function(scope) {
            return scope.form.additions;
        },
        function(nv, ov) {
            // TODO? if not object equality, then do nothing? (Implies loading)
            if (nv !== ov) console.log("Not object equality.");
            if (form.next_section_available) form.calculatePrice();
        }
    );

    // When the form goes from having invalid base options to valid ones, then get
    // the prices (which will in turn get the components).
    $scope.$watch(
        function(scope) {
            return scope.form.validBaseOptions();
        },
        function(nv, ov) {
            if (!ov && nv) {
                // Form went from invalid to valid.
                form.getPrices();
            } else if (ov && !nv) {
                // Form is going from valid to invalid.
                form.next_section_available = false;
            }
        }
    );

    // When the style changes, need to get the new sizes.
    $scope.$watch(
        function(scope) {
            return scope.form.options.style;
        },
        function(nv, ov) {
            form.getSizes();
        }
    );

    // When the size changes, need to check if prebuilt is available.
    $scope.$watch(
        function(scope) {
            form.options.size;
        },
        function(nv, ov) {
            if (nv != '' && nv != null) {
                form.getPrebuilt();
            }
        }
    );





    // Startup


    api.makeCall("styles").success(function(data) {
        form.styles = data;
    }).error(function(data) {
        // TODO uh-oh?
    });













































    //////////////////////////////////////
    // Formatting/Display/Random Checks //
    //////////////////////////////////////

    /**
     *  Checks if the initial options are valid.
     */
    this.validBaseOptions = function () {
        if (!this.options.size || this.options.size == '') return false;
        if (!this.options.style.length || !this.options.size || !this.options.zone) return false;
        if (this.prebuilt_available && !this.options.build_type.length || this.options.build_type == '') return false;
        if (this.requiresFeature(this.options.style) && !this.options.feature.length) return false;
        return true;
    };

    /**
     *  Gets a string representing the display size for a given size.
     */
    this.displaySize = function (size) {
        if (size) return size.width + "x" + size.len;
    };

    /**
     *  Whether or not this style of barn requires a feature selection.
     */
    this.requiresFeature = function (style) {
        for (var i = 0; i < this.noFeature.length; i++)
            if (style === this.noFeature[i]) return false;
        return true;
    };



    this.getMoneyString = function(amt) {
        return $filter('currency')(amt, "$")
    }

    //////////////
    // Sections //
    //////////////

    /**
     *  Checks if the given section is selected.
     */
    this.isSelected = function (checkSection) {
        return this.section === checkSection;
    };

    /**
     *  Moves to the next section.
     */
    this.nextSection = function () {
        if (!form.additions.length) return;
        this.section++;
        window.scroll(0, 0);
    };

    /**
     *  Moves to a specific section.
     */
    this.selectSection = function (setSection) {
        this.section = setSection;
    };

    //////////////////
    // Form Objects //
    //////////////////



    /**
     *  Gets the extra stuff.
     *  TODO fix.
     */
    this.getExtra = function () {
        return {
            site_ready_date: $("#siteReadyDate").val(),
            delivery_date: $("#deliveryDate").val(),
            estimated_time: $("#estimatedTime").val(),
            confirmed: $("#confirmedcb").is(":checked"),
            crew: $("#crew").val()
        }
    }



    ///////////////
    // API Calls //
    ///////////////


    /**
     *  Gets the additions array from the server, then recalculates price.
     */
    this.getAdditions = function () {
        if (!form.validBaseOptions()) return;
        var params = {
            options: form.options,
            additions: form.additions,
            fees: form.fees
        };
        form.next_section_loading = true;
        if (!$scope.$$phase) $scope.$apply();
        api.makeCall("components", {data:params})
            .success(function(data) {
                form.additions = data;
                form.next_section_loading = false;
                form.next_section_available = true;
                form.calculatePrice();
            })
            .error(function(data) {

            });
    };

    /**
     *  Sends the current state of the form to the server, then gets the totals
     *  back.
     */
    this.calculatePrice = function () {
        // No need to calculate price if base options are not set.
        if (!form.validBaseOptions()) return;
        form.calculating_price = true;
        var params = {
            options: form.options,
            additions: form.additions,
            fees: form.fees
        };
        api.makeCall("calculate", {data: params})
            .success(function(data) {

                form.totals = data;
                form.calculating_price = false;
            }).
            error(function(data) {

            });
    };


    /**
     *  Gets the prices of base options. Takes an optional callback function
     *  on success.
     */
    this.getPrices = function () {
        // No need to calculate price if base options are not set.
        if (!form.validBaseOptions()) return;

        var params = {
            style: form.options.style,
            width: form.options.size.width,
            len: form.options.size.len,
            feature: form.options.feature,
            zone: form.options.zone,
            build_type: form.options.build_type
        };

        api.makeCall("prices", {params: params})
            .success(function(data) {
                form.base_price = data.base;
                form.getAdditions();
            })
            .error(function(data) {

            });
    };

    /**
     *  Gets the styles and barn images that the form uses on load.
     */
    this.getStartupStyles = function () {
        api.makeCall("styles")
            .success(function(data) {
                form.styles = data;
            })
            .error(function(data) {

            });
    };

    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// Watches //////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     *  Stops watching all base options, and watches only features and styles.
     */

    this.startWatching = function () {

        // On style change, get sizes.
        form.clearStyleWatch = $scope.$watch(
            function (scope) {
                return form.options.style
            },
            function () {
                if (form.is_loading) return;
                form.options.size = ''
                form.prebuilt_available = false;
                api.makeCall("sizes", {params: {style: form.options.style}})
                    .success(function(data) {
                        form.sizes = data;
                    }).error(function(data) {

                    });
            }
        );

        // When options change, get new prices.
        form.clearValidBaseOptionsWatch = $scope.$watch(
            function (scope) {
                return form.validBaseOptions();
            },
            function (newVal, oldVal) {
                if (newVal) form.getPrices();
                if (!newVal) form.next_section_available = false;
            },
            true // objectEquality http://stackoverflow.com/a/15721434
        );

        // When the size changes, check if prebuilt is available.
        form.clearSizeWatch = $scope.$watch(
            function (scope) {
                return form.options.size
            },
            function (newVal) {
                if (newVal == '') {
                    form.options.build_type = '';
                    return;
                }
                if (form.is_loading) return;
                if (form.options.style.length) {

                    var data = {
                        params: {
                            style: form.options.style,
                            width: form.options.size.width,
                            len: form.options.size.len
                        }
                    };

                    api.makeCall("prebuilt", data)
                        .success(function(data) {
                            form.prebuilt_available = data;
                            if (!form.prebuilt_available)
                                form.options.build_type = 'AOS';
                        })
                        .error(function(data) {

                        });
                }
            },
            true // objectEquality http://stackoverflow.com/a/15721434
        );

        // When the additions change, the price needs to be re-calculated.
        form.clearAdditionsWatch = $scope.$watch(
            function (scope) {
                return form.additions
            },
            form.calculatePrice,
            true // objectEquality http://stackoverflow.com/a/15721434
        );

        // When the fees change, recalculate the price.
        form.clearFeesWatch = $scope.$watch(
            function (scope) {
                return form.fees
            },
            form.calculatePrice,
            true // objectEquality http://stackoverflow.com/a/15721434
        );
    }

    form.clearWatches = function () {
        form.clearFeesWatch();
        form.clearAdditionsWatch();
        form.clearStyleWatch();
        form.clearValidBaseOptionsWatch();
        form.clearSizeWatch();
        if (form.clearFormChange) form.clearFormChange();
    }

    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Submitting/Saving/Loading ////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     *  Validates whether or not the form can be submitted/saved.
     */
    this.validateForm = function () {
        var status = {error: false, reason: []};
        // TODO form validation.
        return status;
    }

    /**
     *  Submits the form upon finishing.
     */
    this.submitForm = function () {
        var status = form.validateForm();
        if (status.error) {
            var reasons = "The form cannot be submitted because of the following reasons:\n\n";
            for (var i = 0; i < status.reasons.length; i++)
                reasons += (i + 1) + ": " + status.reasons[i] + "\n";
            alert(reasons);
        } else {
            // TODO: form submission.
            alert('form submitted');
        }
    };

    /**
     *  Gets the object needed to save the entire order.
     */
    this.getSaveObject = function () {
        var obj = {
            options: form.options,
            additions: form.additions,
            fees: form.fees,
            customer: form.getCustomerInfo(),
            extra: form.getExtra(),
            styles: form.styles,
            sizes: form.sizes,
            prebuilt_available: form.prebuilt_available,
            base_price: form.base_price,
            editor: form.editor,
            base64: form.base64
        };
        if (form.order_id != null) obj.order_id = form.order_id;

        return obj;
    }

    /**
     *  Sends the api call out to the server saving the form.
     */
    this.saveForm = function () {
        // Validate form first.
        var err = form.validateForm();
        if (err.error) {
            var str = "The form could not be saved for the following reason";
            if (err.reason.length > 1) str += "s";
            str += ":\n\n";
            for (var i in err.reason) {
                str += err.reason[i] + "\n\n";
            }
            return;
        }
        // Build object to send.
        var obj = form.getSaveObject();

        api.makeCall("save", {data: obj})
            .success(function(data) {
                form.order_id = data.order_id;
            })
            .error(function(data) {

            });
    };


    form.loadOrder = function (id) { // TODO
        api.cancelAll();
        form.clearWatches();
        api.makeCall("load", null, id).success(function(data) {
            console.log("LOADING: ", data);
            $timeout(function() {
                form.startWatching();
                for (var i in data) {
                    if (form.hasOwnProperty(i) && data.hasOwnProperty(i)) {
                        form[i] = JSON.parse(JSON.stringify(data[i]));
                    }

                }
            }, 0).then(function() {
                api.startAddingCalls();
            });
        }).error(function(data) {

        });

        api.stopAddingCalls();
    };


    ////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Start Up //////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    this.getStartupStyles();
    this.startWatching();

    // After the first angular run, run the page load.
    $timeout(pageLoad, 0);


    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// TODOS ////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////


    this.getCustomerName = function () {
        return $("#customerName").val();
    }


    this.getCustomerInfo = function () {
        return {
            name: form.getCustomerName(),
            id: $("#customerId").val()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// Dev Mode ///////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////	
});




app.directive("datePicker", ["$timeout", function ($timeout) {
    return {
        link: function (scope, elem, attrs) {
            $timeout(function () {
                var picker = new Pikaday({
                    field: document.getElementById(attrs.id),
                    firstDay: 1,
                    minDate: new Date("2000-01-01"),
                    maxDate: new Date("2020-12-31"),
                    yearRange: [2000, 2020],
                    format: 'MM/DD/YYYY'
                });
            }, 0);
        }
    }
}]);






var overlay_id = "overlay";
var overlay_draggable_class = "on-blueprint";
var new_draggable_class = "new-draggable";


app.controller("VisualEditorController", function($scope, $timeout) {


    var editor = this;
    var form = $scope.form;

    this.base_width = 660;
    this.pixels_per_foot = 60;
    this.base_width_feet = this.base_width / this.pixels_per_foot;

    this.id_count = 0;
    this.waiting_count = 0;
    this.z_top = 1;
    this.selected_visual = false;

    this.isOpen = false;

    this.visuals = {};
    /*
     Example:
     visual_0: {
         id: "visual_0",
         component_id: 0,
         component_name: '', // For tooltip text
         image_url: '',
         x: 2,
         y: 2,
         rotation: 0,
         z_order: 0
     }
     */

    // This will not be saved, but will be generated whenever the form
    // has an additions change.
    this.component_info = {};


    this.waiting = {
        /*
        waiting_0: {
            id: 'waiting_0',
            component_id: 0
        }
         */
    }

    this.barn = {
        width: 12,
        height: 12,
        padding: 3
    };

    this.getSaveObject = function() {
        return {
            id_count: editor.id_count,
            visuals: editor.visuals,
            barn: editor.barn
        }
    };


    ////////////////////////////
    // Sizing And Positioning //
    ////////////////////////////

    this.pixelsToFeet = function (pixels) {
        return pixels / editor.pixels_per_foot / editor.getScale();
    };

    this.feetToPixels = function(feet) {
        return feet * editor.pixels_per_foot * editor.getScale();
    };

    /**
     * Gets the scale--the amount the actual images need to be scaled to be proportional to
     * the barn being displayed.
     */
    this.getScale = function() {
        return editor.base_width_feet / (editor.barn.width + editor.barn.padding * 2);
    };

    /**
     * Given x and y offsets, calculates the visual's position in feet.
     * This is done so that the visuals don't lose their position upon scaling.
     */
    this.updateVisual = function(visual_id) {
        var visual = editor.visuals[visual_id];
        var span = $("#" + visual_id);
        var over = $("#overlay");
        var left = span.offset().left - over.offset().left;
        var top = span.offset().top - over.offset().top;
        var x = editor.pixelsToFeet(left);
        var y = editor.pixelsToFeet(top);
        visual.x = x;
        visual.y = y;
    };

    this.selectVisual = function(visual) {
        editor.selected_visual = visual;
        var trap = $("#input_trap");
        if (visual) trap.focus().attr("data-id", visual.id);
        else {
            trap.blur();
            ctrl = false;
            shift = false;
        }
    };

    this.applyScalingToAllVisuals = function() {
        for (var i in editor.visuals) {
            if (editor.visuals.hasOwnProperty(i)) {
                editor.setWidthAndHeight(i);
                editor.setVisualBounds(i);
                console.log(i);
            }
        }
    };

    this.getImageDimensions = function(visual) {
        var span = $("#" + visual.id);
        if (span.length == 0) return false;
        var img = span.find("img");
        if (img.length == 0) return false;
        return {
            width: img.get(0).naturalWidth,
            height: img.get(0).naturalHeight
        };
    };

    ////////////
    // Styles //
    ////////////

    this.getVisualStyle = function(visual) {
        return {
            position : 'absolute',
            left : editor.feetToPixels(visual.x) + "px",
            top : editor.feetToPixels(visual.y) + "px",
            'z-index' : (editor.selected_visual == visual) ? editor.z_top : visual.z_order
        }
    };

    this.getBlueprintStyle = function() {
        var width = editor.base_width;
        var height = (editor.barn.height / editor.barn.width) * width;
        var padding = editor.barn.padding * (editor.pixels_per_foot * editor.getScale());
        return {
            width: width + "px",
            height: height + "px",
            padding: padding + "px"
        }
    };


    //////////////
    // Rotation //
    //////////////

    this.flipVisual = function(visual_id) {
        var visual = editor.visuals[visual_id];
        visual.flipped = !visual.flipped;
    };

    this.rotateVisual = function(visual_id) {
        var visual = editor.visuals[visual_id];
        visual.rotation++;
        visual.rotation %= 4;
        $timeout(function() {
            editor.setWidthAndHeight(visual_id);
        }, 0);
    };

    this.setWidthAndHeight = function(visual_id) {
        var span = $("#" + visual_id);
        if (span.length == 0) return;
        var rot = span.attr("data-r");
        var img = span.find("img").first().get(0);
        if (rot % 2 == 0) {
            span.width(img.naturalWidth * editor.getScale());
            span.height(img.naturalHeight * editor.getScale());
        } else {
            span.width(img.naturalHeight * editor.getScale());
            span.height(img.naturalWidth * editor.getScale());
        }
        $(img).width(img.naturalWidth * editor.getScale());
        $(img).height(img.naturalHeight * editor.getScale());
        editor.setVisualBounds(visual_id);
    };

    this.setVisualBounds = function(visual_id) {
        var span = $("#" + visual_id);
        if (span.length == 0) return;
        var over = $("#" + overlay_id);
        if (span.position().left + span.outerWidth() > over.width()) {
            span.offset({
                left: over.offset().left + over.outerWidth() - span.outerWidth(),
                top: span.offset().top
            });
        }
        if (span.position().top + span.outerHeight() > over.height()) {
            span.offset({
                left: span.offset().left,
                top: over.offset().top + over.outerHeight() - span.outerHeight()
            });
        }
    };

      ////////////////////////
     // Visuals Management //
    ////////////////////////


    this.addVisual = function(component_id, x, y, add) {
        console.log(add);
        var component = form.getComponentById(component_id);
        if (add) {
            if (!form.addComponent(component)) {
                var vis = editor.getVisualsByComponent(component_id);
                console.log("vis:", vis);
                if (vis.length > 0) {
                    vis = vis[0];
                    vis.x = x;
                    vis.y = y;
                    console.log("Changed visual stuff.");
                    return;
                }
                console.log("Couldn't add visual.");
                return;
            };
        }
        console.log(component);
        var id = "visual_" + (++editor.id_count);
        editor.visuals[id] = {
            id: id,
            component_id: component.id,
            component_name: component.name,
            x: editor.pixelsToFeet(x),
            y: editor.pixelsToFeet(y),
            rotation: 0,
            z_order: editor.z_top++,
            flipped: false,
            tab_stop: editor.id_count
        };
        editor.selected_visual = editor.visuals[id];
        $scope.$apply();
    };

    this.isSelected = function(visual) {
        return editor.selected_visual == visual;
    };

    /**
     * Gets a list of visual objects associated with a component. Returns false
     * if there are none.
     */
    editor.getVisualsByComponent = function(component) {
        var cid = component.id + "";
        if (cid in form.visuals) {
            return form.visuals[cid];
        }
        return false;
    };

      //////////////////////////
     // Component Management //
    //////////////////////////

    /**
     * Gets an array of objects that show which items should be available in the
     * queue area.
     */
    editor.getQueuedComponents = function() {
        var qd = [];
        var form = $scope.form;
        var components = form.getAllComponents();
        for (var ci in components) {
            var component = components[ci];
            if (!component.image_url) continue;
            var visuals = editor.getVisualsByComponent(component);
            var len = visuals ? visuals.length : 0;
            var qty = form.getQuantity(component);
            for (var i = 0; i < (qty - len); i++) {
                qd.push(component);
            }
        }
        return qd;
    }


      /////////////
     // Watches //
    /////////////

    $scope.$watch(
        function(scope) {
            return scope.form.options.size;
        },
        function(size) {
            console.log("size changed");
            editor.barn.width = size.width;
            editor.barn.height = size.len;
        }
    )

    $scope.$watch(
        function(scope) {
            return editor.barn.width + "x" + editor.barn.height;
        },
        editor.applyScalingToAllVisuals
    );

    $scope.$watch(
        function(scope) {
            return form.editor_obj;
        },
        function(val) {
            if (val && val.barn && typeof val.id_count !== 'undefined' && val.visuals) {
                editor.barn = val.barn;
                editor.id_count = val.id_count;
                editor.visuals = val.visuals;
            }
        }
    )


    // TODO

    editor.getVisualsByComponent = function(component) {
        var x = [];
        var v = editor.visuals;
        for (var i in v) {
            if (v.hasOwnProperty(i) && v[i].component_id == component.id) x.push(v[i]);
        }
        return x;
    };


    editor.getDisplay = function(visual) {
        var comp = form.getComponentById(visual.component_id);
        if (!comp) return '';
        return form.getDisplayImage(comp);
    }

    this.doblah = false;
    this.base64 = ''

    this.exportToImage = function(callback) {
        console.log("export called");
        this.selected_visual = false;
        $timeout(function() {
            html2canvas($("#blueprint").get(0), {
                onrendered: function (canvas) {
                    callback(canvas.toDataURL());
                }
            });
        }, 0);
    };

    $scope.$watch(
        function(scope) {
            return scope.form.additions;
        },
        function() {
            console.log("changed additions");
            editor.checkVisuals();
        },
        true
    )

    this.checkVisuals = function() {
        var components = form.getAllComponents();
        for (var i = 0; i < components.length; i++) {
            var c = components[i];
            var vs = editor.getVisualsByComponent(c);
            var q = form.getQuantity(c);
            while (vs.length > q) {
                var v = vs.pop();
                delete editor.visuals[v.id];
            }
        }
    }

    this.deleteVisual = function(id) {
        if (editor.visuals.hasOwnProperty(id)) {
            var i = editor.visuals[id];
            var component = form.getComponentById(i.component_id);
            delete editor.visuals[id];
            if (!component) return;
            form.removeComponent(component);
        }
    };

    this.additionsChange = function(additions) {
        console.log("Additions have been changed.");
    };

    this.close = function() {
        editor.exportToImage(function(base64) {
            $timeout(function() {
                editor.isOpen = false;
                form.editor = editor.getSaveObject();
                form.base64 = base64;
            });
        });
    };

    this.open = function() {
        console.log("Open clicked.");
        if (editor.isOpen === true) return;
        console.log("Editor now open.");
        editor.isOpen = true;
    };

    this.overlayClicked = function(event) {
        if ($(event.target).attr("id") == 'overlay') editor.selectVisual(false);
    };

    var ctrl = false;
    var shift = false;

    this.keyDown = function(event) {
        console.log("KEY: ", event);

        if (event.keyCode == 16) shift = true;
        else if (event.keyCode == 17) ctrl = true;

        var vis = editor.selected_visual;
        var pixel = editor.pixelsToFeet(5) * (ctrl ? 5 : 1) * (shift ? .2 : 1);
        if (vis) {
            if (event.keyCode == 37) { // left
                vis.x -= pixel;
            } else if (event.keyCode == 38) { // up
                vis.y -= pixel;
            } else if (event.keyCode == 39) { // right
                vis.x += pixel;
            } else if (event.keyCode == 40) { // down
                vis.y += pixel;
            }
        }
    };

    this.keyUp = function(event) {
        if (event.keyCode == 16) shift = false;
        else if (event.keyCode == 17) ctrl = false;
    }


});

app.directive("blueprintDraggable", function() {
    return {
        link: function(scope, elem, attrs) {
            elem = $(elem);
            var id = elem.attr("id");
            elem.addClass("." + overlay_draggable_class);
            var img = $(elem).find("img").first();
            // Just in case the event was already bounded.
            img.off();
            img.on("load", function() {
                scope.editor.setWidthAndHeight(attrs.id);
            });
            elem.draggable({
                containment: "#" + overlay_id,
                stop: function() {
                    scope.editor.updateVisual(attrs.id);
                }
            });

        }
    }
});

app.directive("newDraggable", function() {
    return {
        link: function(scope, elem, attrs) {
            $(elem).draggable({
                revert: "invalid",
                helper: "clone",
                cursor: "crosshair",
                containment: "document"
            }).addClass(new_draggable_class);
        }
    }
});

app.directive("waiting", function() {
    return {
        link: function(scope, elem, attrs) {
            $(elem).draggable({
                revert: "invalid",
                cursor: "crosshair",
                containment: "document",
                helper: "clone"
            }).addClass("waiting");
        }
    }
});

app.directive("blueprint", function() {
    return {
        link: function(scope, elem, attrs) {
            var overlay = $("#overlay");
            overlay.droppable({
                accept: function(blah) {
                    return blah.hasClass(new_draggable_class) || blah.hasClass("waiting");
                },
                drop: function(event, ui) {
                    var drop = ui.helper;
                    var left = drop.offset().left - overlay.offset().left;
                    var top = drop.offset().top - overlay.offset().top;
                    scope.editor.addVisual(ui.helper.attr("data-id"), left, top, ui.helper.hasClass("waiting") ? false : true);
                }
            });
            overlay.mousedown(function(e) {
                if ($(e.target).attr("id") != "overlay") return;
                scope.editor.selectVisual(false);
            });
        }
    }
});

