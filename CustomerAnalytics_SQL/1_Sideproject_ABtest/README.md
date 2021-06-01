## SIDE PROJECT : ABTEST
> **A/B TEST to understand a feature's effect on user behavior**
 
* DB connection : aws
* create table & data insert : python to_sql & sqlalchemy.create_engine

* DATA 

  > **Users** - one row per user, with descriptive information about the user's account.
  > 
  > **Events** - one row per event. These events include login events, messaging events, search events, events logged as users progress through a signup funnel, events around received emails.
  > 
  > **Experiments** - which groups users are sorted into for experiments. one row per user, per experiment (a user should not be in both the test and control groups in a given experiment).
  > 
  > **Normal Distribution** - omits negative Z-Scores.
 
* Query for testing
