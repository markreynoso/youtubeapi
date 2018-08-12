class ChangeViewsToReceiveNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:videos, :views, true, nil)
    change_column_null(:videos, :duration, true, nil)
  end
end
