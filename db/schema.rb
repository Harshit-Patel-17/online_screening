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

ActiveRecord::Schema.define(version: 20150403074529) do

  create_table "answer_sheets", force: :cascade do |t|
    t.integer  "exam_id",       limit: 4
    t.integer  "user_id",       limit: 4
    t.text     "questions",     limit: 65535
    t.text     "answers",       limit: 65535
    t.integer  "score",         limit: 4
    t.datetime "start_time"
    t.string   "start_test_ip", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "answer_sheets", ["exam_id"], name: "index_answer_sheets_on_exam_id", using: :btree
  add_index "answer_sheets", ["user_id"], name: "index_answer_sheets_on_user_id", using: :btree

  create_table "exam_questions", force: :cascade do |t|
    t.integer  "exam_id",     limit: 4
    t.integer  "question_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "exam_questions", ["exam_id"], name: "index_exam_questions_on_exam_id", using: :btree
  add_index "exam_questions", ["question_id"], name: "index_exam_questions_on_question_id", using: :btree

  create_table "exams", force: :cascade do |t|
    t.integer  "duration_mins",                limit: 4
    t.string   "college_name",                 limit: 255
    t.string   "exam_name",                    limit: 255
    t.date     "date"
    t.time     "time"
    t.text     "question_count_per_weightage", limit: 65535
    t.integer  "total_marks",                  limit: 4
    t.string   "status",                       limit: 255
    t.time     "start_window_time"
    t.time     "end_window_time"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "privileges", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "role_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "privileges", ["role_id"], name: "index_privileges_on_role_id", using: :btree
  add_index "privileges", ["user_id"], name: "index_privileges_on_user_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "question",                limit: 65535
    t.text     "options",                 limit: 65535
    t.string   "answers",                 limit: 255
    t.integer  "weightage",               limit: 4
    t.string   "qtype",                   limit: 255
    t.integer  "no_of_options",           limit: 4
    t.string   "image",                   limit: 255
    t.integer  "question_appeared_count", limit: 4,     default: 0
    t.integer  "correct_response_count",  limit: 4,     default: 0
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "role_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "student_id",             limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "phone_no",               limit: 255
    t.string   "degree",                 limit: 255
    t.integer  "passing_year",           limit: 4
    t.date     "date_of_birth"
    t.string   "registration_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "answer_sheets", "exams"
  add_foreign_key "answer_sheets", "users"
  add_foreign_key "exam_questions", "exams"
  add_foreign_key "exam_questions", "questions"
  add_foreign_key "privileges", "roles"
  add_foreign_key "privileges", "users"
end
