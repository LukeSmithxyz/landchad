---
title: "Cronjobs"
date: 2020-07-01
tags: ['server']
---

Cron is a service that lets you run scheduled tasks on a computer. These tasks
are called **cronjobs.** If you have already followed the initial course you
will have already used cron when you set up Certbot, but we'll explain how they work generally here.

## What tasks would I want to schedule?

You can schedule anything! Some examples of what you might have done
already include:

-   `updatedb` to update your `locate` database to let you quicking search for files
-   `certbot` to update renewing of your https certs

Some tasks that you might *want* to schedule may include:

-   Package updates - if you really just want to leave your server alone
    you can automated updating packages on your server
-   Backups - you may want to backup certain files every day and some
    every week, this is possible with cron

And many more, anything you can do can be turned into a cronjob.

## Basic Cronjobs

This the preferred method for personal tasks and scripts; it\'s also the
easiest to get started with. Run the command `crontab -e` to access your
user\'s crontab

Once you have figured out the command you want to run you need to figure
out how often you want to run it and when. I am going to schedule my
system updates once a week on at 3:30 AM on Mondays.

We now have to convert this time (Every Monday at 3:30 AM) into a cron
time. Cron uses a simple but effective way of scheduling when to run
things.

Crontab expressions look like this `* * * * * command-to-run` The five
elements before the command tell when the command is supposed to be run
automatically.

So for our Monday at 3:30 AM job we would do the following:

```txt
 .---------------- minute (0 - 59)
 | .------------- hour (0 - 23)
 | | .---------- day of month (1 - 31)
 | | | .------- month (1 - 12)
 | | | | .---- day of week (0 - 6)
 | | | | |
 * * * * *
30 3 * * 1 apt -y update && apt -y upgrade
```

### Some notes

-   On the day of the week option, Sunday is 0 and counting up from
    there, Saturday will be 6.
-   `*` designates \"everything\". Our command above has a `*` in the
    day of month and month columns. This means it will run regardless of
    the day of the month or month.
-   The hour option uses 24 hour time. 3 = 3AM, while use 15 for 3PM.

### More examples

Let\'s add another job, our backup job (for the purposes of this our
backup command is just called `backup`). We want to run `backup` every
evening at 11PM. Once we work out the timings for this we can add the to
the same file as the above by running `crontab -e` This would mean our
full crontab would look like this:

```txt
0 23 * * * backup
```

### Consecutive times

Suppose we want a command to run every weekday. We know we can put `1`
(Monday), but we can also use `1-5` to signify from day 1 (Monday) to
day 5 (Friday).

```txt
0 6 * * 1-5 echo "Wakey, wakey, wagie!" >> /home/wagie/alarm
```

The above `echo` command runs every Monday through Friday at 6:00AM.

### Non-consecutive times

We can also randomly specify non-consecutive arguments with a comma.
Suppose you have a script you want to run at the midday of the 1st,
15th, and 20th day of every month. You can specify that by putting
`1,15,20` for the day of the month argument:

```txt
0 12 1,15,20 * * /usr/bin/pay_bills_script
```

### \"Every X minutes/days/months\"

We can also easily run a command every several minutes or months,
without specifying the specific times:

```txt
*/15 * * * * updatedb
```

This cronjob will run the `updatedb` command every 15 minutes.

### Beware of this Rookie Mistake Though\...

Suppose you want to run a script once every other month. You might be
*tempted* write this:

```txt
* * * */2 *
```

That might *feel right*, but this script *will be running once every
minute during that every other month*. You should specify the first two
arguments, because with `*` it will be running every minute and hour!

```txt
0 0 1 */2 *
```

This makes the command run *only* at 0:00 (12:00AM) on the first day of
every two months, which is what we really want.

Consult the website [crontab.guru](https://crontab.guru) for an
intuitive and interactive tester of cronjobs.

## User vs. Root Cronjobs

It is important to note that user accounts all have different cronjobs.
If you have a user account `chad` and edit his crontab with
`crontab -e`, the commands you add will be run as the `chad` user, not
`root` or anyone else.

Bear in mind that if you need root access to run a particular command,
you will usually want to add it as root.

## System-wide cron directories

`crontab -e` is the typical interface for adding cronjobs, but it\'s
important to at least know that system-wide jobs are often stored in the
file directory. Some programs which need cronjobs will automatically
install them in the following way.

Run the command `ls /etc/cron*` you should see a list of directories and
there contents. The directories should be something like the below:

-   /etc/cron.d *This is a crontab like the ones that you create with*
    `crontab -e`
-   /etc/cron.hourly
-   /etc/cron.daily
-   /etc/cron.weekly
-   /etc/cron.monthly

The directories cron.{hourly,daily,weekly,monthly} are where you can put
**scripts** to run at those times. You don\'t put normal cron entries
here. I prefer to use these directories for system wide jobs that don\'t
relate to an individual user.

## Contribution

-   Mark McNally \-- [website](https://mark.mcnally.je),
    [Youtube](https://www.youtube.com/channel/UCMiInY8BhSUtCarO6uu6i_g)
-   Edits and examples by Luke
