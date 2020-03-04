# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


defmodule App.DatabaseSeeder do
  alias App.Repo
  alias App.Accounts
  alias App.Courses
  alias App.Submissions
  alias App.Topics

  @user_list [
    %{display_name: "Professor 1", email: "prof1@yale.edu", net_id: "prof1", is_faculty: true},
    %{display_name: "Professor 2", email: "prof2@yale.edu", net_id: "prof2", is_faculty: true},
    %{display_name: "Professor 3", email: "prof3@yale.edu", net_id: "prof3", is_faculty: true},
    %{display_name: "Professor 4", email: "prof4@yale.edu", net_id: "prof4", is_faculty: true}
  ]
  @semester_list [
    %{name: "Fall 2019"},
    %{name: "Spring 2020"}
  ]
  @course_list [
    %{department: "MGT", name: "Managing Software Development", number: 656, allow_write: true, allow_read: true},
    %{department: "MGT", name: "Basics of MBA Degrees", number: 123, allow_write: true, allow_read: true},
    %{department: "MGT", name: "Foundations of Accounting and Valuation", number: 502, allow_write: true, allow_read: true},
    %{department: "MGT", name: "Introduction to Marketing", number: 505, allow_write: true, allow_read: true}
  ]
  @section_list [
    %{title: "01"},
    %{title: "02"}
  ]
  @topic_list [
    %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some description", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "some title1", user_submission_limit: 42, allow_ranking: true, show_user_submissions: true, visible: true},
    %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some description", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "some title2", user_submission_limit: 42, allow_ranking: true, show_user_submissions: true, visible: true}
  ]

  def insert_users do
    Enum.each(@user_list, &Accounts.create_user/1)
  end

  def insert_semesters do
    creator = Accounts.get_user_by!("prof1")
    for x <- @semester_list do
      Courses.create_semester(creator, x)
    end
  end

  def insert_courses do
    creator = Accounts.get_user_by!("prof1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        Courses.create_course(creator, semester, y)
      end
    end
  end

  def insert_sections do
    creator = Accounts.get_user_by!("prof1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          Courses.create_section(creator, course, attrs)
        end
      end
    end
  end

  def insert_topics do
    creator = Accounts.get_user_by!("prof1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          submitter = Accounts.get_user_by!(Map.get(Enum.random(@user_list), :net_id))
          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            {:ok, topic} = Topics.create_topic(creator, section, attrs)
          end
        end
      end
    end
  end

  def insert_submissions do
    creator = Accounts.get_user_by!("prof1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          submitter = Accounts.get_user_by!(Map.get(Enum.random(@user_list), :net_id))
          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            {:ok, topic} = Topics.create_topic(creator, section, attrs)
          end
        end
      end
    end
  end

  #def insert_link do
  #  Repo.insert! %Link{
  #    title: (@titles_list |> Enum.random()),
  #    url: (@urls_list |> Enum.random())
  #  }
  #end

  def clear do
    Repo.delete_all(App.Courses.Semester)
    Repo.delete_all(App.Courses.Course)
    Repo.delete_all(App.Courses.Section)
    Repo.delete_all(App.Courses.Topic)
  end
end

App.DatabaseSeeder.clear()
App.DatabaseSeeder.insert_users()
#App.DatabaseSeeder.insert_semesters()
#App.DatabaseSeeder.insert_courses()
#App.DatabaseSeeder.insert_sections()
App.DatabaseSeeder.insert_topics()
