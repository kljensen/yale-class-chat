defmodule App.Repo.Migrations.PgNotifyBubbleUp do
  use Ecto.Migration

  @moduledoc """
  Add triggers that result in `pg_notify` messages that
  will "bubble up" so that users can know when changes
  to "children" occur. E.g. a client may "watch" a 
  submission and want to know when its ratings change.
  Or, a client may watch a topic and want to know when
  any of the ratings on any of its submissions changes.

  The bubbles are
  topics < submissions < comments
  topics < submissions < ratings

  If a comment changed, I should get an event that contains
  all the information for its parent submission and its
  parent topic.

  Note that, since this is on a per-row basis, there will
  only ever be one change, we're going to stick that in 
  the `data` key of a JSON object to be consistent with our
  other pg_notify usage. What should a change look like

  If it was a rating change, maybe
  {
    'data': {...the rating object...or comment object...},
    'submission' : {...the submission object for this rating...}
  } -> 'updates:topics:14' channel

  See 
  https://stackoverflow.com/questions/13227142/postgresql-9-2-row-to-json-with-nested-joins

  These functions and triggers produce `pg_notify`
  bodies that look like the following. Notice that
  the user, topic, and submission are embedded.

  ```json
    {
      "table": "ratings",
      "type": "INSERT",
      "data": {
        "id": 80,
        "score": 4,
        "submission_id": 80,
        "user_id": 5,
        "inserted_at": "2020-03-27T19:23:13",
        "updated_at": "2020-03-27T19:23:13",
        "submission": {
          "id": 80,
          "title": "How many woodchucks?",
          "description": "Dave watched as the forest burned up on the hill, only a few miles from her house. The car had been hastily packed and Marta was inside trying to round up the last of the pets. Dave went through his mental list of the most important papers and documents that they couldn't leave behind. He scolded himself for not having prepared these better in advance and hoped that he had remembered everything that was needed. He continued to wait for Marta to appear with the pets, but she still was nowhere to be seen.",
          "slug": null,
          "image_url": "http://i.imgur.com/KONVsYw.jpg",
          "allow_ranking": false,
          "visible": true,
          "topic_id": 16,
          "user_id": 6,
          "inserted_at": "2020-03-27T19:23:13",
          "updated_at": "2020-03-27T19:23:13",
          "topic": {
            "id": 16,
            "title": "Help us design yale.chat!",
            "description": "The website you're using is an experimental piece of software we hope will be helpful during the COVID crisis (and afterward!). This is being developed by SOMers Nick Peranzi and Kyle Jensen. We'd like your advice! What should an app like thisinclude? Right now we're thinking about polls, live chat, private chat, and emojis. (Emojis are top priority.)\n\n    What do you want to see in a communications platform for class? Please tell us!\n\n    ",
            "slug": "2402Help us design yale.chat!",
            "opened_at": "2010-04-17T14:00:00",
            "closed_at": "2100-04-17T14:00:00",
            "allow_submissions": true,
            "allow_submission_voting": true,
            "anonymous": true,
            "allow_submission_comments": true,
            "allow_ranking": true,
            "show_submission_comments": true,
            "show_submission_ratings": true,
            "show_user_submissions": true,
            "visible": true,
            "user_submission_limit": 42,
            "sort": "some sort",
            "type": "general",
            "section_id": 8,
            "inserted_at": "2020-03-27T19:23:12",
            "updated_at": "2020-03-27T19:23:12"
          }
        },
        "user": {
          "id": 5,
          "net_id": "stu2",
          "display_name": "Student 2",
          "email": "stu2@yale.edu",
          "is_faculty": false,
          "inserted_at": "2020-03-27T19:23:05",
          "updated_at": "2020-03-27T19:23:05",
          "is_superuser": false
        }
      }
    }
  ```

  Notice that sometimes this will return nil/null when something
  is deleted via a cascade, e.g. if we delete a submission and
  the comments are deleted by cascade.
  """

  defp comment_or_rating_trigger

  @channel "events:details"
  def change do

    similar_tables = ["comments", "ratings"]
    for table <- similar_tables do
      execute """
        CREATE OR REPLACE FUNCTION #{table}_bubble_notification()
        RETURNS trigger AS $$
        DECLARE
          current_row RECORD;
          row_with_lineage RECORD;
          payload TEXT;
        BEGIN
          IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
            current_row := NEW;
          ELSE
            current_row := OLD;
          END IF;

        -- `row_with_lineage` stores the #{table} information
        -- and information about its parent submission, topic,
        -- and user.
        select into row_with_lineage row
        from (
          select
            c.*,
            st as submission,
            u as user
          from #{table} c
          inner join users u on c.user_id = u.id
          inner join(
            select s.*, t as topic
            from submissions s
            inner join topics t on t.id = s.topic_id
          ) st on c.submission_id = st.id
          where c.id=current_row.id
        ) row;

        payload := json_build_object(
          'table', TG_TABLE_NAME,
          'type', TG_OP,
          'data', row_to_json(row_with_lineage)::json->'row'
        )::text;

        perform pg_notify('#{@channel}', payload);

        RETURN current_row;
        END;
        $$ LANGUAGE plpgsql
      """

      execute """
          CREATE TRIGGER #{table}_bubble_notification_tg
          AFTER INSERT OR UPDATE OR DELETE
          ON #{table}
          FOR EACH ROW
          EXECUTE PROCEDURE #{table}_bubble_notification();
        """
    end

    execute """
      CREATE OR REPLACE FUNCTION submissions_bubble_notification()
      RETURNS trigger AS $$
      DECLARE
        current_row RECORD;
        row_with_lineage RECORD;
        payload TEXT;
      BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
          current_row := NEW;
        ELSE
          current_row := OLD;
        END IF;

      -- `row_with_lineage` stores the submissions information
      -- and information about its parent submission, topic,
      -- and user.
      select into row_with_lineage row
      from (
        select
          s.*,
          t as topic,
          u as user
        from submissions s
        inner join users u on s.user_id = u.id
        inner join topics t on s.topic_id = t.id
        where s.id=current_row.id
      ) row;

      payload := json_build_object(
        'table', TG_TABLE_NAME,
        'type', TG_OP,
        'data', row_to_json(row_with_lineage)::json->'row'
      )::text;

      perform pg_notify('#{@channel}', payload);

      RETURN current_row;
      END;
      $$ LANGUAGE plpgsql
    """

    execute """
        CREATE TRIGGER submissions_bubble_notification_tg
        AFTER INSERT OR UPDATE OR DELETE
        ON submissions
        FOR EACH ROW
        EXECUTE PROCEDURE submissions_bubble_notification();
      """

  end
end
