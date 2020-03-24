# Yale Class Chat

This is a web application for student communication. It should support
the following scenarios:

1. Users (mostly students) proposing, commenting on, and voting on ideas.
2. Users asking questions and answering others' questions.
3. Taking attendance.

We will focus on the first scenario at first because this is the
scenario for which the app will
be used in the Innovator in Spring 2020.

## Starting the app

First, you'll need a `.env` file with the required environment
variables. You'll want something like

```
PORTGRES_PORT=5432
POSTGRES_USER=said_upon_playoff
POSTGRES_PASSWORD=glitter-thing-tamale-flatfoot
POSTGRES_DB=appdevdb
PORT=9001s
MIX_ENV=dev
MOCKCAS_PORT=9002
CAS_BASE_URL=http://localhost:9002/cas
CAS_SERVICE_VALIDATE_BASE_URL=http://mockcas:4000/cas
CAS_CALLBACK_URL=http://localhost:9001/auth/cas/callback
SECRET_KEY_BASE=a7b3f3db42a7a3264a24880906403216b944afbd9bd67365992222ad1a7961c758870182274cd442a3cd89acf5abd5fdccc76974c9ab15a200f5ac2a20eb4b5e
DOMAIN=foo.som.yale.edu
HOST=127.0.0.1
SIGNING_SALT=8ebd49dc616e9d895fff338536e44d5625bd5dc53f8f5c347fb60be75ddfb707
REGISTRATION_API_URL=http://example.com
REGISTRATION_API_USERNAME=user_for_reg_api
REGISTRATION_API_PASSWORD=random-string-of-words-or-characters
LDAP_HOST=ldaps://example.com
LDAP_USER=ldap_user
LDAP_PASS=ldap_pass
YALE_BASE_URL=https://example.com
YALE_COURSE_ENDPOINT=/super_fancy_api
YALE_API_KEY=very-random-string
```

Run `./admin.sh up` to bring up the app. The app will
then be available at [http://localhost:9001](http://localhost:9001)
or on whatever you set `$PORT` as. (Note that the `./admin.sh` script
will source a `.env` file in your current working directory.)

To get a shell in the running docker container, do

```
./admin.sh shell
```

To restart all Elixir processes in the test and app containers, do

```
./admin.sh restart
```

## Running in production

In production, we serve the application mainly over HTTPS and redirect
HTTP requests to HTTPS. This repo has a second docker compose file:
`docker-compose.prod.yaml` that shows the services that we start in
production. To begin, you'll need a domain name that is passed to 
running containers via the `DOMAIN` environment variable. Also, you'll
need to generate certificates. To initialize your certificates, run

```
./admin.sh prod-init-certs
```

This will require answering a few questions. Upon success, certificates
will be stored in the `letsencrypt` docker volume. The certificates are
renewed automatically by the `certbot` docker service.



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
  - ~~I can create a "course".~~
- As a course owner
  - ~~I can make a user "administrator" for a course.~~
  - ~~I can create sections of a course.~~
  - ~~I can "freeze" a course, preventing write.~~
  - ~~I can "archive" a course, preventing both read and write.~~ *Note: read is only prevented for sections, not courses; this way, admins and owners can still read courses*
- As an authenticated administrator for a course
  - ~~I can add users to a course~~
    - ~~I can set a user's role for a course: student, guest.~~
  - ~~I can create a "topic" and specify the courses or
    sections to which this topic is assigned. (Topics
    assigned to a course but not a particular section
    will be assigned to all sections of that course.)~~
  - ~~I can set attributes of a topic:~~
    - ~~title: the title that appears in the UI~~
    - ~~slug: the string in the URL~~
    - ~~opened_at: the date after which the topic is "writeable"
      as long as the `open` (or similar) flag is true.~~
    - ~~closed_at: the date after which the topic is not "writeable"~~
    - ~~allow_submissions: boolean indicating that new submissions (or changes to existing submissions) are allowed~~
    - ~~allow_submission_voting: boolean indicating that submissions
      can be voted upon by authorized users. If `allow_submission_voting`
      is true and `allow_submissions` is false, then the topic is
      effectively in "reviewing" mode: people are voting on submissions.~~
    - ~~submission_limit: integer representing maximum number of submissions per authorized user~~
    - ~~allow_comments: boolean indicating that comments on submissions are allowed.~~
    - sort_order: controls the sort order of submissions. Can be
      by date, votes (ascending, descending), random. **NOT CURRENTLY IMPLEMENTED**
    - anonymous: controls whether submitter ids/names are displayed to end users
  - I can toggle the status of a submission
    - ~~viewable/hidden~~
- As an authenticated user
  - ~~I can see the courses to which I have read access.~~
  - ~~I can see the sections to which I have read access.~~
  - ~~I can submit sub-topics to topics with status Open~~
  - ~~I can vote/rate and comment on sub-topics in topics with status Review~~
  - I can rank submissions in topics with status Selection
  - I can see my assigned submission and team members in topics with status Assigned
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
