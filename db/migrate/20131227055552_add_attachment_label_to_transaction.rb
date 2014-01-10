class AddAttachmentLabelToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :label_file_name, :string
    add_column :transactions, :label_content_type, :string
    add_column :transactions, :label_file_size, :integer
    add_column :transactions, :label_updated_at, :datetime
  end

  def self.down
    remove_column :transactions, :label_file_name
    remove_column :transactions, :label_content_type
    remove_column :transactions, :label_file_size
    remove_column :transactions, :label_updated_at
  end
end
