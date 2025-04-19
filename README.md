# blog

sample web app

## Requirements

* [Qlot](https://github.com/fukamachi/qlot)

## Installation

```
ros install masatoi/blog
qlot install
```

## Creating a database

The following example assumes PostgreSQL.

```
# Create DB user
createuser -d blog

# Create DB (dbname = blog)
WITHOUT_MIDDLEWARE=1 .qlot/bin/utopian db create

# Migration
WITHOUT_MIDDLEWARE=1 .qlot/bin/utopian db migrate
```

## Run

```
# Start server
$ .qlot/bin/utopian server
Hunchentoot server is going to start.
Listening on localhost:5000.

# Call from client
$ curl localhost:5000/ping
{"pong":"ok"}

$ curl localhost:5000/users | jq .

{
  "rows": [
    {
      "name": "foo",
      "uuid": "09e4c9fd-33da-4e0e-a224-347040ee11f4",
      "created_at": "2021-12-19T07:41:40.000000Z",
      "updated_at": "2021-12-19T07:41:40.000000Z"
    },
    {
      "name": "bar",
      "uuid": "3e174c60-f2ed-4f4d-9530-494b2a56310a",
      "created_at": "2021-12-20T17:26:38.000000Z",
      "updated_at": "2021-12-20T17:26:38.000000Z"
    }
  ]
}
```

## Run tests

```
$ .qlot/bin/rove blog.asd
```

## Run with SLIME

See [this link](https://github.com/fukamachi/qlot#working-with-slime) to properly configure Emacs.

```
;; Start server
(ql:quickload :blog)
(blog:start-blog)

;; Run tests
(ql:quickload :rove)
(blog:connect-db)
(rove:run :blog/tests/functional/users/show)
```

## API

https://contellas.stoplight.io/docs/blog-1/YXBpOjMyNjYyNjQz-blog

## License

Copyright (c) 2021 Satoshi Imai

Licensed under the MIT License.
