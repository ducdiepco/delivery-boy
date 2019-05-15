class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text     :body,                 null: false
      t.integer  :messenger,            null: false
      t.datetime :time_to_deliver,      null: true
      t.integer  :messenger_user_id,    null: false
      t.integer  :status,               null: false, default: 0
      t.integer  :tried_to_send_times,  null: false, default: 0

      t.timestamps
    end
  end
end
