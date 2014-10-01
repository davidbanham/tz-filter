time = require 'time'
module.exports =
  tzFilter = (candidates, original_tarTime, offset, now = new time.Date()) ->
    tarTime = JSON.parse JSON.stringify original_tarTime
    console.log tarTime

    # return X characters from the end of a string ('simon',2 => 'on')
    rightTrim = (str, chars) ->
      str.substr(str.length - chars, str.length);

    # change integer time input to a string (9.5 => '09:30')
    numToTime = (value) ->
      hours = Math.floor(value).toString()
      hours = rightTrim('00' + hours, 2)
      minutes = Math.round((value % 1 * 60)).toString()
      minutes = rightTrim('00' + minutes, 2)
      return hours + ':' + minutes

    # change hour OR second value to an integer ('08' => 8 / '59' => 59)
    timeValToNum = (value) ->
      return 0 if ['0','00',undefined].indexOf(value) != -1
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
          return false if now.getMinutes() >= tarTime.end.minute
        return true
      else
        return false

    for prop in ['start', 'end']
      tar = tarTime[prop]
      tar = numToTime tar if typeof tar == 'number'
      arr = tar.split(':')
      tar =
        hour: timeValToNum arr[0]
        minute: timeValToNum arr[1]

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
