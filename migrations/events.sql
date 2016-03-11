-- 1 up
create table if not exists events (
  id       serial primary key,
  log      text,
  incoming json
);
      
-- 1 down
drop table if exists events;
