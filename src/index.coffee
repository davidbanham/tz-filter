time = require 'time'
module.exports =
  tzFilter = (candidates, original_tarTime, offset, now = new time.Date()) ->
    tarTime = JSON.parse JSON.stringify original_tarTime

    strToInt = (value) ->
      return 0 if (value == '00' || value == undefined)
      return parseInt value.replace(/^0/,'')

    filt = (element, index, candidates) ->
      element = element.timezone if typeof element == 'object'
      now.setTimezone element
      now.setMinutes(now.getMinutes() + offset) if offset?

      today = now.getDay()
      today = days[today] if typeof tarTime.days[0] == 'string'
      if now.getHours() >= tarTime.start.hour && now.getHours() <= tarTime.end.hour && tarTime.days.indexOf(today) > -1

        if now.getHours() is tarTime.start.hour
          return false if now.getMinutes() < tarTime.start.minute
        if now.getHours() is tarTime.end.hour
          return false if now.getMinutes >= tarTime.end.minute
        return true
      else
        return false

    for prop in ['start', 'end']
      tar = tarTime[prop]
      tar = tar.toString()
      arr = tar.split(':')
      tar =
        hour: strToInt arr[0]
        minute: strToInt arr[1]

      tarTime[prop] = tar

    return candidates.filter filt

days =
  0: 'sun'
  1: 'mon'
  2: 'tue'
  3: 'wed'
  4: 'thu'
  5: 'fri'
  6: 'sat'
