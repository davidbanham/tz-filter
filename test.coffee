assert = require 'assert'
time = require 'time'
now = new time.Date()

# sets seconds and milliseconds to zero, subtracts one from month for readability
tzDate = (year,month,day,hours,minutes,tz) ->
  return new time.Date(year,month - 1,day,hours,minutes,0,0,tz)

describe 'lib', ->
  tzFilter = require './lib/index.js'
  describe "#tzFilter()", ->
    times =
      workday:
        start: '08:30'
        end: '17:30'
        days: [1..5] #monday - friday
      monOne:
        start: '13:00'
        end: '13:01'
        days: [1] #monday only!
      mornings:
        start: '08'
        end: '13'
        days: [0..6] #all days
      oddEvenings:
        start: '13'
        end: '18'
        days: ['mon','wed','fri','sun'] #skipping days
      halfDay:
        start: '00'
        end: '12'
        days: [0..6] #all days
      hourWindow:
        start: now.getHours()
        end: now.getHours() + 1
        days: [0..6] #all days

    it "Should return a single member if time is within the workday", ->  
      mockNow = tzDate(2014,9,15,8,30,'Australia/Sydney') #8:30am Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,15,13,0,'Australia/Sydney') #1:00pm Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,15,17,29,'Australia/Sydney') #5:29pm Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 1

    it "Should not return members where now is equal to the end time", ->  
      mockNow = tzDate(2014,9,15,5,30,'Australia/Sydney') #5:30pm Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 0

    it "Should not return a member if time is outside the workday", ->  
      mockNow = tzDate(2014,9,15,0,0,'Australia/Sydney') #12:00am Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 0
      mockNow = tzDate(2014,9,15,8,29,'Australia/Sydney') #8:29am Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 0

    it "Should not return a member if the day is outside the workweek", ->  
      mockNow = tzDate(2014,9,20,13,0,'Australia/Sydney') #1:00pm Saturday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 0
      mockNow = tzDate(2014,9,21,13,0,'Australia/Sydney') #1:00pm Sunday
      assert.equal (tzFilter ['Australia/Sydney'], times.workday, 0, mockNow).length, 0

    it "Should accept objects with a timezone property", ->
      mockNow = tzDate(2014,9,15,13,0,'Australia/Sydney') #1:00pm Monday
      assert.equal (tzFilter [{timezone: 'Australia/Sydney'}], times.workday, 0, mockNow).length, 1

    it "Should consider the timezone specified", ->
      mockNow = tzDate(2014,9,15,13,0,'Pacific/Funafuti') #1:00pm Monday
      assert.equal (tzFilter ['Pacific/Funafuti'], times.monOne, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,15,13,0,'America/Los_Angeles') #1:00pm Monday
      assert.equal (tzFilter ['America/Los_Angeles'], times.monOne, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,15,13,0,'UTC') #1:00pm Monday
      assert.equal (tzFilter ['UTC'], times.monOne, 0, mockNow).length, 1

    it "Should accept times without minutes", ->
      mockNow = tzDate(2014,9,15,8,0,'Australia/Sydney') #8:00am Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.mornings, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,15,12,59,'Australia/Sydney') #12:59pm Monday
      assert.equal (tzFilter ['Australia/Sydney'], times.mornings, 0, mockNow).length, 1

    it "Should accept days as strings", ->
      mockNow = tzDate(2014,9,15,15,30,'Australia/Sydney') #3:30pm Monday
      assert.equal (tzFilter [{timezone: 'Australia/Sydney'}], times.oddEvenings, 0, mockNow).length, 1
      mockNow = tzDate(2014,9,16,15,30,'Australia/Sydney') #3:30pm Tuesday
      assert.equal (tzFilter [{timezone: 'Australia/Sydney'}], times.oddEvenings, 0, mockNow).length, 0

    it "Should consider time offsets", ->
      mockNow = tzDate(2014,9,15,14,0,'UTC') #2:00pm Monday
      assert.equal (tzFilter ['UTC'], times.monOne, -60, mockNow).length, 1
      mockNow = tzDate(2014,9,15,10,0,'UTC') #10:00am Monday
      assert.equal (tzFilter ['UTC'], times.monOne, 180, mockNow).length, 1

    it "Should not require a time to be passed", ->
      assert.equal (tzFilter [now.getTimezone()], times.hourWindow, 0).length, 1

    it "Should always return exactly 1 member with opposite timezones", ->
      opposites = [
        {timezone: 'UTC'}
        {timezone: 'Pacific/Funafuti'} #UTC +12hours (no daylight savings)
      ]
      assert.equal (tzFilter opposites, times.halfDay, 0).length, 1
