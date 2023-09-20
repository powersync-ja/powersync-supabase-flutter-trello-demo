# PowerSync + Supabase Flutter Demo: Trello Demo
Trello App Clone built with [Flutter](https://flutter.dev/) [Powersync](https://powersync.co/) and [Supabase](https://supabase.io/)

See [the overview README](../README.md) for more information about this project.

### The Data Client
This is the **Data Client** which it contains:

* The data models (in `trelloappclone_powersync_client/lib/models`)
* A Powersync client that makes use of the Powersync SDK and adds a few convenience methods for the app use cases (`trelloappclone_powersync_client/lib/protocol/powersync.dart`)
* A `DataClient` API that can be used with from the app code, and provides the higher level data API. (`trelloappclone_powersync_client/lib/protocol/data_client.dart`)

Two important files to point out as well are:

* `trelloappclone_powersync_client/lib/schema.dart` defines the sqlite schema to use for the local synced datastore, and this maps to the model classes.
* `trelloappclone_powersync_client/lib/app_config.dart` contains the tokens and urls needed to connect to Powersync and Supabase.
