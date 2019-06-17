
var test = {};


app.controller("VisualEditorController", function($scope, $timeout, $window) {


    this.getSaveObject = function() {
        return {
            barn: editor.barn,
            base_width: editor.base_width,
            pixels_per_foot: editor.pixels_per_foot,
            base_width_feet: editor.base_width_feet,
            id_count: editor.id_count,
            visuals: editor.visuals
        }
    };



    this.addCustomVisual = function(left, top) {
        var cpy = JSON.parse(JSON.stringify(editor.custom_visual));
        editor.addVisual(0, left, top, false, cpy);
    };




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
    );

    editor.reopen = function() {
        if (editor.isOpen) {
            $timeout(function() {
                editor.open();
            }, 0);
        }
    };


    // TODO




    editor.getDisplay = function(visual) {
        var comp = form.getComponentById(visual.component_id);
        if (!comp) return '';
        return form.getDisplayImage(comp);
    };

    this.testStuff = function() {
        html2canvas($("#blueprint").get(0), {
            onrendered: function (canvas) {
                $timeout(function() {
                    var ctx = canvas.getContext("2d");
                    var ou = $("#barn-outline");
                    var ov = $("#overlay");
                    var x = ou.offset().left - ov.offset().left - (3 * editor.pixels_per_foot);
                    var y = ou.offset().top - ov.offset().top - (3 * editor.pixels_per_foot);
                    var w = ou.width() + (6 * editor.pixels_per_foot);
                    var h = ou.height() + (6 * editor.pixels_per_foot);

                    var newCanvas = document.createElement("canvas");
                    newCanvas.width = w;
                    newCanvas.height = h;
                    var imageData = ctx.getImageData(x, y, w, h);
                    newCanvas.getContext("2d").putImageData(imageData, 0, 0);
                    dev.log("DATA URL", {url:newCanvas.toDataURL()});
                }, 0);
            }
        });
    };


    $scope.$watch(
        function(scope) {
            return scope.form.additions;
        },
        function() {
            
            editor.checkVisuals();
        },
        true
    );

    this.checkVisuals = function() {
        var components = form.getAllComponents();
        for (var i = 0; i < components.length; i++) {
            var c = components[i];
            var vs = editor.getVisualsByComponent(c);
            var q = form.getQuantity(c);
            if (q < 0) {
                dev.log("LESS THAN 0: ", c, vs, q);
            }
            while (vs.length > q) {
                var v = vs.pop();
                delete editor.visuals[v.id];
            }
        }
    };

    editor.getCloseStyle = function() {
        if (editor.is_closing) {
            return {
                "background-color": "rgba($FORM_ACCENT, 0.25) !important",
                "cursor" : "default"
            }
        }
        return {}
    };



    this.checkCustomText = function() {
        var cus = editor.custom_visual;
        if (!cus.has_text) {
            cus.text = '';
            cus.size = 'specify';
        } else {
            cus.text = "Sample Text";
        }
    };

    editor.getCustomVisualStyle = function(custom) {
        var cus = custom ? custom : editor.custom_visual;
        if (custom && custom.resizing == true) {
            return {};
        }

        // Custom block style
        var c_style = {
            "display": "block",
            "box-sizing": "border-box",
            "padding": "0",
            "margin": "0",
            "cursor": "grab"
        };

        // Inner span style
        var s_style = {
            "display": "block",
            "box-sizing": "border-box",
            "padding": "0",
            "margin": "0",
            "text-align": "center",
            "width": "100%",
            "position" : "relative"
        };

        if (cus.size == 'auto') {
            c_style["display"] = "inline-block";
            c_style["padding"] = "5px";
            s_style["display"] = "block";
            s_style["font-size"] = "1em";
        } else {
            c_style["width"] = cus.width * editor.pixels_per_foot + "px";
            c_style["height"] = cus.height * editor.pixels_per_foot + "px";
            c_style["display"] = "block";
            s_style["display"] = "table";
            s_style["vertical-align"] = "middle";
            s_style["padding"] = "0";
            s_style["width"] = "100%";
            s_style["position"] = "relative";
        }

        if (cus.border) {
            c_style["border"] = "2px solid #374b5f";
        } else {
            c_style["border"] = "none";
        }

        var jc = $("#" + cus.id);
        if (cus == editor.custom_visual) jc = $("#custom_visual");

        var span = jc.find("span").first();

        if (cus.stretch) {
            setTimeout(function() {
                jc.textfill({maxFontPixels: 0});
            }, 50);
        } else {
            s_style["font-size"] = "1em";
        }

        span.css(s_style);
        if (cus.size == 'specify') {
            if (cus.rotation % 2 == 0) {
                span.css("top", (jc.height() / 2 - span.height() / 2) + "px");
                span.width(jc.width());
                span.css("left", "0");
            } else {
                span.width(jc.height())
                span.css("top", "0px");
                span.css("left", (jc.width() / 2 - span.height() / 2) + "px");
            }
        }

        if (cus == editor.custom_visual) {
            span.css({
                "top" : (jc.height() - span.height()) / 2 + "px",
                "left" : "0"
            })

        }


        return c_style;
    };

    // /Testing


    $timeout(function() {
        form.editorLoaded(editor);
        form.editor = editor;
    }, 0);

});


var overlay_id = "overlay";
var overlay_draggable_class = "on-blueprint";


app.directive("newDraggable", function() {
    return {
        link: function(scope, elem, attrs) {
            elem = $(elem);
            elem.draggable({
                revert: "invalid",
                helper: function() {
                    var copy = $(this).clone();
                    copy.detach().appendTo("#visual-editor").css("z-index", 9999);
                    return copy;
                },
                cursor: "grab",
                containment: "#visual-editor"
            })
            .addClass("new-draggable");
            var img = elem.find("img");
            dev.log("new draggable: " + img.length);
            img.on("load", function() {
                var w = this.naturalWidth;
                var h = this.naturalHeight;
                if (w > 50 || h > 50) {
                    // Need to resize.
                    if (w < h) {
                        // resize h
                        img.height(50);
                    } else {
                        // resize width
                        img.width(50);
                    }
                }
            });
            elem.css("outline", "1px dotted gray");
            elem.css("padding-left", "0");
            elem.css("margin-left", "0");

        }
    }
});

app.directive("waiting", function() {
    return {
        link: function(scope, elem, attrs) {
            $(elem).draggable({
                revert: "invalid",
                cursor: "grab",
                containment: "#visual-editor",
                helper:  function() {
                    var copy = $(this).clone();
                    copy.detach().appendTo("#visual-editor").css("z-index", 9999);
                    return copy;
                }
            }).addClass("waiting");
        }
    }
});

app.directive("custom", function() {
    return {
        link: function(scope, elem, attrs) {
            $(elem).draggable({
                revert: "invalid",
                cursor: "grab",
                containment: "#visual-editor",
                helper:  function() {
                    var copy = $(this).clone();
                    copy.detach().appendTo("#visual-editor").css("z-index", 9999);
                    return copy;
                }
            }).addClass("custom_visual");
        }
    }
});


app.directive("blueprint", function() {
    return {
        link: function(scope, elem, attrs) {
            var overlay = $("#overlay");
            overlay.droppable({
                accept: function(blah) {
                    return blah.hasClass("new-draggable") || blah.hasClass("waiting") || blah.hasClass("custom_visual");
                },
                drop: function(event, ui) {
                    var drop = ui.helper;
                    var left = drop.offset().left - overlay.offset().left;
                    var top = drop.offset().top - overlay.offset().top;
                    if (ui.helper.hasClass("custom_visual")) {
                        scope.editor.addCustomVisual(left, top);
                    } else scope.editor.addVisual(ui.helper.attr("data-id"), left, top, ui.helper.hasClass("waiting") ? false : true);

                }
            });
            overlay.mousedown(function(e) {
                if ($(e.target).attr("id") != "overlay") return;
                scope.editor.selectVisual(false);
            });
        }
    }
});


$(window).resize(function() {
    form.editor.reopen();
});