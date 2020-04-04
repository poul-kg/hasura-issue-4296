Related to Hasura issue: https://github.com/hasura/graphql-engine/issues/4296

## Prerequisites:
* hasura cli 1.1.0
* also tested with v1.2.0-beta.3


* `docker-compose up -d --build`
* `hasura migrate apply --admin-secret 12345 --endpoint http://localhost:8080`
* `hasura console --admin-secret 12345 --endpoint http://localhost:8080`

Check event's retry configuration
* open http://localhost:9695/events/manage/triggers/test_event_1/modify , check `Retry configuration`, it's 30/30/60
* open http://localhost:9695/events/manage/triggers/test_event_2/modify , check `Retry configuration`, it's 30/30/60

now try to squash
Ctrl+C to stop hasura console

`hasura migrate squash --admin-secret 12345 --endpoint http://localhost:8080 --from 1585992945707 --name squashed`

select `Yes` when asked to remove migrations.

run `./remigrate.sh`, which will stop docker, remove db volume, start docker, run hasura migrations

then run console

`hasura console --admin-secret 12345 --endpoint http://localhost:8080`

Check event's retry configuration
* open http://localhost:9695/events/manage/triggers/test_event_1/modify , check `Retry configuration`, it's 0/10/60
* open http://localhost:9695/events/manage/triggers/test_event_2/modify , check `Retry configuration`, it's 10/10/60
* open squashed `up.yml` file:

```YAML
- args:
    headers: []
    insert:
      columns: '*'
    name: test_event_1
    replace: true
    table:
      name: test_table_1
      schema: public
    webhook: http://localhost:8080/api/test_event_1
  type: create_event_trigger
- args:
    headers: []
    insert:
      columns: '*'
    name: test_event_2
    replace: true
    table:
      name: test_table_2
      schema: public
    webhook: http://localhost/test_event_2
  type: create_event_trigger
```

there is no information about retry configuration here

## Expected behavior

after running squashed migration, I want `Retry configuration` be preserved

* when I open http://localhost:9695/events/manage/triggers/test_event_1/modify , and check `Retry configuration`, it should still be 30/30/60
* when I open http://localhost:9695/events/manage/triggers/test_event_2/modify , and check `Retry configuration`, it should still be 30/30/60

YAML file of squashed migration should be (I'm not sure about format, it's my guess):

I've checked format below, it doesn't work, so probably a migration cli do not support it

```YAML
- args:
    headers: []
    insert:
      columns: '*'
    name: test_event_1
    retry_conf:
      interval_sec: 10
      num_retries: 0
      timeout_sec: 60
    replace: true
    table:
      name: test_table_1
      schema: public
    webhook: http://localhost:8080/api/test_event_1
  type: create_event_trigger
- args:
    headers: []
    insert:
      columns: '*'
    name: test_event_2
    retry_conf:
      interval_sec: 10
      num_retries: 0
      timeout_sec: 60
    replace: true
    table:
      name: test_table_2
      schema: public
    webhook: http://localhost/test_event_2
  type: create_event_trigger
```
