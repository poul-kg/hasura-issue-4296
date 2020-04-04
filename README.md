`docker-compose -up -d --build`
`hasura console --admin-secret 12345 --endpoint http://localhost:8080`

Check event's retry configuration
open http://localhost:9695/events/manage/triggers/test_event_1/modify , check `Retry configuration`, it's 30/30/60
open http://localhost:9695/events/manage/triggers/test_event_2/modify , check `Retry configuration`, it's 30/30/60

now try to squash

`hasura migrate squash --admin-secret 12345 --endpoint http://localhost:8080 --from 1585992945707 --name squashed`

select `Yes` when asked to remove migrations.

run `./remigrate.sh`, which will erase db, and restart hasura
