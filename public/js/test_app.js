var VERSION_NUMBER = 2;

/**
 *  The order app.
 */
var app = angular.module('order', []);
var form = null;



app.controller('FormController', function ($scope, $filter, $timeout, $http) {

    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Constants and Variables //////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    this.antony = "http://76.115.226.174/";
    this.hero = "http://weaver-crm.herokuapp.com/";
    this.prod = "/";

    this.BASE_URL = this.hero;

    // Will be set by the visual editor.
    this.editor = null;

    // If a custom size/feature is set.
    this.custom = {
        structure_name: '',
        base_price: 0,
        size: {
            len: 12,
            width: 12
        },
        feature: ''
    };

    this.hasSaved = false;

    this.show_custom = true;

    this.customerSaveErr = false;

    this.components = new ComponentManager();

    form = this;

    this.maximized = false;

    // Manages api calls with a timeout to prevent excessive api calling.
    var api = new ApiCalls(this.BASE_URL, $http);
    api.addCall("calculate", "post", "calculate_price/", 800, true);
    api.addCall("components", "post", "components/", 400, true);
    api.addCall("prices", "jsonp", "prices/?callback=JSON_CALLBACK", 50, true);
    api.addCall("styles", "jsonp", "styles_with_images/?callback=JSON_CALLBACK", 10, false);
    api.addCall("sizes", "jsonp", "sizes/?callback=JSON_CALLBACK", 50, true);
    api.addCall("prebuilt", "jsonp", "prebuilt_available/?callback=JSON_CALLBACK", 10, true);
    api.addCall("save", "post", "sales_orders/save/", 50, true);
    api.addCall("load", "jsonp", "sales_orders/{0}/load/?callback=JSON_CALLBACK", 10, false);


    this.section = 0;
    this.next_section_loading = false;
    this.next_section_available = false;
    this.calculating_price = false;

    this.isSaving = false;

    // The revisions made during this edit of a form.
    this.revisions = {};

    // Should be populated by editor.
    this.editor_obj = {};

    ///////////////////
    // The Form Data //
    ///////////////////

    this.styles = [];
    this.prebuilt_available = false;

    this.features = ['Deluxe', 'Premier', 'Vinyl', 'Custom'];

    this.sizes = [];

    this.getSizes = function() {
        if (form.sizes.length == 0 || form.sizes[0] != "Custom") form.sizes.unshift("Custom");
        if (form.options.size == "Custom") {
            return form.sizes;
        }
        var sel = form.options.size;
        var found = false;
        for (var si in form.sizes) {
            if (form.sizes.hasOwnProperty(si)) {
                var s = form.sizes[si];
                if (s == "custom") {
                    continue;
                }
                if (s.width == sel.width && s.len == sel.len) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            form.options.size = "Custom";
            form.custom.size = sel;
        }
        return form.sizes;
    };

    this.base_price = 0;
    this.totals = {};
    this.options = {
        style: '',
        size: {
            len: 12,
            width: 12
        },
        feature: '',
        zone: 0,
        build_type: '',
        finish: '',
        orientation: '',
        side_out: ''
    };
    this.fees = {
        sales_tax: 6.75,
        delivery: 0,
        advanced: {
            percent: 0,
            price: 0,
            special: ''
        },
        deposit: 0,
        deposit_type: ''
    };
    this.customer = {
        id: 0,
        name: '',
        email: '',
        primary_phone: '',
        secondary_phone: '',
        address: '',
        county: '',
        state: 'OH',
        text: '',
        zip: '',
        shipping_same: true,
        shipping: {
            address: '',
            county: '',
            state: 'OH',
            text: '',
            zip: '',
            city: ''
        },
        city: '',
        sales_method: '',
        advertisement: '',
        status: '1'
    };

    var nc = JSON.parse(JSON.stringify(this.customer));
    this.newCustomer = function() {
        return JSON.parse(JSON.stringify(nc));
    };


    this.extra = {
        date: '',
        site_ready_date: '',
        delivery_date: '',
        estimated_time: '',
        purchase_date: '',
        confirmed: false,
        crew: '',
        notes: '',
        site_ready: false,
        working_on_site: false,
        scheduled: false,
        load_complete: false,
        serial_number: '',
        reference: '',
        additional_notes: ''
    };
    this.order_id = null;


    /**
     * The original order data upon load. Used for making revisions.
     * @type {{}}
     */
    this.original_order = {};


    this.warnings = null;
    this.addWarning = function(cat, msg) {
        if (form.warnings == null) form.warnings = {};
        if (!form.warnings.hasOwnProperty(cat)) form.warnings[cat] = [];
        form.warnings[cat].push(msg);
    };

    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// Functions ////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////
    // Formatting/Display/Random Checks //
    //////////////////////////////////////


    this.hasOptions = function(group) {
        if (group == 'structure') {
            return form.prebuilt_available || form.options.style == 'Custom';
        } else if (group == 'feature') {
            return form.options.feature == 'Custom' || form.options.feature == 'Premier';
        } else if (group == 'custom_size') {
            return form.options.size == 'Custom';
        }
        return false;
    };

    /**
     *  Checks if the initial options are valid.
     */
    this.validBaseOptions = function () {
        // Style
        if (!form.options.style) {
            return false;
        }
        if (form.options.style == "Custom" && !form.custom.structure_name) {
            return false;
        }
        // Size
        if (!form.options.size) {
            return false;
        }
        // Prebuilt
        if (form.prebuilt_available && !form.options.build_type) {
            return false;
        }
        // Feature
        if (!form.options.feature) {
            return false;
        }
        if (form.options.feature == "Custom" && !form.custom.feature) {
            return false;
        }
        if (form.options.feature == "Premier" && (!form.options.orientation || !form.options.side_out)) {
            return false;
        }
        // Zone
        //noinspection RedundantIfStatementJS
        if (!form.options.zone) {
            return false;
        }
        return true;
    };

    /**
     *  Gets a string representing the display size for a given size.
     */
    this.displaySize = function (size) {
        if (size == 'Custom') return "Custom";
        if (size) return size.width + "x" + size.len;
    };

    this.getSizeString = function() {
        if (form.options.size == 'Custom') {
            return form.custom.size.width + "x" + form.custom.size.len;
        } else {
            return form.displaySize(form.options.size);
        }
    };

    this.getFeatureString = function() {
        if (form.options.feature == 'Custom') {
            return form.custom.feature;
        } else {
            return form.options.feature;
        }
    };

    this.getStyleString = function() {
        if (form.options.style == 'Custom') {
            return form.custom.structure_name;
        } else {
            return form.options.style;
        }
    };



    //////////////
    // Sections //
    //////////////

    this.currentSection = function() {
        return form.additions[form.section - 1];
    }

    /**
     *  Checks if the given section is selected.
     */
    this.isSelected = function (checkSection) {
        return form.section === checkSection;
    };

    /**
     *  Moves to the next section.
     */
    this.nextSection = function () {

        if (!form.additions.length) return;
        form.section++;
        window.scroll(0, 0);
    };

    /**
     *  Moves to a specific section.
     */
    this.selectSection = function (setSection) {
        form.section = setSection;
        if (setSection == -1) {
            form.findWarnings();
        }
    };

    //////////////////
    // Form Objects //
    //////////////////

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

    var customReg = /^(.*?)(\s*)(\d*)$/

    this.getCustomBaseName = function(component) {
        return customReg.exec(component.name)[1];
    };

    this.getCustomCount = function(components, component) {

        var name = component.name;
        var groups = customReg.exec(name);

        var base = groups[1];

        var num = 0;

        for (var i = 0; i < components.length; i++) {
            if (components[i].name.startsWith(base)) num++;
        }

        return num;
    };

    this.getFirstCustomIndex = function(components, base) {

        for (var i = 0; i < components.length; i++) {
            var groups = customReg.exec(components[i].name);
            if (groups[1] == base) return i;
        }
        return -1;
    };

    this.getLastCustomIndex = function(components, base) {

        for (var i = components.length - 1; i >= 0; i--) {
            var groups = customReg.exec(components[i].name);
            if (groups[1] == base) return i;
        }
        return -1;
    };

    this.renameCustoms = function(components, base) {

        var count = 0;

        for (var i = 0; i < components.length; i++) {
            if (components[i].name.startsWith(base)) count++;
        }


        if (count == 1) {
            components[0].name = base;
        } else {
            var index = form.getFirstCustomIndex(components, base);
            for (var i = index; i < index + count; i++) {
                components[i].name = base + " " + (i - index + 1);
            }
        }

    };


    this.addCustom = function(components, component) {

        var count = form.getCustomCount(components, component);
        var base = form.getCustomBaseName(component);
        var last = form.getLastCustomIndex(components, base);


        var custom = {
            name: base + " " + (count + 1),
            id: count,
            price: 0,
            form_type: component.form_type,
            requires_quantity: component.requires_quantity,
            value: '',
            duplicate: component.duplicate,
            image_url: component.image_url,
            show: component.show
        };

        if (last == components.length - 1) {
            components.push(custom);
        } else {
            components.splice(last + 1, 0, custom);
        }

        form.renameCustoms(components, base);

    };

    this.removeCustom = function(components, component) {

        var base = form.getCustomBaseName(component);
        components.splice(components.indexOf(component), 1);
        form.renameCustoms(components, base);

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

    /**
     *  Increases the quantity of a component if it can.
     */
    this.incrementRange = function (component, key) {
        var max = component.max || Infinity;
        var min = component.min || 0;
        var value = component[key] || min;
        if (value < max) {
            component[key] = value + 1;
        }
    };

    /**
     *  Decreases the quantity of a component if it can.
     */
    this.decrementRange = function (component, key) {
        var min = component.min || 0;
        var value = component[key] || min;
        if (value > min) {
            value--;
            component[key] = value;
        }
    };

    // exists
    var _ex = function(a) {
        return (typeof a !== 'undefined') && (a !== null);
    }
    // find option
    var _fo = function(component, value) {
        if (!_ex(component.options) || !_ex(component.options.length) || component.options.length == 0) return false;
        if (!_ex(component.value)) return false;
        for (var i in component.options) {
            if (!component.options.hasOwnProperty(i)) continue;
            var o = component.options[i];
            if (_ex(o.id) && o.id == value) return o;
        }
        return false;
    }
    // Select first option.
    var _sfo = function(component) {
        if (!_ex(component.options) || !_ex(component.options.length) || component.options.length == 0) return false;
        component.value = component.options[0].id;
        return true;
    }

    /**
     * Tries to add a component. Returns true if one was added, returns
     * false if one could not be added.
     * @param component
     */
    this.addComponent = function(component) {
        var f = component.form_type;
        if (!component.show) return false;
        if (f == 'check_price') {
            if (!_ex(component.value) || component.value == false) return false;
            return component.value = true;
        } else if (f == 'numeric') {
            var max = Infinity;
            if (_ex(component.max)) max = component.max;
            var val = 0;
            if (_ex(component.value)) val = component.value;
            else component.value = 0;
            if (val < max) {
                component.value++;
                return true;
            }
            return false;
        } else if (f == 'text') {
            return false; // TODO
        } else if (f == 'radio') {
            if (_ex(component.value)) {
                if (_fo(component, component.value)) return false;
                else return _sfo(component);
            }
            return _sfo(component);
        }
        return false; // TODO the rest
    };

    /**
     * Returns true either if a quantity was decreased, or if it is already at the lowest
     * quantity.
     * @param component
     * @returns {boolean}
     */
    this.removeComponent = function(component) {
        var f = component.form_type;
        if (f == 'numeric') {
            if (!_ex(component.value)) return false;
            var min = 0;
            if (_ex(component.min)) min = component.min;
            if (component.value > min) {
                component.value--;
                return true;
            }
            return false;
        } else if (f == 'radio') {
            var o  = _fo(component, component.value);
            if (!o) return true;
            for (var i in o) if (_ex(o[i].name) && o[i].name == 'None') {
                component.value = o[i].id;
                return true;
            }
            return false; // TODO? Is ther a way to tell?
        }
        return false; // TODO
    };


    ///////////////
    // API Calls //
    ///////////////


    /**
     *  Gets the additions array from the server, then recalculates price.
     */
    this.getAdditions = function () {
        if (form.isLoading || !form.validBaseOptions()) return;
        var params = {
            options: form.options,
            additions: form.additions,
            fees: form.fees,
            custom: form.custom
        };
        form.next_section_loading = true;
        if (!$scope.$$phase) $scope.$apply();
        api.makeCall("components", {data:params})
            .success(function(data) {
                form.next_section_loading = false;
                form.next_section_available = true;
                if (form.additions.length == 0) form.additions = data;
                else {
                    data = JSON.parse(JSON.stringify(data));
                    for (var i = 0; i < data.length; i++) {
                        form.additions[i] = data[i];
                    }
                }
                form.calculatePrice();
                form.checkSteelOverhead();
                form.checkWindowAcc();
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
        if (form.isLoading) {
            //dev.log("calculating while loading.");
            return;
        }
        form.calculating_price = true;
        var params = {
            options: form.options,
            additions: JSON.parse(JSON.stringify(form.additions)),
            fees: form.fees,
            custom: form.custom,
            base_price: form.base_price,
            paint_stain: form.paint_stain
        };
        api.makeCall("calculate", {data: params})
            .success(function(data) {
                dev.log(data);
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
        if (form.isLoading || !form.validBaseOptions()) return;

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
                console.log("Prices:", copyOf(data));
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
        if (form.isLoading) return;

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

        $scope.$watch(
            function(scope) {
                if (form.getPaintStain) return form.getPaintStain();
                else return '';
                return form.getPaintStain();
            },
            function() {
                if (!form.options || !form.options.build_type) return;
                if (form.options.build_type == 'AOS') {
                    var ps = form.getPaintStain();
                    var p = form.getComponentByPath("Paint & Stain", "Paint", "Paint for AOS");
                    var s = form.getComponentByPath("Paint & Stain", "Stain", "Stain for AOS");
                    if (!p || !s) return;
                    if (!ps) {
                        p.value = null;
                        s.value = null;
                    } else if (ps == 'Paint') {
                        s.value = null;;
                        p.value = true;
                    } else if (ps == 'Stain') {
                        s.value = true;
                        p.value = null;
                    } else if (ps == 'Vinyl') {
                        s.value = null;
                        p.value = null;
                    }
                }
            }
        );

        $scope.$watch(function(scope) {
            return form.paint_stain;
        }, function() {
            form.calculatePrice();
        });

        $scope.$watch(
            function(scope) {
                return form.options.feature + "_" + form.options.zone + "_" + (form.prebuilt_available ? form.options.build_type : "");
            },
            function() {
                if (!form.validBaseOptions()) return;
                form.next_section_available = false;
                form.getAdditions();
            }
        );

        $scope.$watch(
            function(scope) {
                return form.custom.base_price;
            },
            function() {
                form.calculatePrice();
            }
        );

        $scope.$watch(
            function(scope) {
                return form.custom.size.width + "_" + form.custom.size.len;
            },
            function() {
                form.options.size.width = form.custom.size.width;
                form.options.size.len = form.custom.size.len;
            }
        );

        // On style change, get sizes.
        form.clearStyleWatch = $scope.$watch(
            function (scope) {
                return form.options.style
            },
            function () {
                if (form.isLoading) return;
                var original = form.options.size;
                form.options.size = '';
                form.prebuilt_available = false;
                form.isSizeThing = true;
                api.makeCall("sizes", {params: {style: form.options.style}})
                    .success(function(data) {
                        var useSize = null;
                        for (var i in data) {
                            if (data.hasOwnProperty(i) && original) {
                                if (data[i].len == original.len && data[i].width == original.width) {
                                    useSize = data[i];
                                    break;
                                }
                            }
                        }
                        if (useSize != null) {
                            form.options.size = useSize;
                            var pbobj = {
                                params: {
                                    style: form.options.style,
                                    width: form.options.size.width,
                                    len: form.options.size.len
                                }
                            };
                            var bt = form.options.build_type;
                            if (!bt) {
                                bt = "AOS";
                            }
                            console.log("BUILD TYPE:", bt);
                            api.makeCall("prebuilt", pbobj)
                                .success(function(d) {
                                    $timeout(function() {
                                        form.prebuilt_available = d;
                                        if (!form.prebuilt_available)
                                            form.options.build_type = 'AOS';
                                        else form.options.build_type = bt;
                                        form.sizes = data;
                                        form.sizes.unshift("Custom");
                                        if (useSize) {
                                            form.options.size = useSize;
                                        }
                                        form.isSizeThing = false;
                                    }, 0);
                                });
                        } else {
                            $timeout(function() {
                                form.isSizeThing = false;
                            }, 0).then($timeout(function() {
                                form.sizes = data;
                                form.sizes.unshift("Custom");
                            }, 0));
                        }

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
                if (newVal && !form.isLoading) form.getPrices();
                if (!newVal) form.next_section_available = false;
            },
            true // objectEquality http://stackoverflow.com/a/15721434
        );

        form.isSizeThing = false;

        // When the size changes, check if prebuilt is available.
        form.clearSizeWatch = $scope.$watch(
            function (scope) {
                return form.options.size
            },
            function (newVal) {
                if (form.isSizeThing) {
                    return;
                }
                if (newVal == '') {
                    form.options.build_type = '';
                    return;
                }
                if (form.isLoading) return;
                if (form.options.style.length) {

                    var data = {
                        params: {
                            style: form.options.style,
                            width: form.options.size.width,
                            len: form.options.size.len
                        }
                    };

                    form.options.build_type = '';
                    form.options.prebuilt_available = false;

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
            function() {
                form.calculatePrice();

            },
             true// objectEquality http://stackoverflow.com/a/15721434
        );

        // When the fees change, recalculate the price.
        form.clearFeesWatch = $scope.$watch(
            function (scope) {
                return form.fees
            },
            function() {
                form.calculatePrice();
            }, true
        );
    };

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
    this.submitForm = function (bypass) {
        form.saveForm(function(good) {
            if (good && form.extra.confirmed) {
                window.onbeforeunload = null;
                window.location = form.BASE_URL + "sales_orders/" + form.order_id +"/confirmation";
            }
        }, bypass);
    };

    /**
     *  Gets the object needed to save the entire order.
     */
    this.getSaveObject = function () {
        var cus = form.customer;
        if (!form.customer.id || form.customer.id == null) form.customer.id = 0;
        if (cus.shipping_same) {
            // Copy over address info.
            for (var i in cus) if (cus.hasOwnProperty(i) && cus.shipping.hasOwnProperty(i)) cus.shipping[i] = cus[i];
        }
        form.findWarnings();

        var obj = {
            version: VERSION_NUMBER,
            options: copyOf(form.options),
            additions: form.additions,
            fees: form.fees,
            customer: form.customer,
            extra: form.extra,
            styles: form.styles,
            sizes: form.sizes,
            paint_stain: form.paint_stain,
            prebuilt_available: form.prebuilt_available,
            base_price: form.base_price,
            editor_obj: copyOf(form.editor.toJSON()),
            base64: form.editor.base64,
            prices: form.totals.prices,
            custom: form.custom,
            warnings: form.warnings,
            revisions: form.getRevisions()
        };
        if (form.order_id != null) obj.order_id = form.order_id;

        return obj;
    };

    this.canSaveForm = function() {
        if (form.customer.name == '') return false;
        return true;
    };

    this.invoice = function() {
        window.onbeforeunload = null;
        window.location = form.BASE_URL + "sales_orders/" + form.order_id + ".pdf";
    };

    this.saveAndInvoice = function() {
        form.saveForm(function() {
            window.onbeforeunload = null;
            window.location = form.BASE_URL + "sales_orders/" + form.order_id + ".pdf";
        }, form.order_id);
    };

    this.quickSave = function() {
        form.saveForm(null, form.order_id);
    };


    this.fakeSave = function() {
        $timeout(function() {
            form.order_id = 100;
            form.original_order = JSON.parse(JSON.stringify(form.getSaveObject()));
            form.extra.confirmed = true;
            form.hasSaved = true;
        }, 0);
    };

    this.special_order = {};

    this.addSpecialOrderItem = function(name) {
        if (!form.special_order.hasOwnProperty(name)) {
            form.special_order[name] = {
                name: name,
                required: false,
                po_number: -1,
                ordered: false,
                notes: ''
            };
        }
        return form.special_order[name];
    };

    this.removeSpecialOrderItem = function(name) {
        if (form.special_order.hasOwnProperty(name)) {
            delete form.special_order[name];
        }
    };

    this.getNonZeroComponents = function() {
        var comps = [];
        for (var i = 0; i < form.additions.length; i++) {
            var add = form.additions[i];
            for (var s = 0; s < add.subsections.length; s++) {
                var sub = add.subsections[s];
                for (var c = 0; c < sub.components.length; c++) {
                    var comp = sub.components[c];
                    if (form.getQuantity(comp) == 0) {
                        form.removeSpecialOrderItem(comp.name);
                    } else {
                        var so = form.addSpecialOrderItem(comp.name);
                        comps.push(so);
                    }
                    console.log("PUSHING: " + so);
                }
            }
        }
        return comps;
    };

    /**
     * Gets the revisions given the old object, and the new one.
     * @param o The old object.
     * @param n The new object.
     */
    this.getRevisions = function() {

        dev.log("Getting revisions...");

        // Only have revisions if sales order.
        if (form.original_order == null || !form.extra.confirmed || !form.hasSaved) return null;


        var rev = {};
        var o = form.original_order;

        if (!o) {
            return {};
        }

        // Let's go over each part, in order.

        // Style
        var f = o.options.style == "Custom" ? o.custom.structure_name : o.options.style;
        var t = form.options.style == "Custom" ? form.custom.structure_name : form.options.style;
        dev.log("Comparing styles", f, t);
        if (f != t) {
            dev.log("Style changed.");
            rev["style"] = {
                from: f,
                to: t
            };
        }

        // Size
        f = o.options.size == "Custom" ? o.custom.size : o.options.size;
        t = form.options.size == "Custom" ? form.custom.size : form.options.size;
        dev.log("Comparing sizes", f, t);
        if (f.len != t.len || f.width != t.width) {
            dev.log("Size changed.");
            rev["size"] = {
                from: f,
                to: t
            }
        }

        // Base Price
        f = o.options.size == "Custom" ? o.custom.base_price : o.base_price;
        t = form.options.size == "Custom" ? form.custom.base_price : form.base_price;
        dev.log("Comparing base price", f, t);
        if (f != t) {
            dev.log("base price changed.");
            rev["base_price"] = {
                from: f,
                to: t
            }
        }

        // Feature
        f = o.options.feature == "Custom" ? o.custom.feature : o.options.feature;
        t = form.options.feature == "Custom" ? form.custom.feature : form.options.feature;
        dev.log("Comparing features", f, t);
        if (f != t) {
            dev.log("feature change.");
            rev["feature"] = {
                from: f,
                to: t
            }
        }

        // Orientation
        f = o.options.feature == "Custom" ? o.options.orientation : null;
        t = form.options.feature == "Custom" ? form.options.orientation : null;
        dev.log("Comparing orientation", f, t);
        if (f != t) {
            dev.log("Orientation changed.");
            rev["orientation"] = {
                from: f,
                to: t
            }
        }

        // Side Out
        f = o.options.feature == "Custom" ? o.options.side_out : null;
        t = form.options.feature == "Custom" ? form.options.side_out : null;
        dev.log("Comparing side out", f, t);
        if (f != t) {
            dev.log("side out changed.");
            rev["side_out"] = {
                from: f,
                to: t
            }
        }

        // Zone
        dev.log("Comparing zone", o.options.zone, form.options.zone);
        if (o.options.zone != form.options.zone) {
            dev.log("zone changed");
            rev["zone"] = {
                from: o.options.zone,
                to: form.options.zone
            }
        }

        // Paint Stain
        dev.log("Comparing paint stain", o.paint_stain, form.paint_stain);
        if (o.paint_stain != form.paint_stain) {
            dev.log("paint/stain changed");
            rev["paint_stain"] = {
                from: o.paint_stain,
                to: form.paint_stain
            }
        }

        // Prebuilt
        f = o.prebuilt_available ? o.options.build_type : null;
        t = form.prebuilt_available ? form.options.build_type : null;
        dev.log("Comparing build type", f, t);
        if (f != t) {
            dev.log("build type changed..");
            rev["prebuilt"] = {
                from: f,
                to: t
            }
        }

        // If change from/to a custom from/to a non-custom, do nothing.
        if ((form.original_order.options.style == "Custom" && form.options.style != "Custom") ||
            (form.original_order.options.style != "Custom" && form.options.style == "Custom")) {
            rev["additions"] = form.additions;
            return rev;
        }

        // The form additions...
        var fcpy = JSON.parse(JSON.stringify(o.additions));
        var tcpy = JSON.parse(JSON.stringify(form.additions));

        // Why????
        if (fcpy.length != tcpy.length) {
            rev["additions"] = {
                from: fcpy,
                to: tcpy
            }
        }

        var add = [];

        // Do the adding
        var da = function(a, s, c) {
            dev.log("DA: ", a, s, c);
            // If addition isn't there yet, create it.
            var ai = -1;
            for (var i = 0; i < add.length; i++) {
                if (add[i].name == a.name) {
                    ai = i;
                    break;
                }
            }
            if (ai == -1) {
                add.push({
                    name: a.name,
                    subsections: []
                });
                ai = add.length - 1;
            }
            var j = -1;
            for (var i = 0; i < add[ai].subsections.length; i++) {
                if (add[ai].subsections[i].name == s.name) {
                    j = i;
                    break;
                }
            }
            if (j == -1) {
                add[ai].subsections.push({
                    name: s.name,
                    show: s.show,
                    components: (!c) ? s.components : []
                });
                j = add[ai].subsections.length - 1;
            }
            if (c) {
                add[ai].subsections[j].components.push(c);
            }
        };

        // Contains custom
        var cc = function(name, ca) {
            for (var i = 0; i < ca.length; i++) {
                if (ca.value == name) return ca[i];;
            }
            return false;
        };

        var findTextBase = function(sub, base, val) {
            for (var i = 0; i < sub.components.length; i++) {
                var c = sub.components[i];
                if (c.form_type != 'text') continue;
                if (form.getCustomBaseName(c) == base && c.value == val) {
                    return c;
                }
            }
            return null;
        };

        var compDif = function(add, fsub, tsub, neg) {
            fsub = JSON.parse(JSON.stringify(fsub));
            tsub = JSON.parse(JSON.stringify(tsub));

            for (var i = 0; i < tsub.components.length; i++) {
                var c = tsub.components[i];
                if (c.form_type != 'text' || c.value == null) {
                    continue;
                }
                dev.log("Comparing difference: ", c);

                var o = findTextBase(fsub, form.getCustomBaseName(c), c.value);

                // If neg is defined, it means that I am only looking for removed items.
                if (typeof neg !== 'undefined') {
                    // A custom field was removed, flip its quantity and add it.
                    if (o == null) {
                        c.quantity = -c.quantity;
                        da(add, tsub, c);
                    }
                    continue;
                }

                // Something added, put it in as is.
                if (o == null) {
                    da(add, tsub, c);
                    continue;
                }


                var ndif = c.quantity - o.quantity;

                var pdif = c.price - o.price;

                if (ndif != 0 || pdif != 0) {
                    c.quantity = ndif;
                    c.price = pdif;
                    da(add, tsub, c);
                }

            }


        };

        // Additions
        for (var i = 0; i < fcpy.length; i++) {

            // Subsections
            for (var j = 0; j < fcpy[i].subsections.length; j++) {
                var fsub = fcpy[i].subsections[j];
                var tsub = tcpy[i].subsections[j];

                // Find the difference for custom items
                compDif(tcpy[i], fsub, tsub);

                // Find the custom items that were removed.
                compDif(tcpy[i], tsub, fsub, true);

                // Whole subsection added.
                if (!fsub.show && tsub.show) {
                    da(tcpy[i], tsub);
                    continue;
                } else
                // Whole subsection removed.
                if (fsub.show && !tsub.show) {
                    for (var k = 0; k < tsub.components.length; k++) {
                        var tcom = tsub.components[i];
                        if (tcom.form_type == "numeric") {
                            if (!tcom.value) continue;
                            tcom.value = tcom.value || 0;
                            tcom.value = -tcom.value;
                        } else {
                            if (!tcom.quantity) continue;
                            tcom.quantity = -tcom.quantity;
                        }
                        da(tcpy[i], tsub);
                    }
                    continue;
                }

                // Components
                for (var k = 0; k < fcpy[i].subsections[j].components.length; k++) {
                    var fcom = fsub.components[k];

                    if (fcom.form_type == 'text') {
                        continue;
                    }

                    var tcom = tsub.components[k];
                    if (!tcom.show) {

                        // Item was removed.
                        if (fcom.show) {
                            if (fcom.form_type == 'numeric') {
                                if (!fcom.value) continue;
                                fcom.value = fcom.value || 0;
                                fcom.value = -fcom.value;
                            } else {
                                if (!fcom.quantity) continue;
                                fcom.quantity = fcom.quantity || 0;
                                fcom.quantity = -fcom.quantity;
                            }

                            da(tcpy[i], tsub, fcom);
                        }

                        continue;
                    }
                    if (fcom.value != tcom.value || fcom.quantity != tcom.quantity || fcom.price != tcom.price) {
                        var dif = function(fd) {
                            var fn = def(fcom[fd], 0);
                            var tn = def(tcom[fd], 0);
                            var d = tn - fn;
                            tcom[fd] = d;
                        };
                        if (tcom.form_type == 'numeric') {
                            dif('value');
                        } else {
                            dif('quantity');
                        }
                        dif('price');
                        da(tcpy[i], tsub, tcom);
                    }
                }

            }
        }


        rev["additions"] = add;

        return JSON.parse(JSON.stringify(rev));

    };


    /**
     *  Sends the api call out to the server saving the form.
     */
    this.saveForm = function (callback, bypass) {

        if (typeof window.save_unavailable !== 'undefined' && window.save_unavailable) {
            console.log("Attempting to save even though saving is unavailble.");
            return;
        }

        if (!bypass) {
            form.findWarnings();
            if (form.warnings) {
                form.selectSection(-1);
                return;
            }
            //if (form.customer.name == '') {
            //    $timeout(function() {
            //        form.customerSaveErr = true;
            //        form.selectSection(form.additions.length + 1);
            //    }, 0);
            //    if (callback) callback(false);
            //    return;
            //}
        }

        // Build object to send.
        var obj = form.getSaveObject();


        form.isSaving = true;
        api.makeCall("save", {data: obj})
            .success(function(data) {
                form.order_id = data.order_id;
                form.customer.id = data.customer_id;
                $("#select2-customerSelect-container").text(form.customer.name);
                form.isSaving = false;
                form.hasSaved = true;
                if (form.order_id && form.extra.confirmed) {
                    form.original_order = JSON.parse(JSON.stringify(obj));
                }
                if (callback) callback(true);
            })
            .error(function(data) {
                form.isSaving = false;
                if (callback) callback(false);
            });
    };


    form.loadJSON = function(data, id) {
        console.log("Loading form with data: ", data);
        data = copyOf(data);



        form.isLoading = true;
        $timeout(function() {
            if (isDefined(id) && !isDefined(data.order_id)) {
                data.order_id = id;
            }

            form.original_order = copyOf(data);

            // Old and new versions of data do not change when loading the form.
            // It only affects the editor object, so that will be dealt with
            // in there.
            form.additions = data.additions;
            form.base_price = data.base_price;
            form.custom = data.custom;
            form.customer = data.customer;
            data.editor_obj.base64 = data.base64;
            form.editor.loadData(data.editor_obj);
            form.extra = data.extra;
            form.fees = data.fees;
            form.options = data.options;
            form.paint_stain = data.paint_stain;
            form.prebuilt_available = data.prebuilt_available;
            form.revisions = null;
            form.sizes = data.sizes;
            form.styles = data.styles;
            form.totals.prices = data.prices;
            form.warnings = null;

            if (isDefined(data.order_id)) {
                form.order_id = data.order_id;
            } else {
                form.order_id = 0;
            }

            if (data.customer) {
                var c = data.customer;
                $("#customerSelect").append("<option value='" + c.id + "' selected='selected'>" +
                c.name + "</option>");
            }

            $("#select2-state-container").text(getStateById(data.customer.state));
            $("#select2-customerSelect-container").text(data.customer.name);
            $("#select2-state-container").text(data.customer.state);

        }, 0).then(function() {
            $timeout(function() {
                form.isLoading = false;
                form.hasSaved = true;
                form.next_section_available = true;
                form.calculatePrice();
                form.checkSteelOverhead();
                form.checkWindowAcc();
            }, 0).then(function() {

                api.makeCall("sizes", {params: {style: form.options.style}})
                .success(function(data) {
                    form.sizes = data;
                    form.sizes.unshift("Custom");
                    console.log("Form loaded with data: ", form.getSaveObject());
                }).error(function(data) {

                });
            });
        });
    };

    form.loadOrder = function (id) {
        api.makeCall("load", null, [id])
            .success(function(data) {
                form.loadJSON(data, id);
            })
            .error(function(data) {
                //dev.log("error called");
            });
    };


    ////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Start Up //////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    this.getStartupStyles();
    this.startWatching();

    this.editorLoaded = function(ed) {
        dev.log("Editor loaded.");
        form.editor = ed;
        $timeout(function(){}, 50).then(function() {
            $timeout(pageLoad, 0);
        });
    };
    // After the first angular run, run the page load.


    ////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// TODOS ////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////


    this.getCustomerName = function () {
        return $("#customerName").val();
    };


    this.getCustomerInfo = function () {
        return {
            name: form.getCustomerName(),
            id: $("#customerId").val()
        }
    };

    ////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// Dev Mode ///////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    this.dev_mode = false;

    this.isDevMode = function () {
        if (form.dev_mode) return true;
        var p = getURLParameters();
        if (!p) return false;
        return (p.hasOwnProperty("dev_mode") && p.dev_mode == 'true');
    };

    form.doSaveQueryThing = function() {
        $("#textjson").val(JSON.stringify(form.getSaveObject()));
    };

    form.loadOrderjq = function () {
        form.loadOrder($("#orderid").val());
    };

    var timestamp = Date.now();

    form.devQuery = function() {
        if (form.isDevMode()) {
            return timestamp;
        } else return '';
    };

    $scope.$watch(
        function(scope) {
            return form.BASE_URL;
        },
        function(val) {
            api.base_url = val;
        }
    );


    //////////////////////////// TODO SORT //////////////////////////////////////
    form.getAllComponents = function() {
        var components = [];
        for (var ai in form.additions) {
            var section = form.additions[ai];
            for (var ssi in section.subsections) {
                var subsection = section.subsections[ssi];
                for (var ci in subsection.components) {
                    var component = subsection.components[ci];
                    components.push(component);
                }
            }
        }
        return components;
    };



    $timeout(function() {
        //dev.log("calling page load?");
        pageLoad();
    }, 0);

    /**
     * Gets the display image for a component. If no image is being displayed,
     * it will return no_image.
     */
    this.getDisplayImage = function(component) {
        if (!component) return null;
        // The radio option is the only one that has to be treated special here.
        // If it's not a radio, just check for the image url.
        if (!(component.form_type == 'radio')) {
            return component.image_url ? component.image_url : null;
        }

        // This shouldn't happen, but check to see if it has options if no value.
        if (!component.value && component.options.length == 0) {
            return null;
        }

        // Get the value and check if an option with that id exists.
        var val = parseInt(component.value);
        var option = false;
        for (var o in component.options) {
            if (component.options[o].id == val) {
                option = component.options[o];
                break;
            }
        }
        // If an option was found, and it has an image url, return it.
        if (option && option.image_url) {
            return option.image_url;
        }

        // Nothing was found.
        return null;
    };


    /////////////
    // Adding  //
    /////////////

    var addRadio = function(component) {
        var val = def(component.value, -1);
        var option = form.getOption(component, val);
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
        //dev.log("ADDING COMPONENT: ", component);
        if (!component.requires_quantity) return false;
        var max = def(component.max, Infinity);
        var num = def(component.quantity, 0);
        if (num < max) {
            component.quantity = num + 1;
            if (!component.value) component.value = component.options[0].id;
            return true;
        }
        return false;
    };

    var addText = function(component) {
        if (!component.requires_quantity) return false;
        var max = def(component.max, Infinity);
        var num = def(component.quantity, 0);
        if (num < max) {
            component.quantity = num + 1;
            return true;
        }
        return false;
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
        component.value = component.options[component.options.length - 1].id;
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
        var o = form.getOptionIndex(component, id);
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
        if (ind == null) ind = 0;
        if (!component.requires_quantity) return ind > 0 ? 1 : 0;
        var q = def(component.quantity, 0);
        if (q == null) q = 0;
        return q;
    };

    var qText = function(component) {
        var text = def(component.value, '');
        if (text == null) text = '';
        if (!component.requires_quantity) return text.length > 0;
        return def(component.quantity, 0);
    };

    this.getQuantity = function(component) {
        var f = component.form_type;
        var c = component;
        var q = 0;
        if (f.startsWith("check")) q = qCheck(c);
        else if (f == 'radio') q =qRadio(c);
        else if (f == 'numeric') q = qNumeric(c);
        else if (f == 'select') q = qSelect(c);
        else if (f == 'text') q = qText(c);
        if (q == null || typeof q === 'undefined') q = 0;
        return q;
    };

    this.getOptionIndex = function(component, id) {
        for (var i = 0; i < component.options.length; i++) if (component.options[i].id == id) return i;
        return -1;
    };

    this.getOption = function(component, id) {
        var index = form.getOptionIndex(component, id);
        return index == -1 ? null : component.options[index];
    };
////////////////////////////////////////////////////////////////////////////////


    this.setMaximized = function(bool) {
        form.maximized = bool;
        if (form.maximized) {
            $("#contentWrap").css({
                "position" : "fixed",
                "top": "0",
                "left": "0",
                "right": "0",
                "bottom": "0",
                "background-color": "white",
                "z-index" : "7000"
            });
        } else {
            $("#contentWrap").css("position", "absolute");
        }
    };


    this.getSubsectionByComponent = function(component) {
        for (var addition_index in form.additions) {
            var addition = form.additions[addition_index];
            for (var subsection_index in addition.subsections) {
                var subsection = addition.subsections[subsection_index];
                for (var component_index in subsection.components) {
                    var comp = subsection.components[component_index];
                    if (component.id == comp.id) return subsection;
                }
            }
        }
        return false;
    };

    this.getShownComponentsInSubsection = function(aname, sname) {
        var comps = [];
        var sub = form.getSubsectionByPath(aname, sname);
        if (!sub.show) return [];
        for (var i = 0; i < sub.components.length; i++) if (sub.components[i].show) comps.push(sub.components[i]);
        return comps;
    };

    this.showSubsectionComponents = function(aname, sname, show) {
        var sub = form.getSubsectionByPath(aname, sname);
        sub.show = show;
        if (sub) {
            for (var i = 0; i < sub.components.length; i++) sub.components[i].show = show;
        }
    };

    this.textChange = function(component) {
        return; // TODO ?
        if (component.name == "Paint for AOS") {
            if (component.value) {
                var sub = form.getSubsectionByPath("Paint & Stain", "Stain");
                if (sub) sub.show = false;
            }
        } else if (component.name == "Stain for AOS") {
            if (component.value) {
                var sub = form.getSubsectionByPath("Paint & Stain", "Paint");
                if (sub) sub.show = false;
            }
        }
    };

    this.paint_stain = '';

    this.isCoo = function(word) {
        var ps = form.getPaintStain();
        if (word == 'Wood Door Color Option' || word == 'Steel/Overhead Door Color Option' ||
            word == 'Overhead Door Add-Ons' || word == 'Custom' || word == ' Custom')
            return true;
        return word == ps;
    };

    this.getPaintStain = function() {
        if (form.options.feature == 'Vinyl') return 'Vinyl';
        return form.paint_stain;
    };


    this.selectChange = function(component) {
        if (!component.value || component.value == '' || component.value == 0)
            component.quantity = 0;
        if (component.requires_quantity) {
            var qty = form.getQuantity(component);
            component.quantity = qty + 1;
        }
        var sub = form.getSubsectionByComponent(component);
        if (!sub) return;
        if (sub.name.toLowerCase().contains("overhead")) form.checkSteelOverhead();
    };

    this.checkboxChanged = function(component) {
        var sub = form.getSubsectionByComponent(component);
        if (sub.name == "Paint" || sub.name == "Stain") {
            var stain = form.getSubsectionByPath("Paint & Stain", "Stain");
            var paint = form.getSubsectionByPath("Paint & Stain", "Paint");
            if (component.name == "Paint for AOS") {
                for (var i = 0; i < stain.components.length; i++) stain.components[i].value = '';
                if (component.value) {
                    stain.show = false;
                    return;
                } else {
                    for (var i = 0; i < paint.components.length; i++) paint.components[i].value = '';
                    stain.show = true;
                    return;
                }
            } else if (component.name == "Stain for AOS") {
                for (var i = 0; i < paint.components.length; i++) paint.components[i].value = '';
                if (component.value) {
                    paint.show = false;
                    return;
                } else {
                    for (var i = 0; i < stain.components.length; i++) stain.components[i].value = '';
                    paint.show = true;
                    return;
                }
            }
        }
    };

    this.radioChange = function(component) {
        if (component.name == "Roof") {
            var opt = form.getOption(component, component.value);
            if (opt == null) return;
            if (opt.name.startsWith("Metal Roof")) {
                var sub = form.getSubsectionByPath("Roof", "Shingles");
                if (sub != null) {
                    sub.show = false;
                    for (var i = 0; i < sub.components.length; i++) {
                        sub.components[i].show = false;
                    }
                }
                var comp = form.getComponentByPath("Roof", "Roof", "Metal Roof Color");
                if (comp) comp.show = true;
            } else {
                var sub = form.getSubsectionByPath("Roof", "Shingles");
                if (sub != null) {
                    sub.show = true;
                    for (var i = 0; i < sub.components.length; i++) {
                        sub.components[i].show = true;
                    }
                }
                var comp = form.getComponentByPath("Roof", "Roof", "Metal Roof Color");
                if (comp) comp.show = false;
            }
        }
    };


    this.overhead_steel_warning = false;

    this.warnSteelOverhead = function() {
        var sub = form.getSubsectionByPath("Structural", "Structural");
        if (sub) {
            var comp = form.getComponentByName(sub, "Higher Sidewall for Wooden Buildings");
            if (comp.show && !comp.value) {
                form.selectSection(1);
                $timeout(function(){
                    form.overhead_steel_warning = true;
                }, 0);
            } else {
                comp = form.getComponentByName(sub, "Higher Sidewall for Vinyl Buildings");
                if (comp.show && !comp.value) {
                    form.selectSection(1);
                    $timeout(function(){
                        form.overhead_steel_warning = true;
                    }, 0);
                } else form.overhead_steel_warning = false;
            }
        }
    };

    this.checkWindowAcc = function() {
        if (form.options.style == "Custom") {
            return;
        }
        dev.log("Checking window");
        var wa = form.getSubsectionByPath("Windows", "Window Accessories");
        if (!wa) return;
        var sc = null, fc = null;
        var shut = 0, box = 0;
        for (var i = 0; i < wa.components.length; i++) {
            var c = wa.components[i];
            var n = c.name.toLowerCase();
            if (c.name == "Vinyl Shutter Color") sc = c;
            else if (c.name == "Vinyl Flowerbox Color") fc = c;
            else if (n.contains("vinyl")) {
                if (n.contains("shutter") && c.value) shut += +wa.components[i].value;
                if (n.contains("flowerbox") && c.value) box += +wa.components[i].value;
            }
        }
        sc.show = shut > 0;
        fc.show = box > 0;
    };

    this.checkSteelOverhead = function() {
        if (form.options.style == "Custom") {
            return;
        }
        form.overhead_steel_warning = false;
        var qty = 0;
        var tot = 0;
        var sub = form.getSubsectionByPath("Doors", "Steel Entry Door");
        if (sub == null) {
            dev.log("Steel door null.");
            return;
        }
        var comps = sub.components;
        for (var i = 0; i < comps.length; i++) {
            qty += form.getQuantity(comps[i]);
        }
        var s = form.getSubsectionByPath("Paint & Stain", "Steel/Overhead Door Color Option");
        if (s == null) {
            dev.log("steel door paint null");
            return;
        }
        tot += qty;
        if (qty > 0) {
            form.warnSteelOverhead();
            s.show = true;
            for (var i = 0; i < s.components.length; i++) s.components[i].show = true;
        }
        qty = 0;
        sub = form.getSubsectionByPath("Doors", "Overhead Door");
        if (sub == null) {
            dev.log("overhead door null.");
            return;
        }
        comps = sub.components;
        for (var i = 0; i < comps.length; i++) {
            qty += form.getQuantity(comps[i]);
        }
        var s = form.getSubsectionByPath("Paint & Stain", "Overhead Door Add-Ons");
        if (s == null) {
            dev.log("overhead door paint null");
            return;
        }
        tot += qty;
        if (qty > 0) {
            form.warnSteelOverhead();
            s.show = true;
            for (var i = 0; i < s.components.length; i++) s.components[i].show = true;
        }
        if (tot > 0) {
            s = form.getSubsectionByPath("Paint & Stain", "Steel/Overhead Door Color Option");
            if (s == null) {
                dev.log("steel door paint null");
                return;
            }
            tot += qty;
            if (qty > 0) {
                form.warnSteelOverhead();
                s.show = true;
                for (var i = 0; i < s.components.length; i++) s.components[i].show = true;
            }
        }
    };

    this.numericDown = function(component, sub) {
        dev.log("NUMERIC UP", sub.name, component, sub);
        form.decrementRange(component, 'value');
        if (sub.name == "Steel Entry Door" || sub.name == "Overhead Door") {
            form.checkSteelOverhead();
        } else if (sub.name == 'Window Accessories') {
            form.checkWindowAcc();
        }
    };

    this.numericUp = function(component, sub) {
        dev.log("NUMERIC UP", sub.name, component, sub);
        form.incrementRange(component, 'value');
        if (sub.name == "Steel Entry Door" || sub.name == "Overhead Door") {
            form.checkSteelOverhead();
        } else if (component.name == 'Higher Sidewall for Wooden Buildings' ||
            component.name == 'Higher Sidewall for Vinyl Buildings') {
            form.overhead_steel_warning = false;
        } else if (sub.name == 'Window Accessories') {
            form.checkWindowAcc();
        }
    };

    this.getSectionByName = function(name) {
        for (var i = 0; i < form.additions.length; i++) {
            if (form.additions[i].name == name) return form.additions[i];
        }
        return null;
    };

    this.getSubsectionByName = function(section, name) {
        for (var i = 0; i < section.subsections.length; i++) {
            if (section.subsections[i].name == name) return section.subsections[i];
        }
        return null;
    };

    this.getSubsectionByPath = function(aname, sname) {
        var sec = form.getSectionByName(aname);
        if (sec == null) return null;
        return form.getSubsectionByName(sec, sname);
    };

    this.getComponentByName = function(sub, name) {
        for (var i = 0; i < sub.components.length; i++) {
            if (sub.components[i].name == name) return sub.components[i];
        }
        return null;
    };

    this.getComponentByPath = function(aname, sname, cname) {
        var sec = form.getSectionByName(aname);
        if (sec == null) return null;
        var sub = form.getSubsectionByName(sec, sname);
        if (sub == null) return null;
        return form.getComponentByName(sub, cname);
    };



    this.salesOrderStatus = null;


    this.findWarnings = function() {
        form.warnings = null;
        var customer = form.customer;

        // Check customer status.
        if (customer.name == '') {
            form.addWarning("Customer", "There is no customer selected.");
        } else {
            if (!customer.email) form.addWarning("Customer", "No email was given");
            if (!customer.primary_phone) form.addWarning("Customer", "No phone number was given");
            if (!customer.address || !customer.county || !customer.state || !customer.zip || !customer.city)
                form.addWarning("Customer", "Not all address information was given.");
            if (!customer.shipping_same) {
                if (!customer.shipping.address || !customer.shipping.county || !customer.shipping.state
                        || !customer.shipping.zip || !customer.shipping.city)
                    form.addWarning("Customer", "Shipping and billing address are said to be different, " +
                        "but shipping address is incomplete.");
            }
        }

        if ($("#sandbox").find("img").length > 0) {
            form.addWarning("Visual Editor", "There are still items in the visual editor that need to be placed.");
        }

        if (form.options.style == "Custom") {
            return;
        }

        var ps = form.getPaintStain();

        // Loops through and checks to see if the colors are all selected.

        for (var k = 0; k < form.additions.length; k++) {
            var sec = form.additions[k];
            for (var i = 0; i < sec.subsections.length; i++) {
                var sub = sec.subsections[i];
                if (!sub.show) continue;
                if (sub.name == 'Paint' && ps != 'Paint') continue;
                else if (sub.name == 'Stain' && ps != 'Stain') continue;
                else if (sub.name == 'Vinyl' && ps != 'Vinyl') continue;
                for (var j = 0; j < sec.subsections[i].components.length; j++) {
                    var comp = sec.subsections[i].components[j];
                    if (comp.name == "Steel Door Color Option") continue;
                    if (comp.form_type.startsWith("select") &&
                        comp.name.toLowerCase().contains("color") &&
                        comp.show && !comp.value) {
                        form.addWarning(sub.name, comp.name + " needs to be selected.");
                    }
                }
            }
        }

    };


    this.convertToSalesOrder = function() {
        form.extra.confirmed = true;
        form.saveForm(null, true);
    };

    this.getSalesOrderStatus = function() {
        var status = { error: false, reason: []};
        if (form.customer.name == '') {
            status.error = true;
            status.reason.push("There is no customer selected.");
        }
        if ($("#sandbox").find("img").length > 0) {
            status.error = true;
            status.reason.push("There are still items in the visual editor that need to be placed.");
        }

        var colors = {};
        var num = 0;

        for (var k = 0; k < form.additions.length; k++) {
            var sec = form.additions[k];
            for (var i = 0; i < sec.subsections.length; i++) {
                var sub = sec.subsections[i];
                if (!sub.show) continue;
                for (var j = 0; j < sec.subsections[i].components.length; j++) {
                    var comp = sec.subsections[i].components[j];
                    if (comp.name == "Steel Door Color Option") continue;
                    if (comp.form_type.startsWith("select") &&
                        comp.name.toLowerCase().contains("color") &&
                        comp.show && !comp.value) {
                        status.error = true;
                        if (typeof colors[sub.name] == 'undefined') colors[sub.name] = [];
                        colors[sub.name].push(comp.name);
                        num++;
                    }
                }
            }
        }

        if (num > 0) status.colors = colors;

        return status;
    };

    this.autosave = window.setInterval(function() {
        if (form.validBaseOptions() && form.hasSaved && !form.extra.confirmed) form.saveForm(null, true);
    }, 60 * 1000);

    window.onbeforeunload = function() { return true; };

    $timeout(function() {
        form.is_shipping_user = window.is_shipping_user;
    }, 0);


    this.isSaveUnavailable = function() {
        if (typeof window.save_unavailable === 'undefined') {
            return false;
        }
        return window.save_unavailable;
    };

   // $timeout(testData, 0);

}).directive("datePicker", ["$timeout", function ($timeout) {
    return {
        link: function (scope, elem, attrs) {
            $timeout(function () {
                var picker = new Pikaday({
                    field: document.getElementById(attrs.id),
                    firstDay: 0,
                    minDate: new Date("2000-01-01"),
                    maxDate: new Date("2050-12-31"),
                    yearRange: [2000, 2020],
                    format: 'MM/DD/YYYY'
                });
            }, 0);
        }
    }
}]);



////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Page Loading ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// This whole section is just so that if loadOrder is called before angular has
// had time to load its stuff, it will keep track of the order to load until 
// angular has had time to finish. Then, it will load the order.
//

var pageIsLoaded = false;
var orderToLoad = false;

function pageLoad() {
    pageIsLoaded = true;
    if (orderToLoad) {
        loadOrder(orderToLoad);
        orderToLoad = false;
    }
}

function loadOrder(id) {
    //dev.log("Calling load order function with id '" + id + "'");
    // Wait for angular.
    if (!pageIsLoaded) {
        orderToLoad = id;
        //dev.log("Page isn't loaded yet, pushing off order load until done.");
        return;
    }
    // Get the scope.
    var scope = angular.element($("#main")).scope();
    if (!scope) {
        //dev.log("THIS IS THE BAD ERROR", "Scope can't be found, can't load order.");
        return;
    }
    //dev.log("Calling form controllers load.");
    // Load the order.
    scope.form.loadOrder(id);
}
