class CreateVersionActivities < ActiveRecord::Migration
  def change
    create_table :version_activities do |t|
      t.references :version, index: true, foreign_key: true
      t.integer :invoice_raised_user_id
      t.integer :payment_received_user_id
      t.boolean :is_invoice, default: false
      t.boolean :is_payment, default: false
      t.datetime :invoice_raised_date
      t.datetime :payment_received_date

      t.timestamps null: false
    end
  end
end
