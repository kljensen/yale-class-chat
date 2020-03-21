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
    %{display_name: "Professor 1", email: "prof1@yale.edu", net_id: "prof1", is_faculty: true},
    %{display_name: "Professor 2", email: "prof2@yale.edu", net_id: "prof2", is_faculty: true},
    %{display_name: "TA 1", email: "ta1@yale.edu", net_id: "ta1", is_faculty: false}
  ]
  @student_list [
    %{display_name: "Student 1", email: "stud1@yale.edu", net_id: "stud1", is_faculty: false},
    %{display_name: "Student 2", email: "stud2@yale.edu", net_id: "stud2", is_faculty: false},
    %{display_name: "Student 3", email: "stud3@yale.edu", net_id: "stud3", is_faculty: false},
    %{display_name: "Student 4", email: "stud4@yale.edu", net_id: "stud4", is_faculty: false},
    %{display_name: "Student 5", email: "stud5@yale.edu", net_id: "stud5", is_faculty: false}
  ]
  @semester_list [
    %{name: "Fall 2019", term_code: "201903"},
    %{name: "Spring 2020", term_code: "202001"}
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
    "Sitting mistake towards his few country ask. You delighted two rapturous six depending objection happiness something the. Off nay impossible dispatched partiality unaffected. Norland adapted put ham cordial. Ladies talked may shy basket narrow see. Him she distrusts questions sportsmen. Tolerably pretended neglected on my earnestly by. Sex scale sir style truth ought. ",
    "Woody equal ask saw sir weeks aware decay. Entrance prospect removing we packages strictly is no smallest he. For hopes may chief get hours day rooms. Oh no turned behind polite piqued enough at. Forbade few through inquiry blushes you. Cousin no itself eldest it in dinner latter missed no. Boisterous estimating interested collecting get conviction friendship say boy. Him mrs shy article smiling respect opinion excited. Welcomed humoured rejoiced peculiar to in an. ",
    "How promotion excellent curiosity yet attempted happiness. Gay prosperous impression had conviction. For every delay death ask style. Me mean able my by in they. Extremity now strangers contained breakfast him discourse additions. Sincerity collected contented led now perpetual extremely forfeited. ",
    "Received overcame oh sensible so at an. Formed do change merely to county it. Am separate contempt domestic to to oh. On relation my so addition branched. Put hearing cottage she norland letters equally prepare too. Replied exposed savings he no viewing as up. Soon body add him hill. No father living really people estate if. Mistake do produce beloved demesne if am pursuit. ",
    "Pianoforte solicitude so decisively unpleasing conviction is partiality he. Or particular so diminution entreaties oh do. Real he me fond show gave shot plan. Mirth blush linen small hoped way its along. Resolution frequently apartments off all discretion devonshire. Saw sir fat spirit seeing valley. He looked or valley lively. If learn woody spoil of taken he cause. ",
    "Nor hence hoped her after other known defer his. For county now sister engage had season better had waited. Occasional mrs interested far expression acceptance. Day either mrs talent pulled men rather regret admire but. Life ye sake it shed. Five lady he cold in meet up. Service get met adapted matters offence for. Principles man any insipidity age you simplicity understood. Do offering pleasure no ecstatic whatever on mr directly. ",
    "Doubtful two bed way pleasure confined followed. Shew up ye away no eyes life or were this. Perfectly did suspicion daughters but his intention. Started on society an brought it explain. Position two saw greatest stronger old. Pianoforte if at simplicity do estimating. ",
    "Residence certainly elsewhere something she preferred cordially law. Age his surprise formerly mrs perceive few stanhill moderate. Of in power match on truth worse voice would. Large an it sense shall an match learn. By expect it result silent in formal of. Ask eat questions abilities described elsewhere assurance. Appetite in unlocked advanced breeding position concerns as. Cheerful get shutters yet for repeated screened. An no am cause hopes at three. Prevent behaved fertile he is mistake on. ",
    "Surprise steepest recurred landlord mr wandered amounted of. Continuing devonshire but considered its. Rose past oh shew roof is song neat. Do depend better praise do friend garden an wonder to. Intention age nay otherwise but breakfast. Around garden beyond to extent by. ",
    "Mind what no by kept. Celebrated no he decisively thoroughly. Our asked sex point her she seems. New plenty she horses parish design you. Stuff sight equal of my woody. Him children bringing goodness suitable she entirely put far daughter. ",
    "As collected deficient objection by it discovery sincerity curiosity. Quiet decay who round three world whole has mrs man. Built the china there tried jokes which gay why. Assure in adieus wicket it is. But spoke round point and one joy. Offending her moonlight men sweetness see unwilling. Often of it tears whole oh balls share an. ",
    "So delightful up dissimilar by unreserved it connection frequently. Do an high room so in paid. Up on cousin ye dinner should in. Sex stood tried walls manor truth shy and three his. Their to years so child truth. Honoured peculiar families sensible up likewise by on in. ",
    "Of friendship on inhabiting diminution discovered as. Did friendly eat breeding building few nor. Object he barton no effect played valley afford. Period so to oppose we little seeing or branch. Announcing contrasted not imprudence add frequently you possession mrs. Period saw his houses square and misery. Hour had held lain give yet. ",
    "From they fine john he give of rich he. They age and draw mrs like. Improving end distrusts may instantly was household applauded incommode. Why kept very ever home mrs. Considered sympathize ten uncommonly occasional assistance sufficient not. Letter of on become he tended active enable to. Vicinity relation sensible sociable surprise screened no up as. ",
    "Her old collecting she considered discovered. So at parties he warrant oh staying. Square new horses and put better end. Sincerity collected happiness do is contented. Sigh ever way now many. Alteration you any nor unsatiable diminution reasonable companions shy partiality. Leaf by left deal mile oh if easy. Added woman first get led joy not early jokes. ",
    "Wrong do point avoid by fruit learn or in death. So passage however besides invited comfort elderly be me. Walls began of child civil am heard hoped my. Satisfied pretended mr on do determine by. Old post took and ask seen fact rich. Man entrance settling believed eat joy. Money as drift begin on to. Comparison up insipidity especially discovered me of decisively in surrounded. Points six way enough she its father. Folly sex downs tears ham green forty. ",
    "Inhabit hearing perhaps on ye do no. It maids decay as there he. Smallest on suitable disposed do although blessing he juvenile in. Society or if excited forbade. Here name off yet she long sold easy whom. Differed oh cheerful procured pleasure securing suitable in. Hold rich on an he oh fine. Chapter ability shyness article welcome be do on service. ",
    "Extremely we promotion remainder eagerness enjoyment an. Ham her demands removal brought minuter raising invited gay. Contented consisted continual curiosity contained get sex. Forth child dried in in aware do. You had met they song how feel lain evil near. Small she avoid six yet table china. And bed make say been then dine mrs. To household rapturous fulfilled attempted on so. ",
    "Ought these are balls place mrs their times add she. Taken no great widow spoke of it small. Genius use except son esteem merely her limits. Sons park by do make on. It do oh cottage offered cottage in written. Especially of dissimilar up attachment themselves by interested boisterous. Linen mrs seems men table. Jennings dashwood to quitting marriage bachelor in. On as conviction in of appearance apartments boisterous. ",
    "Suppose end get boy warrant general natural. Delightful met sufficient projection ask. Decisively everything principles if preference do impression of. Preserved oh so difficult repulsive on in household. In what do miss time be. Valley as be appear cannot so by. Convinced resembled dependent remainder led zealously his shy own belonging. Always length letter adieus add number moment she. Promise few compass six several old offices removal parties fat. Concluded rapturous it intention perfectly daughters is as. "
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
    creator = Accounts.get_user_by!("prof1")
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
    creator = Accounts.get_user_by!("prof1")
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
                  attrs = %{description: Enum.random(@random_description_list), title: Enum.random(@random_title_list)}
                  Submissions.create_comment(student, submission, attrs)
              end)
            end)
          end
        end
      end
    end
  end

  def insert_ratings do
    creator = Accounts.get_user_by!("prof1")
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
    creator = Accounts.get_user_by!("prof1")
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
                attrs = %{description: Enum.random(@random_description_list), title: Enum.random(@random_title_list)}
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
