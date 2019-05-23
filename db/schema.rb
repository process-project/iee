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

ActiveRecord::Schema.define(version: 20190509084743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "access_methods", id: :serial, force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "service_id"
    t.index ["service_id"], name: "index_access_methods_on_service_id"
  end

  create_table "access_policies", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "access_method_id", null: false
    t.integer "resource_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_method_id"], name: "index_access_policies_on_access_method_id"
    t.index ["group_id"], name: "index_access_policies_on_group_id"
    t.index ["resource_id"], name: "index_access_policies_on_resource_id"
    t.index ["user_id"], name: "index_access_policies_on_user_id"
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "user_id"
    t.string "user_email"
    t.string "project_name"
    t.string "pipeline_id"
    t.string "pipeline_name"
    t.string "computation_id"
    t.string "pipeline_step_name"
    t.string "message", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "computations", id: :serial, force: :cascade do |t|
    t.string "job_id"
    t.text "script"
    t.string "working_directory"
    t.string "status", default: "created", null: false
    t.string "stdout_path"
    t.string "stderr_path"
    t.text "standard_output"
    t.text "error_output"
    t.string "error_message"
    t.integer "exit_code"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "input_path"
    t.string "output_path"
    t.string "pipeline_step"
    t.string "working_file_name"
    t.integer "pipeline_id"
    t.datetime "started_at"
    t.string "revision"
    t.string "tag_or_branch"
    t.string "run_mode"
    t.string "container_name"
    t.string "container_tag"
    t.string "src_host"
    t.string "dest_host"
    t.json "parameter_values"
    t.string "hpc"
    t.index ["pipeline_id"], name: "index_computations_on_pipeline_id"
  end

  create_table "data_files", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "data_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "output_of_id"
    t.bigint "input_of_id"
    t.bigint "project_id"
    t.index ["data_type"], name: "index_data_files_on_data_type"
    t.index ["input_of_id"], name: "index_data_files_on_input_of_id"
    t.index ["output_of_id"], name: "index_data_files_on_output_of_id"
    t.index ["project_id"], name: "index_data_files_on_project_id"
  end

  create_table "group_relationships", id: :serial, force: :cascade do |t|
    t.integer "parent_id", null: false
    t.integer "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_group_relationships_on_child_id"
    t.index ["parent_id", "child_id"], name: "index_group_relationships_on_parent_id_and_child_id", unique: true
    t.index ["parent_id"], name: "index_group_relationships_on_parent_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false, null: false
  end

  create_table "pipelines", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "iid", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode", default: 0, null: false
    t.string "flow", default: "full_body_scan", null: false
    t.bigint "project_id"
    t.index ["iid"], name: "index_pipelines_on_iid"
    t.index ["project_id", "iid"], name: "index_pipelines_on_project_id_and_iid", unique: true
    t.index ["project_id"], name: "index_pipelines_on_project_id"
    t.index ["user_id"], name: "index_pipelines_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "project_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_name"], name: "index_projects_on_project_name"
  end

  create_table "resource_managers", id: :serial, force: :cascade do |t|
    t.integer "resource_id"
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_resource_managers_on_group_id"
    t.index ["resource_id"], name: "index_resource_managers_on_resource_id"
    t.index ["user_id"], name: "index_resource_managers_on_user_id"
  end

  create_table "resources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.citext "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "service_id", null: false
    t.integer "resource_type", default: 0, null: false
    t.index ["path"], name: "index_resources_on_path"
    t.index ["service_id"], name: "index_resources_on_service_id"
  end

  create_table "service_ownerships", id: :serial, force: :cascade do |t|
    t.integer "service_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_ownerships_on_service_id"
    t.index ["user_id", "service_id"], name: "index_service_ownerships_on_user_id_and_service_id", unique: true
    t.index ["user_id"], name: "index_service_ownerships_on_user_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "uri", null: false
    t.string "token", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uri_aliases", default: [], array: true
    t.index ["uri"], name: "index_services_on_uri"
    t.index ["uri_aliases"], name: "index_services_on_uri_aliases", using: :gin
  end

  create_table "singularity_script_blueprints", force: :cascade do |t|
    t.string "container_name"
    t.string "container_tag"
    t.string "hpc"
    t.string "script_blueprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "singularity_script_blueprints_step_parameters", id: false, force: :cascade do |t|
    t.bigint "singularity_script_blueprint_id", null: false
    t.bigint "step_parameter_id", null: false
  end

  create_table "step_parameters", force: :cascade do |t|
    t.string "label"
    t.string "name"
    t.string "description"
    t.integer "rank"
    t.string "datatype"
    t.string "default"
    t.string "values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.boolean "owner", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plgrid_login"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "proxy"
    t.datetime "proxy_expired_notification_time"
    t.integer "state", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["plgrid_login"], name: "index_users_on_plgrid_login", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "access_methods", "services"
  add_foreign_key "computations", "pipelines"
  add_foreign_key "data_files", "pipelines", column: "input_of_id"
  add_foreign_key "data_files", "pipelines", column: "output_of_id"
  add_foreign_key "data_files", "projects"
  add_foreign_key "group_relationships", "groups", column: "child_id"
  add_foreign_key "group_relationships", "groups", column: "parent_id"
end
