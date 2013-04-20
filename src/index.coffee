time = require 'time'
module.exports =
  tzFilter = (candidates, tarTime, offset) ->
    filt = (element, index, candidates) ->
      element = element.timezone if typeof element == 'object'
      now = new time.Date().setTimezone element
      now.setMinutes(now.getMinutes() + offset) if offset?
      today = now.getDay()
      today = days[today] if typeof tarTime.days[0] == 'string'
      if now.getHours() >= tarTime.start && now.getHours() <= tarTime.end && tarTime.days.indexOf(today) > -1
        return true
      else
        return false
    return candidates.filter filt

days =
  0: 'sun'
  1: 'mon'
  2: 'tue'
  3: 'wed'
  4: 'thu'
  5: 'fri'
  6: 'sat'
