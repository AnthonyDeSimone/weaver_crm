# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190331170719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "god_mode"
    t.boolean  "reports_only"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "change_orders", force: true do |t|
    t.binary   "json_info"
    t.binary   "revisions"
    t.integer  "sales_order_id"
    t.binary   "image_string"
    t.text     "prices"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "exported",       default: false
    t.boolean  "approved_1",     default: false
    t.boolean  "approved_2",     default: false
    t.integer  "salesperson_id"
  end

  create_table "component_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "component_options", force: true do |t|
    t.string   "name"
    t.decimal  "small_price"
    t.decimal  "large_price"
    t.string   "image_url"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.integer  "build_type",         default: 0
    t.boolean  "active",             default: true
    t.decimal  "height"
    t.decimal  "width"
    t.integer  "sort_order",         default: 0
    t.text     "image_data"
    t.string   "image_content_type"
  end

  create_table "component_subcategories", force: true do |t|
    t.string   "name"
    t.integer  "component_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", force: true do |t|
    t.string   "name"
    t.string   "pricing_type"
    t.decimal  "small_price"
    t.decimal  "large_price"
    t.string   "creator_image_path"
    t.text     "options"
    t.boolean  "requires_quantity"
    t.string   "form_type"
    t.string   "image_url"
    t.integer  "component_subcategory_id"
    t.integer  "style_key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "build_type",               default: 0
    t.integer  "order_id"
    t.decimal  "height"
    t.decimal  "width"
    t.boolean  "active",                   default: true
    t.text     "image_data"
    t.string   "image_content_type"
  end

  create_table "creator_categories", force: true do |t|
    t.integer  "creator_image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creator_category_relationships", force: true do |t|
    t.integer "parent_id"
    t.integer "child_id"
  end

  create_table "creator_images", force: true do |t|
    t.string   "component"
    t.string   "image_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customer_comments", force: true do |t|
    t.text     "comment"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "zip"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.integer  "lead_status"
    t.string   "email"
    t.datetime "quote_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "callback_date"
    t.integer  "sales_team_id"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "secondary_email"
    t.integer  "infusionsoft_id"
  end

  add_index "customers", ["sales_team_id"], name: "index_customers_on_sales_team_id", using: :btree

  create_table "default_options", force: true do |t|
    t.integer  "component_id"
    t.integer  "component_option_id"
    t.integer  "style_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dummy", force: true do |t|
  end

  create_table "installs", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "installs", ["email"], name: "index_installs_on_email", unique: true, using: :btree
  add_index "installs", ["reset_password_token"], name: "index_installs_on_reset_password_token", unique: true, using: :btree

  create_table "key_component_pairs", force: true do |t|
    t.integer  "component_id"
    t.integer  "style_size_finish_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "new_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "new_users", ["email"], name: "index_new_users_on_email", unique: true, using: :btree
  add_index "new_users", ["reset_password_token"], name: "index_new_users_on_reset_password_token", unique: true, using: :btree

  create_table "sales_order_items", force: true do |t|
    t.integer  "quantity"
    t.decimal  "price"
    t.text     "description"
    t.integer  "component_id"
    t.integer  "component_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_orders", force: true do |t|
    t.decimal  "percent_discount"
    t.decimal  "dollar_discount"
    t.decimal  "delivery_charge"
    t.decimal  "tax"
    t.decimal  "deposit"
    t.integer  "build_type"
    t.boolean  "issued",                                              default: false
    t.integer  "status",                                              default: 0
    t.datetime "site_ready_date"
    t.datetime "delivery_date"
    t.integer  "salesperson_id"
    t.integer  "customer_id"
    t.integer  "structure_style_key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "json_info"
    t.datetime "finalized_date"
    t.text     "prices"
    t.boolean  "open",                                                default: true
    t.integer  "follow_ups",                                          default: 0
    t.string   "estimated_time"
    t.boolean  "confirmed",                                           default: false
    t.string   "crew"
    t.datetime "date"
    t.binary   "image_string"
    t.string   "ship_address"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip"
    t.string   "ship_county"
    t.text     "notes"
    t.boolean  "approved"
    t.string   "sales_method"
    t.string   "advertisement"
    t.boolean  "exported",                                            default: false
    t.string   "serial_number"
    t.boolean  "site_ready",                                          default: false
    t.boolean  "working_on_site",                                     default: false
    t.boolean  "scheduled",                                           default: false
    t.boolean  "load_complete",                                       default: false
    t.integer  "modified_by_id"
    t.boolean  "in_fishbowl",                                         default: false
    t.boolean  "production_order_created",                            default: false
    t.string   "dropbox_url"
    t.boolean  "finalized_in_fishbowl",                               default: false
    t.boolean  "final_approval",                                      default: false
    t.integer  "final_approver_id"
    t.datetime "final_approval_time"
    t.boolean  "active",                                              default: true
    t.date     "last_contact_date"
    t.binary   "special_order_items"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "build_status",                                        default: 0
    t.datetime "optional_order_date"
    t.datetime "optional_quote_date"
    t.boolean  "approved_1",                                          default: false
    t.boolean  "approved_2",                                          default: false
    t.datetime "production_order_printed_at"
    t.integer  "outstanding_special_order",                           default: 0
    t.integer  "locked_by_id"
    t.datetime "locked_at"
    t.decimal  "aos_finish_price",            precision: 6, scale: 2
    t.boolean  "initial_approval",                                    default: false
    t.boolean  "finalized",                                           default: false
  end

  create_table "sales_team_connectors", force: true do |t|
    t.integer "salesperson_id"
    t.integer "sales_team_id"
  end

  add_index "sales_team_connectors", ["sales_team_id"], name: "index_sales_team_connectors_on_sales_team_id", using: :btree
  add_index "sales_team_connectors", ["salesperson_id"], name: "index_sales_team_connectors_on_salesperson_id", using: :btree

  create_table "sales_teams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                  default: true
    t.boolean  "track_in_infusionsoft",   default: false
    t.string   "business_name"
    t.string   "address"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.boolean  "show_company_on_invoice", default: false
  end

  create_table "salesmen", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salespeople", force: true do |t|
    t.integer  "account_type"
    t.string   "email",                        default: "",    null: false
    t.string   "encrypted_password",           default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "sales_team_id"
    t.boolean  "active",                       default: true
    t.string   "rep_name"
    t.boolean  "track_in_infusionsoft",        default: false
    t.boolean  "can_approve_orders",           default: false
    t.boolean  "can_download_production_copy", default: false
  end

  add_index "salespeople", ["email"], name: "index_salespeople_on_email", unique: true, using: :btree
  add_index "salespeople", ["invitation_token"], name: "index_salespeople_on_invitation_token", unique: true, using: :btree
  add_index "salespeople", ["reset_password_token"], name: "index_salespeople_on_reset_password_token", unique: true, using: :btree
  add_index "salespeople", ["sales_team_id"], name: "index_salespeople_on_sales_team_id", using: :btree

  create_table "service_tickets", force: true do |t|
    t.text     "notes"
    t.datetime "date"
    t.boolean  "confirmed",                  default: false
    t.boolean  "completed",                  default: false
    t.integer  "salesperson_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "info"
    t.boolean  "site_visit_required"
    t.string   "time_frame"
    t.boolean  "customer_presence_required"
    t.integer  "customer_id"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "materials_not_in_hand"
  end

  create_table "settings", force: true do |t|
    t.string   "fishbowl_ip"
    t.string   "fishbowl_port"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fishbowl_username"
    t.string   "fishbowl_password"
  end

  create_table "special_order_items", force: true do |t|
    t.string   "name"
    t.string   "po_number"
    t.string   "notes"
    t.string   "part_type"
    t.boolean  "required",       default: false
    t.boolean  "ordered",        default: false
    t.integer  "sales_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "structure_style_keys", force: true do |t|
    t.string   "style"
    t.integer  "width"
    t.integer  "length"
    t.integer  "sq_feet"
    t.integer  "ln_feet"
    t.string   "feature"
    t.integer  "starting_roof_pitch"
    t.text     "zone_prices"
    t.text     "door_defaults"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "style_keys", force: true do |t|
    t.integer  "width"
    t.integer  "length"
    t.integer  "sq_feet"
    t.integer  "ln_feet"
    t.decimal  "starting_roof_pitch",      precision: 3, scale: 1
    t.string   "feature"
    t.text     "zone_prices"
    t.text     "door_defaults"
    t.integer  "style_id"
    t.integer  "style_size_finish_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "starting_sidewall_height"
    t.string   "display_feature"
    t.integer  "post_amount"
    t.integer  "beam_height"
    t.integer  "minimum_roof_pitch"
  end

  create_table "style_size_finishes", force: true do |t|
    t.string   "size"
    t.string   "feature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_feature"
  end

  create_table "styles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "isoft_tag_id"
    t.string   "display_name"
    t.integer  "sort_order",     default: 50
    t.boolean  "active",         default: true
    t.boolean  "pavillion",      default: false
    t.boolean  "do_not_compare", default: false
    t.boolean  "large_garage",   default: false
    t.boolean  "real_property",  default: false
  end

  create_table "users", force: true do |t|
    t.integer  "account_type"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_team_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
