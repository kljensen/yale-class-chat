defmodule App.Repo.Migrations.TopicChangePgNotify do
  use Ecto.Migration

  def up do
    execute """
-- This trigger should be called every time a change
-- to a topic is made. 
CREATE OR REPLACE FUNCTION row_change_notification()
RETURNS trigger AS $$
DECLARE
  current_row RECORD;
  payload TEXT;
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
    current_row := NEW;
  ELSE
    current_row := OLD;
  END IF;
  payload := json_build_object(
      'table', TG_TABLE_NAME,
      'type', TG_OP,
      'data', row_to_json(current_row)
  )::text;
  perform pg_notify(
    'events',
    payload    
  );
  RETURN current_row;
END;
$$ LANGUAGE plpgsql
"""

    execute """
CREATE TRIGGER row_change_notification_trigger
AFTER INSERT OR UPDATE OR DELETE
ON topics
FOR EACH ROW
EXECUTE PROCEDURE row_change_notification();
"""
  end

  def down do
    execute "DROP TRIGGER IF EXISTS row_change_notification_trigger"
    execute "DROP FUNCTION IF EXISTS row_change_notification"
  end
end
