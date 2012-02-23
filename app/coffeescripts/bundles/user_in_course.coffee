require.config
  paths:
    analytics: "/plugins/analytics/javascripts"

require [
  'jquery'
  'analytics/jst/user_in_course'
  'analytics/compiled/models/participation'
  'analytics/compiled/models/messaging'
  'analytics/compiled/models/assignments'
  'analytics/compiled/graphs/page_views'
  'analytics/compiled/graphs/responsiveness'
  'analytics/compiled/graphs/assignment_tardiness'
  'analytics/compiled/graphs/grades'
], ($, template, Participation, Messaging, Assignments, PageViews, Responsiveness, AssignmentTardiness, Grades) ->

  # unpackage the environment
  {user, course, startDate, endDate} = ENV.ANALYTICS
  startDate = Date.parse(startDate)
  endDate = Date.parse(endDate)

  # populate the template and inject it into the page
  $("#analytics_body").append template {user, course}

  # colors for the graphs
  frame = "#d7d7d7"
  grid = "#f4f4f4"
  blue = "#29abe1"
  darkgray = "#898989"
  gray = "#a1a1a1"
  lightgray = "#cccccc"
  lightgreen = "#95ee86"
  darkgreen = "#2fa23e"
  lightyellow = "#efe33e"
  darkyellow = "#b3a700"
  lightred = "#dea8a9"
  darkred = "#da181d"

  # setup the graphs
  graphOpts =
    width: 800
    height: 100
    frameColor: frame

  dateGraphOpts = $.extend {}, graphOpts,
    startDate: startDate
    endDate: endDate
    leftPadding: 30  # larger padding on left because of assymetrical
    rightPadding: 15 # responsiveness bubbles

  pageViews = new PageViews "participating-graph", $.extend {}, dateGraphOpts,
    verticalPadding: 9
    barColor: lightgray
    participationColor: blue

  responsiveness = new Responsiveness "responsiveness-graph", $.extend {}, dateGraphOpts,
    verticalPadding: 14
    gutterHeight: 22
    markerWidth: 31
    caratOffset: 7
    caratSize: 10
    studentColor: lightgray
    instructorColor: blue

  assignmentTardiness = new AssignmentTardiness "assignment-finishing-graph", $.extend {}, dateGraphOpts,
    verticalPadding: 10
    barColorOnTime: lightgreen
    diamondColorOnTime: darkgreen
    barColorLate: lightyellow
    diamondColorLate: darkyellow
    diamondColorMissing: darkred
    diamondColorUndated: gray
    gridColor: grid

  grades = new Grades "grades-graph", $.extend {}, graphOpts,
    height: 200
    padding: 15
    whiskerColor: darkgray
    boxColor: lightgray
    medianColor: darkgray
    goodRingColor: lightgreen
    goodCenterColor: darkgreen
    fairRingColor: lightyellow
    fairCenterColor: darkyellow
    poorRingColor: lightred
    poorCenterColor: darkred
    gridColor: grid

  # request data
  participation = new Participation course, user
  messaging = new Messaging course, user
  assignments = new Assignments course, user

  # draw graphs
  pageViews.graphDeferred participation.ready -> participation
  responsiveness.graphDeferred messaging.ready -> messaging
  assignmentTardiness.graphDeferred assignments.ready -> assignments
  grades.graphDeferred assignments.ready -> assignments
