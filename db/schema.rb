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

ActiveRecord::Schema.define(version: 20160531065917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "computations", force: :cascade do |t|
    t.string   "job_id"
    t.text     "script",                            null: false
    t.string   "working_directory"
    t.string   "status",            default: "new", null: false
    t.string   "stdout_path"
    t.string   "stderr_path"
    t.text     "standard_output"
    t.text     "error_output"
    t.string   "error_message"
    t.integer  "exit_code"
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "patient_id"
  end

  add_index "computations", ["patient_id"], name: "index_computations_on_patient_id", using: :btree

  create_table "data_files", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "handle"
    t.integer  "data_type",  null: false
    t.integer  "patient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "data_files", ["data_type"], name: "index_data_files_on_data_type", using: :btree
  add_index "data_files", ["patient_id"], name: "index_data_files_on_patient_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string   "case_number",                  null: false
    t.integer  "procedure_status", default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "patients", ["case_number"], name: "index_patients_on_case_number", using: :btree
  add_index "patients", ["procedure_status"], name: "index_patients_on_procedure_status", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "action_id",   null: false
    t.integer  "resource_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "permissions", ["action_id"], name: "index_permissions_on_action_id", using: :btree
  add_index "permissions", ["group_id"], name: "index_permissions_on_group_id", using: :btree
  add_index "permissions", ["resource_id"], name: "index_permissions_on_resource_id", using: :btree
  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.string   "path",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "service_id", null: false
  end

  add_index "resources", ["path"], name: "index_resources_on_path", using: :btree
  add_index "resources", ["service_id"], name: "index_resources_on_service_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "uri",                              null: false
    t.string   "token",                            null: false
    t.string   "name"
    t.boolean  "editable_by_user", default: false, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "services", ["uri"], name: "index_services_on_uri", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "owner",      default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_groups", ["group_id"], name: "index_user_groups_on_group_id", using: :btree
  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "plgrid_login"
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.boolean  "approved",               default: false, null: false
    t.text     "proxy"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["plgrid_login"], name: "index_users_on_plgrid_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "computations", "patients"
  add_foreign_key "data_files", "patients"
end
