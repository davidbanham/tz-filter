# tz-filter

This module accepts an array of timezones (or objects with a .timezone property) and a specified time criteria, then filters the array for only timezones in which the criteria is satisfied.

eg: I have a list of users, I want to know which users it's currently the weekend for. Say it's currently 8pm UTC

```coffeescript
tzFilter = require 'tz-filter'
users = [
  dave:
    timezone: "Australia/Sydney" #6am Monday
  jim:
    timezone: "Europe/Copenhagen" #10pm Sunday
]
weekend =
  start: '00'
  end: '23'
  days: ['sat', 'sun']
chillers = tzFilter(users, weekend) #Chillers contains only the jim object
```

You can also pass an offset in minutes to answer the question "Which timezones are valid in n minutes / n minutes ago?"

```coffeescript
tzFilter(users, weekend, 60) #Tests the condition as if it were an hour from now
tzFilter(users, weekend, -60) #Tests the condition as if it were an hour ago
```

This is written for a phone system that wants to know which of a list of users are currently in business hours and should have a call potentially directed to them.
