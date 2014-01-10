class AddShippingOptionsToItem < ActiveRecord::Migration
  def change
  	add_column :items, :bring_it_to_you, :boolean, :default => false
  	add_column :items, :come_and_get_it, :boolean, :default => false
  	add_column :items, :lets_meet_up, :boolean, :default => false
  	add_column :items, :come_to_you, :boolean, :default => false
  	add_column :items, :come_to_me, :boolean, :default => false
  	add_column :items, :done_remotely, :boolean, :default => false

  	say "Add shipping options"
	  Item.all.each do |i|
	  	if i.delivery == 1
	  		i.lets_meet_up = true 
	  	elsif i.delivery == 2
	  		i.bring_it_to_you = true
	  	elsif i.delivery == 3
	  		i.come_and_get_it = true
	  	elsif i.delivery == 4
	  		i.come_to_you = true
	  	elsif i.delivery == 5
	  		i.come_to_me = true
	  	elsif i.delivery == 6
	  		i.done_remotely = true
	  	end
	  	i.save
	  end
	end

end
