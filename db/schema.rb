# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_26_124425) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "downloads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "audio_only", default: false
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.text "error", default: "", null: false
    t.text "output_path", default: "", null: false
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.bigint "user_id", null: false
    t.index ["chat_id"], name: "index_downloads_on_chat_id"
    t.index ["created_at"], name: "index_downloads_on_created_at"
    t.index ["status"], name: "index_downloads_on_status"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "allowed"
    t.datetime "created_at", null: false
    t.text "first_name"
    t.text "last_name"
    t.text "role"
    t.bigint "telegram_user_id"
    t.datetime "updated_at", null: false
    t.text "username"
  end

  add_foreign_key "downloads", "users", on_delete: :cascade
end
