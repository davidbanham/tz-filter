assert = require 'assert'
time = require 'time'
now = new time.Date()

describe 'lib', ->
  tzFilter = require './lib/index.js'
  describe "#tzFilter()", ->
    members =
      objects: [
        {timezone: 'UTC'}
        {timezone: 'Pacific/Funafuti'}
      ]
      strings: [
        'UTC'
        'Pacific/Funafuti'
      ]
    times =
      permissive:
        start: '00'
        end: '23'
        days: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      restrictive:
        start: '00'
        end: '11'
        days: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      numbers:
        start: '00'
        end: '11'
        days: [0..6]
      now:
        start: now.getHours()
        end: now.getHours()
        days: [0..6]
      inAnHour:
        start: now.getHours() + 1
        end: now.getHours() + 1
        days: [0..6]
      anHourAgo:
        start: now.getHours() - 1
        end: now.getHours() - 1
        days: [0..6]
      minuted:
        start: '00:40'
        end: '11:40'
        days: [0..6]
      superminuted:
        start: '00:40'
        end: '01:40'
        days: [0..6]
    it "Should return all members for a permissive time", ->
      assert.equal (tzFilter members.objects, times.permissive).length, 2
    it "Should strip one member for a restrictive time", ->
      assert.equal (tzFilter members.objects, times.restrictive).length, 1
    it "Should strip one member for a restrictive time with minutes", ->
      assert.equal (tzFilter members.objects, times.minuted).length, 1
    it "Should strip one member for a restrictive time with minutes when passed a time dep", ->
      mockNow = new time.Date()
      mockNow.setTimezone 'UTC'
      mockNow.setMinutes '00'
      mockNow.setHours '01'
      assert.equal (tzFilter members.objects, times.superminuted, 0, mockNow).length, 1
    it "Should strip both members for a restrictive time with minutes when passed a failing time dep", ->
      mockNow = new time.Date()
      mockNow.setTimezone 'UTC'
      mockNow.setMinutes '00'
      mockNow.setHours '00'
      assert.equal (tzFilter members.objects, times.superminuted, 0, mockNow).length, 0
    it "Should acceptnumbers for days", ->
      assert.equal (tzFilter members.objects, times.numbers).length, 1
    it "Should accept an array of strings", ->
      assert.equal (tzFilter members.strings, times.restrictive).length, 1
    it "Shouldn't filter the current time in the current zone", ->
      assert.equal (tzFilter [now.getTimezone()], times.now).length, 1
    it "Should handle an offset", ->
      assert.equal (tzFilter [now.getTimezone()], times.now, 60).length, 0
      assert.equal (tzFilter [now.getTimezone()], times.inAnHour, 60).length, 1
    it "Should handle a negative offset", ->
      assert.equal (tzFilter [now.getTimezone()], times.anHourAgo, -60).length, 1
      assert.equal (tzFilter [now.getTimezone()], times.now, -60).length, 0
