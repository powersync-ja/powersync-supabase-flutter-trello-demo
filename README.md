# Powersync + Flutter

## Introduction

Trello App Clone built with [Flutter](https://flutter.dev/), [Powersync](https://powersync.co/) and [Supabase](https://supabase.io/)

<img src="showcase.png" alt="drawing" width="360"/>

The project consists of two components:

- `trelloappclone_powersync_client` is a dart library that defines the domain model and integrates with Powersync and Supabase
- `trelloappclone_flutter` contains the Trello clone Flutter app

## Getting Started

First check out [the getting started guide](https://docs.powersync.co/integration-guides/supabase-+-powersync) for [Powersync](https://powersync.co/) and [Supabase](https://supabase.io/).

Before you proceed, this guide assumes that you have already signed up for free accounts with both Supabase and PowerSync. If you haven't signed up for a **PowerSync account** yet, [click here](https://accounts.journeyapps.com/portal/free-trial?powersync=true) (and if you haven't signed up for **Supabase** yet, [click here](https://supabase.com/dashboard/sign-up)). This guide also assumes that you already have Flutter set up.

Next up we will follow these steps:

1. Configure Supabase:
* Create the demo database schema
* Create the Postgres publication
2. Configure PowerSync:
* Create connection to Supabase
* Configure Global Sync Rules
3. Configure the Trello Clone App
4. Run the app and test
5. Configure improved Sync Rules
6. Run the app and test

## Configure Supabase

- [ ] Create a new Supabase project (or use an existing project if you prefer) and follow the below steps.

- [ ] For ease of use of the Flutter demo app, you can **disable email confirmation** in your Supabase Auth settings. In your Supabase project, go to _"Authentication"_ --> _"Providers"_ -> _"Email"_ and then disable _"Confirm email"_. If you keep email confirmation enabled, the Supabase user confirmation email will reference the default Supabase Site URL ofhttp://localhost:3000 — you can ignore this.

### Creating Database Tables
After creating the Supabase project, we still need to create the tables in the database. For this application we need the following tables:

* `activity`
* `attachment`
* `board`
* `card`
* `checklist`
* `comment`
* `listboard`
* `member`
* `models`
* `trellouser`
* `workspace`

_(We give a brief overview of the app domain later in this README.)_

- [ ] Open the `tables.pgsql` file, and copy the contents. 
- [ ] Paste this into the *Supabase SQL Editor*
- [ ] Run the SQL statements in the editor. (If you get a warning about a "potentially destructive operation", that's a false positive that you can safely ignore.)

### Create the Postgres Publication

PowerSync uses the Postgres [Write Ahead Log (WAL)](https://www.postgresql.org/docs/current/wal-intro.html) to replicate data changes in order to keep PowerSync SDK clients up to date. To enable this we need to create a `publication` in Supabase.

- [ ] Run the below SQL statement in your Supabase SQL Editor:
```sql
create publication powersync for table activity, attachment, board, card, checklist, comment, listboard, member, trellouser, workspace;
```

## Configuring PowerSync

We need to connect PowerSync to the Supabase Postgres database:

- [ ] In the [PowerSync dashboard](https://powersync.journeyapps.com/) Project tree, click on _"Create new instance"_.

- [ ] Give your instance a name, such as _"Trello Clone"_.
 
- [ ] In the _"Edit Instance"_ dialog, navigate to the _"Credentials"_ tab and enable _"Use Supabase Auth"_.

- [ ] Under the _"Connections"_ tab, click on the + icon.

- [ ] On the subsequent screen, we'll configure the connection to Supabase. This is simplest using your Supabase database URI. In your Supabase dashboard, navigate to _"Project Settings"_ -> _"Database"_. Then, under the _"Connection String"_ section, switch to URI and copy the value.

- [ ] Paste the copied value into the _"URI"_ field in PowerSync:

- [ ] Enter the Password for the `postgres` user in your Supabase database. (Supabase also [refers to this password](https://supabase.com/docs/guides/database/managing-passwords) as the database password or project password)

- [ ] Click _"Test Connection"_ and fix any errors:

- [ ] Click "Save"

PowerSync deploys and configures an isolated cloud environment for you, which will take a few minutes to complete:


## Configuring Sync Rules - 1
[Sync rules](https://docs.powersync.co/usage/sync-rules) allow developers to control which data gets synced to which user devices using a SQL-like syntax in a YAML file.  For the demo app, we're first going to use naive global sync rules, and then present improved rules that takes the domain permissions into account.

### Global sync rules to get things working

We can be naive about it, and use a global bucket definition that at least specify in some way which users can get data. 

- [ ] Copy the contents of `trelloappclone_powersync_client.dart/sync-rules-0.yaml` to `sync-rules.yaml` under your Powersync project instance
- [ ] In the top right of the editor, click _"Deploy sync rules"_. 
- [ ] Confirm in the dialog and wait a couple of minutes for the deployment to complete. 

When you now run the app (after completing the next step to configure and run the app), it will actually show and retain data. The app code itself applies some basic filtering to only show data that belongs to the current user, or according to the visibility and membership settings of the various workspaces and boards.

## Configuring Flutter App

We need to configure the app to use the correct Powersync and Supabase projects.

- [ ] Open and edit the `trelloappclone_powersync_client.dart/lib/app_config.dart` file.
- [ ] Replace the values for `supabaseUrl` and `supabaseAnonKey` (You can find these under _"Project Settings"_ -> _"API"_ in your Supabase dashboard — under the _"URL"_ section, and anon key under _"Project API keys"_.)
- [ ] For the value of powersyncUrl, follow these steps:
1. In the project tree on the PowerSync dashboard, right-click on the instance you created earlier.
2. Click _"Edit instance"_.
3. Click on _"Instance URL"_ to copy the value.
 

## Build & Run the App

- [ ] Run ``` flutter pub get ``` to install the necessary packages on your command line that's navigated to the root of the project.
- [ ] Invoke the ``` flutter run ``` command, and select either an Android device/emulator or iOS device/simulator as destination (_Note: Powersync does not support flutter web apps yet._)


## Configuring Sync Rules - 2

### Using sync rules to enforce permissions
We have syncing working, but the sync rules are not enforcing the access rules from the domain in any way.

It is better that we do not sync data to the client that the logged-in user is not allowed to see. We can use Powersync sync rules to enforce permissions, so that users can only see and edit data that they are allowed to see and edit.

First, we need to understand the permissions from the app domain model:

- A **workspace** is created by a user — this user can always see and edit the workspace.
- A **workspace** has a specific *visibility*: private (only the owner can see it), workspace (only owner and members can see it), or public (anyone can see it).
- A **workspace** has a list of *members* (users) that can see and edit the workspace, if the workspace is not private.
- A **board** is created by a user — this user can always see and edit the board as long as the user can still access that workspace
- A **board** has a specific *visibility*: private (only the owner can see it), workspace (only owner and members belonging to the parent workspace can see it)
- A user can see (and edit) any of the **cards** and **lists** belonging to a **board** that they have access to.
- A user can see (and edit) any of the **checklists**, **comments**, and **attachments** belonging to a **card** that they have access to.

Also have a look at `trelloappclone_flutter/lib/utils/service.dart` for the access patterns used by the app code.

Let us explore how we can use sync rules to enforce these permissions and access patterns.

First we want to sync the relevant `trellouser` record for the logged-in user, based on the user identifier:

```yaml
bucket_definitions:
  user_info:
    # this allows syncing of trellouser record for logged-in user
    parameters: SELECT id as user_id FROM trellouser WHERE trellouser.id = token_parameters.user_id
    data:
      - SELECT * FROM trellouser WHERE trellouser.id = bucket.user_id
```

Then we want to look up all the workspaces (a) owned by this user, (b) where this user is a member, or (c) which are public.

```yaml
  by_workspace:
    # the entities are filtered by workspaceId, thus linked to the workspaces (a) owned by this user, (b) where this user is a member, or (c) which are public
    # Note: the quotes for "workspaceId" and "userId" is important, since otherwise postgres does not deal well with non-lowercase identifiers
    parameters:
      - SELECT id as workspace_id FROM workspace WHERE
        workspace."userId" = token_parameters.user_id
      - SELECT "workspaceId" as workspace_id FROM member WHERE
        member."userId" = token_parameters.user_id
      - SELECT id as workspace_id FROM workspace WHERE
        visibility = "Public"
    data:
      - SELECT * FROM workspace WHERE workspace.id = bucket.workspace_id
      - SELECT * FROM board WHERE board."workspaceId" = bucket.workspace_id
      - SELECT * FROM member WHERE member."workspaceId" = bucket.workspace_id
      - SELECT * FROM listboard WHERE listboard."workspaceId" = bucket.workspace_id
      - SELECT * FROM card WHERE card."workspaceId" = bucket.workspace_id
      - SELECT * FROM checklist WHERE checklist."workspaceId" = bucket.workspace_id
      - SELECT * FROM activity WHERE activity."workspaceId" = bucket.workspace_id
      - SELECT * FROM comment WHERE comment."workspaceId" = bucket.workspace_id
      - SELECT * FROM attachment WHERE attachment."workspaceId" = bucket.workspace_id
```

**To configure the improved sync rules, follow these steps:**

- [ ] Copy the contents of `trelloappclone_powersync_client.dart/sync-rules-1.yaml`.
- [ ] Paste this to `sync-rules.yaml` under your Powersync project instance
- [ ] and click _"Deploy sync rules"_.
- [ ] Confirm in the dialog and wait a couple of minutes for the deployment to complete.

Now you can run the app again, and it should now only sync the subset of data that a logged in user actually has access to.

### Importing / Generating Data

When you run the app, after logging in, you will start without any workspaces or boards. It is possible to generate a workspace with sample boards and cards in order to make it easier to have enough data to experiment with, without having to manually create every item.

- [ ] Sign up and log in to the app.
- [ ] In the home view, tap on the "+" floating button in the lower right corner.
- [ ] Tap on _"Sample Workspace"_ and give it a name — this will create a new workspace, with multiple boards with lists, and a random number of cards with checklists, comments and activities for each list. 

<img src="sample_workspace.png" alt="drawing" width="360"/>

## App Architecture Overview

The project consists of two components, the **App** (`trelloappclone_flutter`) and the **Data Client** (`trelloappclone_powersync_client`).

### The Data Client
The **Data Client** is a separate Dart library, and it contains:

* The data models (in `trelloappclone_powersync_client/lib/models`)
* A Powersync client that makes use of the Powersync SDK and adds a few convenience methods for the app use cases (`trelloappclone_powersync_client/lib/protocol/powersync.dart`)
* A `DataClient` API that can be used with from the app code, and provides the higher level data API. (`trelloappclone_powersync_client/lib/protocol/data_client.dart`)

Two important files to point out as well are:

* `trelloappclone_powersync_client/lib/schema.dart` defines the sqlite schema to use for the local synced datastore, and this maps to the model classes.
* `trelloappclone_powersync_client/lib/app_config.dart` contains the tokens and urls needed to connect to Powersync and Supabase.


### Listening to updated data

The Powersync SDK makes use of `watch` queries to listen for changes to synced data. When the SDK syncs updated data from the server, and it matches the query, it will send an event out, allowing e.g. an app view (via `StreamBuilder`) or some other state management class to respond.

As an example look at `trelloappclone_flutter/lib/utils/service.dart`:

```dart
  Stream<List<Workspace>> getWorkspacesStream() {
    return dataClient.workspace.watchWorkspacesByUser(userId: trello.user.id).map((workspaces) {
      trello.setWorkspaces(workspaces);
      return workspaces;
    });
  }
```

This in turn makes use of the `_WorkspaceRepository` class:
```dart
  Stream<List<Workspace>> watchWorkspacesByUser({required String userId}) {
    //First we get the workspaces
    return client.getDBExecutor().watch('''
          SELECT * FROM workspace WHERE userId = ?
           ''', parameters: [userId]).asyncMap((event) async {
      List<Workspace> workspaces = event.map((row) => Workspace.fromRow(row)).toList();

      //Then we get the members for each workspace
      for (Workspace workspace in workspaces) {
        List<Member> members = await client.member.getMembersByWorkspace(workspaceId: workspace.id);
        workspace.members = members;
      }
      return workspaces;
    });
  }
```

Now we can simply make use of a `StreamBuilder` to have a view component that updates whenever a matching workspace is updated:

```dart
      StreamBuilder(
          stream: getWorkspacesStream(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Workspace>> snapshot) {
            if (snapshot.hasData) {
              List<Workspace> children = snapshot.data as List<Workspace>;

              if (children.isNotEmpty) {
                return SingleChildScrollView(
                    child:
                        Column(children: buildWorkspacesAndBoards(children)));
              }
            })
```

### Transactions 
TODO: discussion of transaction example?

### Changes from original Trello clone app

The app code was forked from the [Serverpod + Flutter Tutorial](https://github.com/Mobterest/serverpod_flutter_tutorial) code. It was changed in the following ways to facilitate the Powersync integration:

- Updated data model so that all `id` fields are Strings, and using UUIDs (it was auto-increment integer fields in the original app)
- Updated data model so that all entities refers to the `workspaceId` of workspace in which it was created (this facilitates the sync rules)

## Next 

Below is a list of things that we can consider to do to enhance the functionality and experience of this app.

* Fix Lists in a board to keep its order, and Cards in a list to keep its ranking
* Update Workspace + Board edit views to use actual data and update the entity
* Fix Members functionality (at least Workspace members invite/edit) to actually work
* Get Comments & Checklists working properly
* Allow user to import existing workspaces/board/etc from e.g. Trello (either via API or exported json)
* Enhancing UX of app (there are many irritating issues and things not working yet in the original app)
* Update of password or email
* Enhance state management - e.g. let `TrelloProvider` listen to streams, and notify changes, to simplify views
* Get the attachments to actually work (using Supabase files upload/download)

## Feedback

- Feel free to send feedback . Feature requests are always welcome. If there's anything you'd like to chat about, please don't hesitate to [reach out to us](https://docs.powersync.co/resources/contact-us).

## Acknowledgements

This tutorial is based on the [Serverpod + Flutter Tutorial](https://github.com/Mobterest/serverpod_flutter_tutorial) by [Mobterest](https://www.instagram.com/mobterest/

# TODOs

## Must DOs
- [X] Basic Powersync and Supabase setup
- [X] Create Supabase tables
- [X] Port Serverpod client code to Powersync client code
- [X] Update App code to user powersync client code
- [X] Test if it works with local db (sqlite)
- [X] Update to use Supabase Auth
- [X] implement basic global sync rules
- [X] Test if global syncing works
- [X] Tweak datamodel to allow per workspace lookups: add workspaceId reference to various entities (update on supabase, etc)
- [X] Tweak sync rules to enforce permissions (according to workspace owner, visibility, and members)
- [X] Test if permissions are enforced by Powersync
- [X] Look at using watch queries (for when other users update data)
- [X] BUG: look at listboard loading for new boards? (not seeing new empty lists..)
- [X] Data generation functionality for testing bigger datasets
- [X] Show message/spinner while syncing after login - check sync status (lastSyncedAt)
- [X] remember logged-in state (Supabase side remember auth session, but app not...)
- [X] remove/hide/disable unused things (alternative logins, offline boards, my cards, members buttons)
- [X] drag and drop must work
- [X] disable invalid login/signup options
- [X] BUG: cards loaded inconsistently for boards
- [X] test on Android
- [ ] README/Tutorial writing & cleanup
- [ ] Look at using transactions (if time, else in next round))

