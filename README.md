# Yale Class Chat

This is a web application for student communication. It should support
the following scenarios:

1. Users (mostly students) proposing, commenting on, and voting on ideas.
2. Users asking questions and answering others' questions.
3. Taking attendance.

We will focus on the first scenario at first because this is the
scenario for which the app will
be used in the Innovator in Spring 2020.

## Tech stack

We will be using

- Docker
- Elixir
- Phoenix
- Ecto with PostgreSQL
- User authentication
  - Unclear of the best option. A few include
  - [Überauth](https://github.com/ueberauth/ueberauth)
    - [Überauth CAS](https://github.com/marceldegraaf/ueberauth_cas)
    - See [this blog
      post](http://brandonvergara.me/post/ueberauth_cas_with_phoenix/)
  - [Pow](https://github.com/danschultzer/pow)
    - This seems most actively maintained
  - Seems like Überauth is the only option with an existing
    CAS library. Not sure I feel like rolling our own right
    now. Maybe we can use dependency injection or something
    to make this swappable later?
- Session storage
  - Cookie is the Phoenix default
  - ETS is a common alternative with good performance
  - ETS doesn't survive app restart and cookie sessions
    expose data to the user. Unclear how best to use
    redis or postgres.
- Client-side
  - Unclear what the best option is here. Some options
  - [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view)
    - This is intriguing, but unclear if it can do
      everything one might want on the client side.
      And, it is under active development.
    - Elm. This would be a good amount of work that
      might take us a long time.
    - Phoenix pub/sub channels. This is the defacto
      solution, but involves writing plain vanilla
      js on the client side for DOM updates. That's
      a non-starter.

## User stories

Here are some draft stories

- As a user with Yale CAS credentials I can log in using
  the Yale CAS system.
- As a logged in user
  - my Yale status is recognized: faculty, TA,
    student, staff, or other.
    - This comes from Yale LDAP.
    - My status is persisted in my user model upon
      first authentication.
  - I can refresh my status in my "account settings"
- As an authenticated faculty person
  - I can create a "course".
  - I can create sections of a course.
  - I can make a user "administrator" for a course.
  - I can "freeze" a course, preventing read.
  - I can "archive" a course, preventing both read and write.
  - I can "preserve" a course, preventing write. `Thinking this will be useful if they wish to view old courses but prevent any edits`
- As an authenticated administrator for a course
  - I can add users to a course
    - I can set a user's role for a course: student, guest.
    - I can toggle a user's activity: active, inactive
      - This will govern read & write access to course
        data. This is mostly used for students who
        drop a course.
  - I can create a "topic" and specify the courses or
    sections to which this topic is assigned. (Topics
    assigned to a course but not a particular section
    will be assigned to all sections of that course.)
    `What does a "topic" map to? Is a topic an idea (e.g., bring healthcare to rural poor)? Or more like an assignment (e.g., submit an idea)? Or something else?` 
  - I can toggle the status of a topic:
    - Open: Allow submission of new sub-topics
      - Students can see only their own sub-topics
    - Review: Allow voting/rating and commenting on subtopics; prevent submission of new sub-topics
      - Students can see all sub-topics in their section but cannot see submitter information (only sub-topic content)
    - Selection: Allow ranking subtopics; prevent submission of new sub-topics or voting/rating
      - Students can see all sub-topics marked as "Pitched", including submitter name
      - Students can only see their own rankings
    - Assigned: Prevent voting/rating/ranking
  - I can toggle the status of a sub-topic
    - Submitted: default status applied when students submit; open for evaluation
    - Pitched: selected for pitching in class
- As an authenticated user
  - I can see the courses to which I have read access.
  - I can submit sub-topics to topics with status Open
  - I can vote/rate and comment on sub-topics in topics with status Review
  - I can rank sub-topics in topics with status Selection
  - I can see my assigned sub-topic and team members in topics with status Assigned
- To be continued...

## Q&A with Rodrigo

```
- should this require authentication?
>> yes.  Ideally they could access this from Canvas somehow

- do you need to prevent students from posting and commenting in sections that are not theirs?
>> yes. Tricky thing is a small but non-trivial number of them (eg 5 per section) change sections. So ideal is to have a central database where one field is their section. And they are loaded from that into their section’s workspace. If you change sections, your idea goes with you. Other side of that coin is that when you connect, you only see the ideas posted in your section

- how many ideas can a user post?
>> up to 3? Rarely happens they post more than one

- can users edit/delete their ideas?
>> interesting. Yes but we would like to keep record if possible

- can users edit/delete their ratings or comments?
>> sure- but we want to keep record if possible
```

## General flow of idea generation (from 2019 course)
1. Students all submit idea(s) for a project to work on for the quarter
2. Students rate and provide feedback for other students' projects; they are graded on quality of feedback and somewhat on number of ratings/comments provided. IIRC, students are not able to see who submitted an idea when they rate/comment
3. Faculty and TAs select the top 20 ideas (partly but not entirely driven by student interest, measured by average rating and # of ratings/comments)
4. Students who submitted the top 20 ideas pitch their idea to the remainder of their class during a class session
5. Students who did not submit one of the top 20 ideas rank their top preferences (IIRC we rated our top 5)
6. Faculty and TAs use these student ratings to assign groups to each idea, which are then their teams for the remainder of the course