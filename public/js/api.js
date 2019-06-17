window.dbg = {};

/**
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
        console.log(arguments);
    };

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

        // I'm sorry... This code was so nice for a minute, but here you go....
        if (data && isObject(data)) {
            var tmp = JSON.stringify(data);
            data = JSON.parse(tmp.replace(/Manchester/g, 'Mini').replace(/Newbury/g, 'Cottage'));
        }

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
                    if (data && isObject(data)) {
                        data = JSON.parse(JSON.stringify(data).replace(/Mini/g, 'Manchester').replace(/Cottage/g, 'Newbury'));
                    }
                    log("The api call to '" + api_calls.base_url + str + "' was a success!", data);
                    done(call, data, suc);
                })
                .error(function (data, b, c, d) {
                    if (data && isObject(data)) {
                        data = JSON.parse(JSON.stringify(data).replace(/Mini/g, 'Manchester').replace(/Cottage/g, 'Newbury'));
                    }
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
