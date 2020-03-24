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

  @prof_list [
    %{display_name: "Professor 1", email: "pro1@yale.edu", net_id: "pro1", is_faculty: true},
    %{display_name: "Professor 2", email: "pro2@yale.edu", net_id: "pro2", is_faculty: true},
    %{display_name: "TA 1", email: "ta1@yale.edu", net_id: "ta1", is_faculty: false}
  ]
  @student_list [
    %{display_name: "Student 1", email: "stu1@yale.edu", net_id: "stu1", is_faculty: false},
    %{display_name: "Student 2", email: "stu2@yale.edu", net_id: "stu2", is_faculty: false},
    %{display_name: "Student 3", email: "stu3@yale.edu", net_id: "stu3", is_faculty: false},
    %{display_name: "Student 4", email: "stu4@yale.edu", net_id: "stu4", is_faculty: false},
    %{display_name: "Student 5", email: "stu5@yale.edu", net_id: "stu5", is_faculty: false}
  ]
  @semester_list [
    %{name: "Fall 2019", term_code: "201903"},
    %{name: "Spring 2020", term_code: "202001"}
  ]
  @course_list [
    %{department: "MGT", name: "Managing Software Development", number: 656, allow_write: true, allow_read: true},
    %{department: "MGT", name: "Basics of MBA Degrees", number: 123, allow_write: true, allow_read: true}
  ]
  @section_list [
    %{title: "01"},
    %{title: "02"}
  ]
  @topic_list [
    %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "This is where you should post your problems for Assignment 1. Remember: you are posting PROBLEMS that matter -- and maybe a general approach to solving them. You are NOT posting ideas -- the development of ideas will happen through the next assignments.

    “If I had an hour to solve a problem I'd spend 55 minutes thinking about the problem and five minutes thinking about solutions.” - Albert Einstein", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "Idea Board (Assignment 1)", user_submission_limit: 42, allow_ranking: true, show_user_submissions: true, visible: true},
    %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "The website you're using is an experimental piece of software we hope will be helpful during the COVID crisis (and afterward!). This is being developed by SOMers Nick Peranzi and Kyle Jensen. We'd like your advice! What should an app like this include? Right now we're thinking about polls, live chat, private chat, and emojis. (Emojis are top priority.)

    What do you want to see in a communications platform for class? Please tell us!

    ", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "Help us design yale.chat!", user_submission_limit: 42, allow_ranking: true, show_user_submissions: true, visible: true}
  ]
  @random_title_list [
    "Let's vote on this idea!",
    "How many woodchucks?",
    "Rate my teaching ability",
    "Make a brillian business idea",
    "Is lorem ipsum overrated?",
    "Who do you want to have on your team?",
    "Is there enough &Society in this class?",
    "List 3 ways to improve Yale SOM",
    "This is a boring title.",
    "How often do you skip class?",
    "How confident are you in your abilities?"
  ]
  @random_description_list [
    "I inadvertently went to See's Candy last week (I was in the mall looking for phone repair), and as it turns out, See's Candy now charges a dollar -- a full dollar -- for even the simplest of their wee confection offerings. I bought two chocolate lollipops and two chocolate-caramel-almond things. The total cost was four-something. I mean, the candies were tasty and all, but let's be real: A Snickers bar is fifty cents. After this dollar-per-candy revelation, I may not find myself wandering dreamily back into a See's Candy any time soon.",
    "He was an expert but not in a discipline that anyone could fully appreciate. He knew how to hold the cone just right so that the soft server ice-cream fell into it at the precise angle to form a perfect cone each and every time. It had taken years to perfect and he could now do it without even putting any thought behind it. Nobody seemed to fully understand the beauty of this accomplishment except for the new worker who watched in amazement.",
    "There wasn't a bird in the sky, but that was not what caught her attention. It was the clouds. The deep green that isn't the color of clouds, but came with these. She knew what was coming and she hoped she was prepared.",
    "Dave watched as the forest burned up on the hill, only a few miles from her house. The car had been hastily packed and Marta was inside trying to round up the last of the pets. Dave went through his mental list of the most important papers and documents that they couldn't leave behind. He scolded himself for not having prepared these better in advance and hoped that he had remembered everything that was needed. He continued to wait for Marta to appear with the pets, but she still was nowhere to be seen.",
    "Since they are still preserved in the rocks for us to see, they must have been formed quite recently, that is, geologically speaking. What can explain these striations and their common orientation? Did you ever hear about the Great Ice Age or the Pleistocene Epoch? Less than one million years ago, in fact, some 12,000 years ago, an ice sheet many thousands of feet thick rode over Burke Mountain in a southeastward direction. The many boulders frozen to the underside of the ice sheet tended to scratch the rocks over which they rode. The scratches or striations seen in the park rocks were caused by these attached boulders. The ice sheet also plucked and rounded Burke Mountain into the shape it possesses today.",
    "This is important to remember. Love isn't like pie. You don't need to divide it among all your friends and loved ones. No matter how much love you give, you can always give more. It doesn't run out, so don't try to hold back giving it as if it may one day run out. Give it freely and as much as you want.",
    "I recollect that my first exploit in squirrel-shooting was in a grove of tall walnut-trees that shades one side of the valley. I had wandered into it at noontime, when all nature is peculiarly quiet, and was startled by the roar of my own gun, as it broke the Sabbath stillness around and was prolonged and reverberated by the angry echoes.",
    "Josh had spent year and year accumulating the information. He knew it inside out and if there was ever anyone looking for an expert in the field, Josh would be the one to call. The problem was that there was nobody interested in the information besides him and he knew it. Years of information painstakingly memorized and sorted with not a sole giving even an ounce of interest in the topic.",
    "As she sat watching the world go by, something caught her eye. It wasn't so much its color or shape, but the way it was moving. She squinted to see if she could better understand what it was and where it was going, but it didn't help. As she continued to stare into the distance, she didn't understand why this uneasiness was building inside her body. She felt like she should get up and run. If only she could make out what it was. At that moment, she comprehended what it was and where it was heading, and she knew her life would never be the same.",
    "The words hadn't flowed from his fingers for the past few weeks. He never imagined he'd find himself with writer's block, but here he sat with a blank screen in front of him. That blank screen taunting him day after day had started to play with his mind. He didn't understand why he couldn't even type a single word, just one to begin the process and build from there. And yet, he already knew that the eight hours he was prepared to sit in front of his computer today would end with the screen remaining blank.",
    "The cab arrived late. The inside was in as bad of shape as the outside which was concerning, and it didn't appear that it had been cleaned in months. The green tree air-freshener hanging from the rearview mirror was either exhausted of its scent or not strong enough to overcome the other odors emitting from the cab. The correct decision, in this case, was to get the hell out of it and to call another cab, but she was late and didn't have a choice.",
    "The day had begun on a bright note. The sun finally peeked through the rain for the first time in a week, and the birds were sinf=ging in its warmth. There was no way to anticipate what was about to happen. It was a worst-case scenario and there was no way out of it.",
    "She sat in the darkened room waiting. It was now a standoff. He had the power to put her in the room, but not the power to make her repent. It wasn't fair and no matter how long she had to endure the darkness, she wouldn't change her attitude. At three years old, Sandy's stubborn personality had already bloomed into full view.",
    "I haven't bailed on writing. Look, I'm generating a random paragraph at this very moment in an attempt to get my writing back on track. I am making an effort. I will start writing consistently again!",
    "Since they are still preserved in the rocks for us to see, they must have been formed quite recently, that is, geologically speaking. What can explain these striations and their common orientation? Did you ever hear about the Great Ice Age or the Pleistocene Epoch? Less than one million years ago, in fact, some 12,000 years ago, an ice sheet many thousands of feet thick rode over Burke Mountain in a southeastward direction. The many boulders frozen to the underside of the ice sheet tended to scratch the rocks over which they rode. The scratches or striations seen in the park rocks were caused by these attached boulders. The ice sheet also plucked and rounded Burke Mountain into the shape it possesses today.",
    "He wondered if he should disclose the truth to his friends. It would be a risky move. Yes, the truth would make things a lot easier if they all stayed on the same page, but the truth might fracture the group leaving everything in even more of a mess than it was not telling the truth. It was time to decide which way to go.
    I recently discovered I could make fudge with just chocolate chips, sweetened condensed milk, vanilla extract, and a thick pot on slow heat. I tried it with dark chocolate chunks and I tried it with semi-sweet chocolate chips. It's better with both kinds. It comes out pretty bad with just the dark chocolate. The best add-ins are crushed almonds and marshmallows -- what you get from that is Rocky Road. It takes about twenty minutes from start to fridge, and then it takes about six months to work off the twenty pounds you gain from eating it. All things in moderation, friends. All things in moderation.",
    "I'm heading back to Colorado tomorrow after being down in Santa Barbara over the weekend for the festival there. I will be making October plans once there and will try to arrange so I'm back here for the birthday if possible. I'll let you know as soon as I know the doctor's appointment schedule and my flight plans.",
    "It wasn't quite yet time to panic. There was still time to salvage the situation. At least that is what she was telling himself. The reality was that it was time to panic and there wasn't time to salvage the situation, but he continued to delude himself into believing there was."
  ]
  @random_comment_list [
    "He fumbled in the darkness looking for the light switch, but when he finally found it there was someone already there.",
    "He walked into the basement with the horror movie from the night before playing in his head.",
    "Malls are great places to shop; I can find everything I need under one roof.",
    "I often see the time 11:11 or 12:34 on clocks.",
    "Never underestimate the willingness of the greedy to throw you under the bus.",
    "My dentist tells me that chewing bricks is very bad for your teeth.",
    "I currently have 4 windows open up… and I don’t know why.",
    "He figured a few sticks of dynamite were easier than a fishing pole to catch fish.",
    "I am my aunt's sister's daughter.",
    "The small white buoys marked the location of hundreds of crab pots.",
    "I really want to go to work, but I am too sick to drive."
  ]
  @random_image_url_list [
    "http://i.imgur.com/u3vyMCW.jpg",
    "http://i.imgur.com/zF7rPAf.jpg",
    "http://i.imgur.com/aDTl7OM.jpg",
    "http://i.imgur.com/KONVsYw.jpg",
    "http://i.imgur.com/RVM2pYi.png",
    "http://i.imgur.com/tkMhc9T.jpg",
    "http://i.imgur.com/KxUrZkp.gif",
    "http://i.imgur.com/mnDTovy.jpg",
    "http://i.imgur.com/WpuXbHb.jpg",
    "http://i.imgur.com/qZA3mCR.jpg",
    "http://i.imgur.com/AxMS1Fs.png",
    "http://i.imgur.com/TLSd571.jpg",
    "http://i.imgur.com/VfMhLIQ.jpg",
    "http://i.imgur.com/Wu32582.jpg"
  ]

  def insert_users do
    Enum.each(@prof_list, &Accounts.create_user/1)
    Enum.each(@student_list, &Accounts.create_user/1)
  end

  def insert_semesters do
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      Courses.create_semester(creator, x)
    end
  end

  def insert_courses do
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        Courses.create_course(creator, semester, y)
      end
    end
  end

  def insert_sections do
    creator = Accounts.get_user_by!("pro1")
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
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          submitter = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
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
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        course_role_attrs = %{role: "administrator", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
        for u <- @prof_list do
          user = Accounts.get_user_by!(u.net_id)
          if u.net_id != creator.net_id, do: Accounts.create_course__role(creator, user, course, course_role_attrs)
        end
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          section_role_attrs = %{role: "student", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
          for u <- @student_list do
            user = Accounts.get_user_by!(u.net_id)
            Accounts.create_section__role(creator, user, section, section_role_attrs)
          end
          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            topic_writer = Accounts.get_user_by!(Map.get(Enum.random(@prof_list), :net_id))
            {:ok, topic} = Topics.create_topic(topic_writer, section, attrs)
            Enum.each(1..5, fn x ->
                submitter = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
                attrs = %{description: Enum.random(@random_description_list), image_url: Enum.random(@random_image_url_list), title: Enum.random(@random_title_list), allow_ranking: true, visible: true}
                Submissions.create_submission(submitter, topic, attrs)
            end)
          end
        end
      end
    end
  end

  def insert_comments do
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        course_role_attrs = %{role: "administrator", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
        for u <- @prof_list do
          user = Accounts.get_user_by!(u.net_id)
          if u.net_id != creator.net_id, do: Accounts.create_course__role(creator, user, course, course_role_attrs)
        end
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          section_role_attrs = %{role: "student", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
          for u <- @student_list do
            user = Accounts.get_user_by!(u.net_id)
            Accounts.create_section__role(creator, user, section, section_role_attrs)
          end
          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            topic_writer = Accounts.get_user_by!(Map.get(Enum.random(@prof_list), :net_id))
            {:ok, topic} = Topics.create_topic(topic_writer, section, attrs)
            Enum.each(1..5, fn b ->
                submitter = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
                attrs = %{description: Enum.random(@random_description_list), image_url: Enum.random(@random_image_url_list), title: Enum.random(@random_title_list), allow_ranking: true, visible: true}
                {:ok, submission} = Submissions.create_submission(submitter, topic, attrs)

                Enum.each(1..5, fn c ->
                  student = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
                  attrs = %{description: Enum.random(@random_comment_list)}
                  Submissions.create_comment(student, submission, attrs)
              end)
            end)
          end
        end
      end
    end
  end

  def insert_ratings do
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        course_role_attrs = %{role: "administrator", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
        for u <- @prof_list do
          user = Accounts.get_user_by!(u.net_id)
          if u.net_id != creator.net_id, do: Accounts.create_course__role(creator, user, course, course_role_attrs)
        end
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          section_role_attrs = %{role: "student", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
          for u <- @student_list do
            user = Accounts.get_user_by!(u.net_id)
            Accounts.create_section__role(creator, user, section, section_role_attrs)
          end
          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            topic_writer = Accounts.get_user_by!(Map.get(Enum.random(@prof_list), :net_id))
            {:ok, topic} = Topics.create_topic(topic_writer, section, attrs)
            Enum.each(1..5, fn b ->
                submitter = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
                attrs = %{description: Enum.random(@random_description_list), image_url: Enum.random(@random_image_url_list), title: Enum.random(@random_title_list), allow_ranking: true, visible: true}
                {:ok, submission} = Submissions.create_submission(submitter, topic, attrs)

                Enum.each(1..5, fn d ->
                  student = Accounts.get_user_by!(Map.get(Enum.random(@student_list), :net_id))
                  attrs = %{score: Enum.random(0..5)}
                  Submissions.create_rating(student, submission, attrs)
              end)
            end)
          end
        end
      end
    end
  end

  def insert_comments_and_ratings do
    creator = Accounts.get_user_by!("pro1")
    for x <- @semester_list do
      {:ok, semester} = Courses.create_semester(creator, x)
      for y <- @course_list do
        {:ok, course} = Courses.create_course(creator, semester, y)
        course_role_attrs = %{role: "administrator", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}
        for u <- @prof_list do
          user = Accounts.get_user_by!(u.net_id)
          if u.net_id != creator.net_id, do: Accounts.create_course__role(creator, user, course, course_role_attrs)
        end
        for z <- @section_list do
          crn = to_string(semester.id) <> to_string(course.id) <> Map.get(z, :title)
          attrs = Map.put(z, :crn, crn)
          {:ok, section} = Courses.create_section(creator, course, attrs)
          section_role_attrs = %{role: "student", valid_from: "2010-04-17T14:00:00Z", valid_to: "2100-04-17T14:00:00Z"}

          shuffled_list = Enum.shuffle @student_list
          short_student_list = Enum.take(shuffled_list, 3)

          for u <- short_student_list do
            user = Accounts.get_user_by!(u.net_id)
            Accounts.create_section__role(creator, user, section, section_role_attrs)
          end

          for a <- @topic_list do
            slug = Map.get(section, :crn) <> to_string(Map.get(a, :title))
            attrs = Map.put(a, :slug, slug)
            topic_writer = Accounts.get_user_by!(Map.get(Enum.random(@prof_list), :net_id))
            {:ok, topic} = Topics.create_topic(topic_writer, section, attrs)
            Enum.each(1..5, fn b ->
              submitter = Accounts.get_user_by!(Map.get(Enum.random(short_student_list), :net_id))
              attrs = %{description: Enum.random(@random_description_list), image_url: Enum.random(@random_image_url_list), title: Enum.random(@random_title_list), allow_ranking: true, visible: true}
              {:ok, submission} = Submissions.create_submission(submitter, topic, attrs)

              Enum.each(1..5, fn c ->
                student = Accounts.get_user_by!(Map.get(Enum.random(short_student_list), :net_id))
                attrs = %{description: Enum.random(@random_comment_list)}
                Submissions.create_comment(student, submission, attrs)
              end)
              Enum.each(1..1, fn d ->
                student = Accounts.get_user_by!(Map.get(Enum.random(short_student_list), :net_id))
                attrs = %{score: Enum.random(0..5)}
                Submissions.create_rating(student, submission, attrs)
              end)
            end)
          end
        end
      end
    end
  end

  def clear do
    Repo.delete_all(App.Accounts.User)
    Repo.delete_all(App.Accounts.Course_Role)
    Repo.delete_all(App.Accounts.Section_Role)
    Repo.delete_all(App.Courses.Semester)
    Repo.delete_all(App.Courses.Course)
    Repo.delete_all(App.Courses.Section)
    Repo.delete_all(App.Topics.Topic)
    Repo.delete_all(App.Submissions.Submission)
    Repo.delete_all(App.Submissions.Comment)
    Repo.delete_all(App.Submissions.Rating)
  end
end

App.DatabaseSeeder.clear()
App.DatabaseSeeder.insert_users()
#App.DatabaseSeeder.insert_semesters()
#App.DatabaseSeeder.insert_courses()
#App.DatabaseSeeder.insert_sections()
#App.DatabaseSeeder.insert_topics()
#App.DatabaseSeeder.insert_submissions()
#App.DatabaseSeeder.insert_comments()
#App.DatabaseSeeder.insert_ratings()
App.DatabaseSeeder.insert_comments_and_ratings()
