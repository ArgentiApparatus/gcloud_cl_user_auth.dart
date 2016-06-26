# Google Cloud Command Line User Authentication

User authentication utility:
* Authenticate a Google cloud command line app with a Google account
* Write credentials to a json file
* Refresh credentials

User authentication library:
* Use the credentials json file in a command line program
* Automatically refresh crredentials while command line program running

[Github Page](https://github.com/argentiapparatus/blurge.dart)

## Using the Utility:

### Activate the Utility:

From the directory that contains the package directory:

    pub global activate gcloud_user_auth -s path

### Getting Credentials:

Create a client json file contaning the Google cloud client identifier and secret

````json
{
  "clientId": {
    "identifier": "...apps.googleusercontent.com",
    "secret":     "..."
  }
}
````

Run the utility to authenticate and get credentials:

Example:

````
> pub global run gcloud_user_auth get -i client.json -c creds.json -s 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/spreadsheets'

Please go to the following URL and grant access:

https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=....
````

Paste the URL in a browser, authenticate with a Google user account.

The utility will write a credentials file. A credentials file can be reused as a client file to reauthenticate with a different account or scopes.

### Refreshing Credentials:

Example:

````
> pub global run gcloud_user_auth refresh -c creds.json
````

## Using the Library

### Dependencies:

blurge.dart is not (yet) available from [pub.dartlang.org](https://pub.dartlang.org/) and must be had from the Github page instead.

To get the latest commited version (which may or may not be broken):

In your `pubspec.yaml`:

```yaml
dependencies:
  blurge:
    git: https://github.com/argentiapparatus/blurge.dart.git
```

To get a specific release, tag or branch (which should not be broken):

```yaml
dependencies:
  blurge:
    git: https://github.com/argentiapparatus/blurge.dart.git
    ref: some-identifer
```

See the Github page to find releases, tags and branches.

See [Pub Dependencies - Github Packages](https://www.dartlang.org/tools/pub/dependencies.html#git-packages)
for more details.

### Imports:

```dart
import 'package:googleapis_auth/auth.dart';
import 'package:blurge/auth_manager.dart';

main(List<String> args) async {

  String credsFile = args[0];
  AuthClient authClient = (await getUserAuthMgr(credsFile)).autoAuthClient;
  ...
}

```
