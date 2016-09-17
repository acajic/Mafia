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

ActiveRecord::Schema.define(version: 20150208144402) do

  create_table "action_resolvers", force: true do |t|
    t.string   "type"
    t.integer  "ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "action_result_types", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "description"
    t.boolean  "is_self_generated", default: false
    t.integer  "trigger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_result_types", ["trigger_id"], name: "index_action_result_types_on_trigger_id", using: :btree

  create_table "action_results", force: true do |t|
    t.integer  "action_id"
    t.integer  "action_result_type_id"
    t.text     "result_json"
    t.boolean  "is_automatically_generated", default: false
    t.integer  "city_id"
    t.integer  "day_id"
    t.integer  "resident_id"
    t.integer  "role_id"
    t.boolean  "deleted",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_results", ["action_id"], name: "index_action_results_on_action_id", using: :btree
  add_index "action_results", ["action_result_type_id"], name: "index_action_results_on_action_result_type_id", using: :btree
  add_index "action_results", ["city_id"], name: "index_action_results_on_city_id", using: :btree
  add_index "action_results", ["day_id"], name: "index_action_results_on_day_id", using: :btree
  add_index "action_results", ["resident_id"], name: "index_action_results_on_resident_id", using: :btree
  add_index "action_results", ["role_id"], name: "index_action_results_on_role_id", using: :btree

  create_table "action_types", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "trigger_id"
    t.integer  "action_result_type_id"
    t.text     "default_params_json"
    t.boolean  "require_alive_posting",    default: true
    t.boolean  "require_alive_processing", default: false
    t.boolean  "is_single_required",       default: false
    t.boolean  "can_submit_manually",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "action_types", ["action_result_type_id"], name: "index_action_types_on_action_result_type_id", using: :btree
  add_index "action_types", ["trigger_id"], name: "index_action_types_on_trigger_id", using: :btree

  create_table "actions", force: true do |t|
    t.integer  "resident_id"
    t.integer  "role_id"
    t.integer  "action_type_id"
    t.integer  "day_id"
    t.boolean  "resident_alive"
    t.boolean  "is_processed",   default: false
    t.text     "input_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actions", ["action_type_id"], name: "index_actions_on_action_type_id", using: :btree
  add_index "actions", ["day_id"], name: "index_actions_on_day_id", using: :btree
  add_index "actions", ["resident_id"], name: "index_actions_on_resident_id", using: :btree
  add_index "actions", ["role_id"], name: "index_actions_on_role_id", using: :btree

  create_table "affiliations", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "app_permissions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "app_role_has_app_permissions", force: true do |t|
    t.integer  "app_role_id"
    t.integer  "app_permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_role_has_app_permissions", ["app_permission_id"], name: "index_app_role_has_app_permissions_on_app_permission_id", using: :btree
  add_index "app_role_has_app_permissions", ["app_role_id"], name: "index_app_role_has_app_permissions_on_app_role_id", using: :btree

  create_table "app_roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token_string"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_tokens", ["user_id"], name: "index_auth_tokens_on_user_id", using: :btree

  create_table "cities", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_creator_id"
    t.boolean  "public",            default: true
    t.string   "password"
    t.string   "hashed_password"
    t.string   "password_salt"
    t.boolean  "active",            default: false
    t.boolean  "paused",            default: false
    t.boolean  "paused_during_day"
    t.datetime "last_paused_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "timezone",          default: 0
    t.datetime "last_accessed_at",  default: '2016-09-14 22:08:11'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["user_creator_id"], name: "index_cities_on_user_creator_id", using: :btree

  create_table "city_affiliation_losers", force: true do |t|
    t.integer  "city_id"
    t.integer  "affiliation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "city_affiliation_losers", ["affiliation_id"], name: "index_city_affiliation_losers_on_affiliation_id", using: :btree
  add_index "city_affiliation_losers", ["city_id"], name: "index_city_affiliation_losers_on_city_id", using: :btree

  create_table "city_affiliation_winners", force: true do |t|
    t.integer  "city_id"
    t.integer  "affiliation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "city_affiliation_winners", ["affiliation_id"], name: "index_city_affiliation_winners_on_affiliation_id", using: :btree
  add_index "city_affiliation_winners", ["city_id"], name: "index_city_affiliation_winners_on_city_id", using: :btree

  create_table "city_has_game_end_conditions", force: true do |t|
    t.integer  "city_id"
    t.integer  "game_end_condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "city_has_game_end_conditions", ["city_id"], name: "index_city_has_game_end_conditions_on_city_id", using: :btree
  add_index "city_has_game_end_conditions", ["game_end_condition_id"], name: "index_city_has_game_end_conditions_on_game_end_condition_id", using: :btree

  create_table "city_has_roles", force: true do |t|
    t.integer  "city_id"
    t.integer  "role_id"
    t.text     "action_types_params_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "city_has_roles", ["city_id"], name: "index_city_has_roles_on_city_id", using: :btree
  add_index "city_has_roles", ["role_id"], name: "index_city_has_roles_on_role_id", using: :btree

  create_table "city_has_self_generated_result_types", force: true do |t|
    t.integer  "city_id"
    t.integer  "action_result_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "city_has_self_generated_result_types", ["action_result_type_id"], name: "chshrt_index_on_action_result_type_id", using: :btree
  add_index "city_has_self_generated_result_types", ["city_id"], name: "index_city_has_self_generated_result_types_on_city_id", using: :btree

  create_table "day_cycles", force: true do |t|
    t.integer  "city_id"
    t.integer  "day_start"
    t.integer  "night_start"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "day_cycles", ["city_id"], name: "index_day_cycles_on_city_id", using: :btree

  create_table "days", force: true do |t|
    t.integer  "city_id"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["city_id"], name: "index_days_on_city_id", using: :btree

  create_table "game_end_conditions", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_purchases", force: true do |t|
    t.integer  "payment_log_id"
    t.integer  "user_id"
    t.string   "user_email"
    t.integer  "city_id"
    t.string   "city_name"
    t.datetime "city_started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_purchases", ["city_id"], name: "index_game_purchases_on_city_id", using: :btree
  add_index "game_purchases", ["payment_log_id"], name: "index_game_purchases_on_payment_log_id", using: :btree
  add_index "game_purchases", ["user_id"], name: "index_game_purchases_on_user_id", using: :btree

  create_table "granted_app_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "subscription_purchase_id"
    t.integer  "app_role_id"
    t.text     "description"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "granted_app_roles", ["app_role_id"], name: "index_granted_app_roles_on_app_role_id", using: :btree
  add_index "granted_app_roles", ["subscription_purchase_id"], name: "index_granted_app_roles_on_subscription_purchase_id", using: :btree
  add_index "granted_app_roles", ["user_id"], name: "index_granted_app_roles_on_user_id", using: :btree

  create_table "initial_app_roles", force: true do |t|
    t.string   "description"
    t.string   "email"
    t.string   "email_pattern"
    t.integer  "app_role_id",   default: 4
    t.integer  "priority",      default: 100
    t.boolean  "enabled",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "initial_app_roles", ["app_role_id"], name: "index_initial_app_roles_on_app_role_id", using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "city_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["city_id"], name: "index_invitations_on_city_id", using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "join_requests", force: true do |t|
    t.integer  "city_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "join_requests", ["city_id"], name: "index_join_requests_on_city_id", using: :btree
  add_index "join_requests", ["user_id"], name: "index_join_requests_on_user_id", using: :btree

  create_table "payment_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "user_email"
    t.integer  "payment_type_id"
    t.decimal  "unit_price",       precision: 10, scale: 0
    t.integer  "quantity"
    t.decimal  "total_price",      precision: 10, scale: 0
    t.text     "info_json"
    t.boolean  "is_payment_valid",                          default: true
    t.boolean  "is_sandbox",                                default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_logs", ["payment_type_id"], name: "index_payment_logs_on_payment_type_id", using: :btree
  add_index "payment_logs", ["user_email"], name: "index_payment_logs_on_user_email", using: :btree
  add_index "payment_logs", ["user_id"], name: "index_payment_logs_on_user_id", using: :btree

  create_table "payment_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resident_previous_roles", force: true do |t|
    t.integer  "resident_id"
    t.integer  "previous_role_id"
    t.integer  "day_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resident_previous_roles", ["day_id"], name: "index_resident_previous_roles_on_day_id", using: :btree
  add_index "resident_previous_roles", ["previous_role_id"], name: "index_resident_previous_roles_on_previous_role_id", using: :btree
  add_index "resident_previous_roles", ["resident_id"], name: "index_resident_previous_roles_on_resident_id", using: :btree

  create_table "resident_role_action_type_params_models", force: true do |t|
    t.integer  "resident_id"
    t.integer  "role_id"
    t.integer  "action_type_id"
    t.text     "action_type_params_json"
    t.text     "original_action_type_params_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resident_role_action_type_params_models", ["action_type_id"], name: "index_resident_role_action_type_params_models_on_action_type_id", using: :btree
  add_index "resident_role_action_type_params_models", ["resident_id"], name: "index_resident_role_action_type_params_models_on_resident_id", using: :btree
  add_index "resident_role_action_type_params_models", ["role_id"], name: "index_resident_role_action_type_params_models_on_role_id", using: :btree

  create_table "residents", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "city_id"
    t.integer  "role_id"
    t.integer  "saved_role_id"
    t.boolean  "role_seen",     default: false
    t.boolean  "alive",         default: true
    t.datetime "died_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "residents", ["city_id"], name: "index_residents_on_city_id", using: :btree
  add_index "residents", ["role_id"], name: "index_residents_on_role_id", using: :btree
  add_index "residents", ["saved_role_id"], name: "index_residents_on_saved_role_id", using: :btree
  add_index "residents", ["user_id"], name: "index_residents_on_user_id", using: :btree

  create_table "role_has_action_types", force: true do |t|
    t.integer  "role_id"
    t.integer  "action_type_id"
    t.text     "action_type_params_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_has_action_types", ["action_type_id"], name: "index_role_has_action_types_on_action_type_id", using: :btree
  add_index "role_has_action_types", ["role_id"], name: "index_role_has_action_types_on_role_id", using: :btree

  create_table "role_has_demanded_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "demanded_role_id"
    t.integer  "quantity_min",             default: 0
    t.integer  "quantity_max"
    t.boolean  "is_demanded_per_resident", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_has_demanded_roles", ["demanded_role_id"], name: "index_role_has_demanded_roles_on_demanded_role_id", using: :btree
  add_index "role_has_demanded_roles", ["role_id"], name: "index_role_has_demanded_roles_on_role_id", using: :btree

  create_table "role_has_implicated_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "implicated_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_has_implicated_roles", ["implicated_role_id"], name: "index_role_has_implicated_roles_on_implicated_role_id", using: :btree
  add_index "role_has_implicated_roles", ["role_id"], name: "index_role_has_implicated_roles_on_role_id", using: :btree

  create_table "role_pick_purchases", force: true do |t|
    t.integer  "payment_log_id"
    t.integer  "user_id"
    t.string   "user_email"
    t.integer  "role_pick_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_pick_purchases", ["payment_log_id"], name: "index_role_pick_purchases_on_payment_log_id", using: :btree
  add_index "role_pick_purchases", ["role_pick_id"], name: "index_role_pick_purchases_on_role_pick_id", using: :btree
  add_index "role_pick_purchases", ["user_id"], name: "index_role_pick_purchases_on_user_id", using: :btree

  create_table "role_picks", force: true do |t|
    t.integer  "user_id"
    t.integer  "city_id"
    t.string   "city_name"
    t.datetime "city_started_at"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_picks", ["city_id"], name: "index_role_picks_on_city_id", using: :btree
  add_index "role_picks", ["role_id"], name: "index_role_picks_on_role_id", using: :btree
  add_index "role_picks", ["user_id"], name: "index_role_picks_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.integer  "affiliation_id"
    t.string   "type"
    t.string   "name"
    t.boolean  "is_starting_role", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["affiliation_id"], name: "index_roles_on_affiliation_id", using: :btree

  create_table "subscription_purchases", force: true do |t|
    t.integer  "payment_log_id"
    t.integer  "user_id"
    t.string   "user_email"
    t.integer  "subscription_type"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_purchases", ["payment_log_id"], name: "index_subscription_purchases_on_payment_log_id", using: :btree
  add_index "subscription_purchases", ["user_id"], name: "index_subscription_purchases_on_user_id", using: :btree

  create_table "triggers", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_preferences", force: true do |t|
    t.integer  "user_id"
    t.boolean  "receive_notifications_when_added_to_game", default: true
    t.boolean  "automatically_join_when_invited",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_preferences", ["user_id"], name: "index_user_preferences_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "identifier_url"
    t.string   "hashed_password"
    t.string   "password_salt"
    t.integer  "default_app_role_id",               default: 2
    t.boolean  "email_confirmed",                   default: false
    t.string   "email_confirmation_code"
    t.boolean  "email_confirmation_code_exchanged", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["default_app_role_id"], name: "index_users_on_default_app_role_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["identifier_url"], name: "index_users_on_identifier_url", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
