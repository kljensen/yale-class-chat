defmodule App.Repo.Migrations.TopicChangePgNotify do
  use Ecto.Migration
  @tables ["topics", "submissions", "comments", "ratings"]

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

    create_index = fn table_name ->
     execute """
        CREATE TRIGGER #{table_name}_change_notification_trigger
        AFTER INSERT OR UPDATE OR DELETE
        ON #{table_name}
        FOR EACH ROW
        EXECUTE PROCEDURE row_change_notification();
      """
    end
    Enum.map(@tables, create_index)
  end

  def down do
    drop_trigger = fn table_name ->
      execute "DROP TRIGGER IF EXISTS #{table_name}_change_notification_trigger"
    end
    Enum.map(@tables, drop_trigger)
    execute "DROP FUNCTION IF EXISTS row_change_notification"
  end
end
