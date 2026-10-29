class DropLegacyNotificationsTable < ActiveRecord::Migration[7.1]
  # The old noticed 1.x schema. Noticed 2.x uses noticed_events +
  # noticed_notifications instead. There is no production data and seeds
  # create no notifications, so this table can be dropped outright.
  def up
    drop_table :notifications
  end

  def down
    create_table :notifications do |t|
      t.string :recipient_type, null: false
      t.bigint :recipient_id, null: false
      t.string :type, null: false
      t.jsonb :params
      t.datetime :read_at
      t.timestamps
      t.index [ :read_at ], name: "index_notifications_on_read_at"
      t.index %i[recipient_type recipient_id], name: "index_notifications_on_recipient"
    end
  end
end
