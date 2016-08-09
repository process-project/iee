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

ActiveRecord::Schema.define(version: 20160809085712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_methods", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "access_policies", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "access_method_id", null: false
    t.integer  "resource_id",      null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["access_method_id"], name: "index_access_policies_on_access_method_id", using: :btree
    t.index ["group_id"], name: "index_access_policies_on_group_id", using: :btree
    t.index ["resource_id"], name: "index_access_policies_on_resource_id", using: :btree
    t.index ["user_id"], name: "index_access_policies_on_user_id", using: :btree
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
    t.index ["patient_id"], name: "index_computations_on_patient_id", using: :btree
  end

  create_table "data_files", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "handle"
    t.integer  "data_type",  null: false
    t.integer  "patient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_type"], name: "index_data_files_on_data_type", using: :btree
    t.index ["patient_id"], name: "index_data_files_on_patient_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "parent_group_id"
    t.index ["parent_group_id"], name: "index_groups_on_parent_group_id", using: :btree
  end

  create_table "patients", force: :cascade do |t|
    t.string   "case_number",                  null: false
    t.integer  "procedure_status", default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["case_number"], name: "index_patients_on_case_number", using: :btree
    t.index ["procedure_status"], name: "index_patients_on_procedure_status", using: :btree
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.string   "path",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "service_id", null: false
    t.index ["path"], name: "index_resources_on_path", using: :btree
    t.index ["service_id"], name: "index_resources_on_service_id", using: :btree
  end

  create_table "service_ownerships", force: :cascade do |t|
    t.integer  "service_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_ownerships_on_service_id", using: :btree
    t.index ["user_id", "service_id"], name: "index_service_ownerships_on_user_id_and_service_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_service_ownerships_on_user_id", using: :btree
  end

  create_table "services", force: :cascade do |t|
    t.string   "uri",        null: false
    t.string   "token",      null: false
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uri"], name: "index_services_on_uri", using: :btree
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "owner",      default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id", using: :btree
    t.index ["user_id"], name: "index_user_groups_on_user_id", using: :btree
  end

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
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["plgrid_login"], name: "index_users_on_plgrid_login", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "computations", "patients"
  add_foreign_key "data_files", "patients"
end
