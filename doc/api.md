# API

Most of the API calls require a valid `params[:auth_token]`. In those cases, when a valid token is not provided, the system will return

    message: "Invalid authorization token", :status => 401

## User Sessions

##### POST /api/user_sessions

Use it to retrieve the `auth_token`.

Requires:
  - `params[:email]`
  - `params[:password]`

if valid credentials and confirmed user: returns the user information, along with its `auth_token` and `game_data`

*Example response*

    {
      id: 303,
      email: "peter@parker.com",
      nickname: "Peter",
      location: {
        id:   "3dde8e8....",
        name: "Berlin",
      },
      group: {
        id:   "2329bc1...",
        name: "Foo"
      },
      gender: "Female",
      birth_date_year: "1990",
      birth_date_month: "12",
      birth_date_day: "1",
      auth_token: "2afd5910eaebfc304bb26acdc7e19645af072c...",
      game_data: {
        data: {
          //...
        }
      }
    }, status: 200


if valid credentials or invalid credentials but not registered:

    { message: "Registration pending" }, status: 412

if invalid credentials:

    { message: "Invalid credentials" }, status: 401

##### DELETE  /api/user_sessions/reset
It will change the auth_token of this user

Requires
  - `params[:auth_token]`


*Example response*

    { message: "Auth token reset successful" }, status: 200


## User Password Reset

##### POST	/api/password_resets
It will send a password reset email to the given user email if it exists.

Requires
  - `params[:email]`

*Example Response* (regardless of valid email or not):

    { message: "Instructions have been sent to your email" }, status: 200


##### PATCH	/api/password_resets/:token
Use it to set a new password.

Requires
  - `params[:token]` as part of the route
  - `params[:user][:password]`
  - `params[:user][:password_confirmation]`

when valid params:

    { message: "Password was successfully updated." }, status: 200


when invalid params:

    { message: "Invalid password change"}, status: 422



## Users

##### GET /api/users/:id
Returns the user information with his game_data

Requires
- `params[:id]` as part of the route
- `params[:auth_token]`

*Example response*

    {
      id: 303,
      email: "peter@parker.com",
      nickname: "peter",
      location: {
        id:   "3dde8e8....",
        name: "Berlin",
      },
      group: {
        id:   "2329bc1...",
        name: "Foo"
      },
      gender: "Female",
      birth_date_year: "1990",
      birth_date_month: "12",
      birth_date_day: "1",
      auth_token: "2afd5910eaebfc304bb26acdc7e19645af072c...",
      game_data: {
        data: {
          //...
        }
    }, status: 200


##### PATCH /api/users/register
Registers the user after installing the game.

Requires:
  - `params[:registration_code]`
  - `params[:user][:nickname]`
  - `params[:user][:password]`

when valid, returns the user json with the `game_data` and `auth_token`:

*Example response*

    {
      id: 303,
      email: "peter@parker.com",
      nickname: "peter",
      location: {
        id:   "3dde8e8....",
        name: "Berlin",
      },
      group: {
        id:   "2329bc1...",
        name: "Foo"
      },
      gender: "Female",
      birth_date_year: "1990",
      birth_date_month: "12",
      birth_date_day: "1",
      auth_token: "2afd5910eaebfc304bb26acdc7e19645af072c...",
      game_data: {
        data: {
          //...
        }
    }, status: 200

when the registration code is invalid, it returns

    { message: "Invalid registration code" }, :status => 401



when invalid nickname or password, returns a hash of errors

    {
      errors: {
        nickname: "can't be blank"
      }
    }, status: 422


if the user was previously registered, it returns:

    { message: "User already registered. Use credentials to log in." }, status: 412


##### PATCH /api/users/:id/change_password
Changes the user password (for logged in users).

Requires:
  - `params[:id]` as part of the route
  - `params[:auth_token]`
  - `params[:user][:password]`

when valid, it returns

    { message: "Password changed" }, status: 200

when invalid password, returns a hash of errors

    {
      errors: {
        password: "invalid"
      }
    }, status: 422


## Game Data

##### GET /api/users/:user_id/game_data

Get the game data from a given user

Requires:
  - `params[:auth_token]`
  - `params[:user_id]` as part of the route.

*Example response*

    {
      data: {...}
    }, status: 200


##### PATCH /api/users/:user_id/game_data

Change the game data for a given user

Requires:
- `params[:auth_token]`
- `params[:user_id]` as part of the route.
- `params[:game_data][:data]`

if there is not game data provided it returns:

    { message: "Invalid Game Data." }, status: 422

if the params are valid it returns:

    { message: "Game Data saved." }, status: 200


## Player Sessions

##### POST /api/player_sessions

Creates a new play session for the current user

Requires:
- `params[:auth_token]`
- `params[:player_session][:started_at]`
- `params[:player_session][:finished_at]`

The dates should be in UTC format, such as in `(new Date()).toUTCString() -> "Thu, 14 Apr 2016 16:40:48 GMT"`. The minimum timespan between `started_at` and `finished_at` is one second.


*Example response*

    {
      id:                  "2e4f4576-ee28-4d53-9762-6ff463b711bc",
      started_at:          "2016-04-15T07:09:33.000Z",
      finished_at:         "2016-04-15T07:29:33.000Z",
      duration_in_seconds: 1200
    }, status: 200


This date format can also be parsed from javascript with `new Date("2016-04-15T07:09:33.000Z")`

if the params are invalid it returns:

    { message: "Invalid Player Session." }, status: 422

##### PUT /api/player_sessions/:id

Updates or creates a new play session for the current user, depending on whether the `params[:id]` corresponds to an exiting record. The `id` needs to be a valid UUID. The format for UUID is `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`, where x is any hexadecimal digit and y is one of 8, 9, A, or B (e.g., efe1f2aa-1e99-40f2-83fa-8519acd8c34c). The backend will also accept it without dashes.

One library to this in Javascript is the [node-uuid](https://npmjs.org/package/node-uuid) module, which can be installed with `npm install node-uuid`.

    var uuid = require('node-uuid');
    var uuid1 = uuid.v4(); // e.g. 32a4fbed-676d-47f9-a321-cb2f267e2918
    var uuid2 = uuid.v4(); // e.g. 8b68cf5b-d619-4281-b560-1578b0ee891d

See more details at [https://blog.tompawlak.org/generate-random-values-nodejs-javascript](https://blog.tompawlak.org/generate-random-values-nodejs-javascript)

Requires:
- `params[:auth_token]`
- `params[:id]`
- `params[:player_session][:started_at]`
- `params[:player_session][:finished_at]`


*Example response*

    {
      id:                  "2e4f4576-ee28-4d53-9762-6ff463b711bc",
      started_at:          "2016-04-15T07:09:33.000Z",
      finished_at:         "2016-04-15T07:29:33.000Z",
      duration_in_seconds: 1200
    }, status: 200


if the params are invalid it returns:

    { message: "Invalid Player Session." }, status: 422

##### GET /api/player_sessions

Returns the complete list of sessions ordered by `finished_at` (most recents first)

Requires:
- `params[:auth_token]`

*Example response*

    [
      {
        id:                  "997ec3ca-59ec-4bb1-b69a-83788f40aec6",
        started_at:          "2016-03-15T07:39:01.986Z",
        finished_at:         "2016-03-15T08:18:02.986Z",
        duration_in_seconds: 2341
      },
      {
        id:                  "290d7b6f-c786-41f6-8a0c-41d5e55cda76",
        started_at:          "2016-03-02T07:39:01.983Z",
        finished_at:         "2016-03-02T08:19:02.983Z",
        duration_in_seconds: 2401
      },
      ...
    ], status: 200



##### GET /api/player_sessions/:id

Returns the given session

Requires:
- `params[:auth_token]`
- `params[:id]`

*Example response*

    {
      id:                  "2e4f4576-ee28-4d53-9762-6ff463b711bc",
      started_at:          "2016-04-15T07:09:33.000Z",
      finished_at:         "2016-04-15T07:29:33.000Z",
      duration_in_seconds: 1200
    }, status: 200


if the session is not found it returns:

    { message: "Player Session not found" }, status: 404

##### DELETE /api/player_sessions/:id

Deletes the given session

Requires:
- `params[:auth_token]`
- `params[:id]`

*Example response*

    { message: "Player Session deleted" }, status: 200

if the session is not found it returns:

    { message: "Player Session not found" }, status: 404
