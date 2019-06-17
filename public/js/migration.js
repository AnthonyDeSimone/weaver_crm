// The current version of this app.
var VERSION_NUMBER = 2;

/**
 * An object for dealing with different versions of saved objects. Tries to migrate the
 * data to its best ability.
 * @param load_object
 * @param {number} [version] An optional version to migrate to. Defaults to VERSION_NUMBER.
 * @constructor
 */
var Migrations = function(load_object, version) {

    if (typeof load_object === 'undefined') {
        throw "No object to load.";
    }

    version = def(version, VERSION_NUMBER);

    var me = this;

    // From version.
    var fv = def(load_object.version, 1);

    // To version.
    var tv = version;

    // An object to hold all local migrations.
    var migrations = {};

    this.app = null;
    this.barn = null;
    this.editor = null;
    this.visuals = null;

    /******************************************************************************************************************
     ******************************************************************************************************************
     ******************************************************************************************************************/

    /**
     * Migrates an object from one step to the next.
     * @param {string} name
     * @param {number} place
     * @param {*} obj
     * @returns {boolean}
     */
    var migrate_step = function(name, place, obj) {
        // If our current migration step is already at the version we are going to, then the migration
        // is complete and nothing else needs to be done.
        if (place == tv) {
            return false;
        }
        // Build the name of the function that should be called to migrate this step.
        var func = name + "_";
        if (place < tv) {
            func += "forward_";
        } else {
            func += "backward_";
        }
        func += place + "_";
        place += (place < tv) ? 1 : -1;
        func += place;
        // If this function exists within the migrations, then call it.
        if (migrations.hasOwnProperty(func) && isFunction(migrations[func])) {
            return migrations[func](obj);
        } else {
            // The function didn't exist.
            return false;
        }
    };


    var migrate = function(name, obj) {
        var place = fv;
        //noinspection SpellCheckingInspection
        var mobj = obj;
        while (mobj !== false) {
            mobj = migrate_step(name, place, mobj);
        }
        return mobj;
    };


    /******************************************************************************************************************
     ******************************************************************************************************************
     ******************************************************************************************************************/

    migrations["visual_forward_1_2"] = function(obj) {

    };

    migrations["visual_backward_2_1"] = function(obj) {

    };



    /******************************************************************************************************************
     ******************************************************************************************************************
     ******************************************************************************************************************/

    /******************************************************************************************************************
     ******************************************************************************************************************
     ******************************************************************************************************************/


};

/**
 * Returns a new migrations object.
 * @param load_object
 * @param [version]
 * @returns {Migrations}
 */
Migrations.load = function(load_object, version) {
    return new Migrations(load_object, version);
};