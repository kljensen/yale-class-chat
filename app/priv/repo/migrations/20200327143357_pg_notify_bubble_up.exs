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

  The function `rating_change_detailed_notification` produces `pg_notify`
  bodies that look like the following:

  ```json
  {
    "id": 4,
    "description": "He walked into the basement with the horror movie from the night before playing in his head.",
    "submission_id": 1,
    "user_id": 7,
    "inserted_at": "2020-03-25T17:10:57",
    "updated_at": "2020-03-25T17:10:57",
    "submission": {
      "id": 1,
      "title": "Is there enough &Society in this class?",
      "description": "I'm heading back to Colorado tomorrow after being down in Santa Barbara over the weekend for the festival there. I will be making October plans once there and will try to arrange so I'm back here for the birthday if possible. I'll let you know as soon asI know the doctor's appointment schedule and my flight plans.",
      "slug": null,
      "image_url": "http://i.imgur.com/qZA3mCR.jpg",
      "allow_ranking": false,
      "visible": true,
      "topic_id": 1,
      "user_id": 7,
      "inserted_at": "2020-03-25T17:10:57",
      "updated_at": "2020-03-25T17:10:57",
      "topic": {
        "id": 1,
        "title": "foo",
        "description": "This is where you should post your problems for Assignment 1. Remember: you are posting PROBLEMS that matter -- and maybe a general approach to solving them. You are NOT posting ideas -- the development of ideas will happen through the next assignments.\n\n    “If I had an hour to solve a problem I'd spend 55 minutes thinking about the problem and five minutes thinking about solutions.” - Albert Einstein",
        "slug": "1101Idea Board (Assignment 1)",
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
        "section_id": 1,
        "inserted_at": "2020-03-25T17:10:57",
        "updated_at": "2020-03-25T17:10:57"
      }
    },
    "user": {
      "id": 7,
      "net_id": "stu4",
      "display_name": "Student 4",
      "email": "stu4@yale.edu",
      "is_faculty": false,
      "inserted_at": "2020-03-25T17:10:57",
      "updated_at": "2020-03-25T17:10:57",
      "is_superuser": false
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
          'data', to_json(row_with_lineage)
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


  end
end
