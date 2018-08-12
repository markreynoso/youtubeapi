class ChangeDurationToInteger < ActiveRecord::Migration[5.2]
  def change
    change_column :videos, :duration, 'integer USING(duration::integer)'
  end
end
