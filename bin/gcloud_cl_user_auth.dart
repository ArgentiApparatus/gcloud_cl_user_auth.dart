// Copyright (c) 2016, Gary Smith. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:http/http.dart' as http;

import 'package:gcloud_cl_user_auth/user_creds_encoding.dart';

// TODO proper error handling



main(List<String> args) async {

  CommandRunner commandRunner = new CommandRunner('gcloud_user_auth', 'Utility for getting Google user credentials for command line apps.')
    ..addCommand(new GetUserConsentCommand())
    ..addCommand(new RefreshCredentialsCommand());

  try {

      await commandRunner.run(args);

  } on UsageException catch(e) {
    print(e);
  } on FormatException catch(e) {
    print('Error parsing a file');
    print(e);
  }
}



class GetUserConsentCommand extends Command {

  String get name => 'get';

  String get description => 'Gets user consent for application; writes user credentials to file.';

  GetUserConsentCommand() {
    argParser.addOption('client', abbr: 'i', help: 'Client info.');
    argParser.addOption('creds',  abbr: 'c', help: 'Output user credentials file.');
    argParser.addOption('scopes', abbr: 's', help: 'Space separated list of requested scopes.', allowMultiple: true);
  }

  dynamic run() async {

    http.Client client;
    AuthClient authClient;

    try {

      // Possible errors:
      //   Creds option not provided
      //   ClientId file can't be read
      //   No clientId or fucked up clientId in clientId file
      //   Get user consent fucks Up
      //   Get user info fucks up
      //   Creds file cannot be written

      // TODO add client ID and secret options
      // TODO how to print instructions for each command?

      // Read clientId file
      Map clientIdMap = JSON.decode(new File(argResults['client']).readAsStringSync());

      // Get info from clientId file
      ClientId clientId = decodeClientId(clientIdMap['clientId']);

      print(argResults['client']);
      print(argResults['creds']);
      print(argResults['scopes']);

      // Get user consent
      client = new http.Client();
      argResults['scopes'].add('https://www.googleapis.com/auth/userinfo.email');
      AccessCredentials creds = await obtainAccessCredentialsViaUserConsent(clientId, argResults['scopes'], client, promptBuilder);

      // Get user info
      authClient = authenticatedClient(client, creds);
      Oauth2Api oauth2 = new Oauth2Api(authClient);
      Userinfoplus userInfo = await oauth2.userinfo.v2.me.get();

      // Write creds to file
      File userCredsFile = new File(argResults['creds']);
      UserCreds userCreds = new UserCreds(clientId, userInfo.email, creds, new DateTime.now());
      userCredsFile.writeAsStringSync(JSON.encode(encodeUserCreds(userCreds)), flush: true);

    } finally {
      authClient?.close();
      client?.close();
    }
  }
}


class RefreshCredentialsCommand extends Command {

  String get name => 'refresh';

  String get description => 'Refreshes user credentials.';

  RefreshCredentialsCommand() {
    argParser.addOption('creds', abbr: 'c', help: 'User credentials file (will be modified).');
  }

  dynamic run() async {

    http.Client client;

    try {

      // Possible errors:
      //   user option not provided
      //   user file can't be read
      //   No clientId or fucked up clientId in user file
      //   No creds or fucked up creds in user file
      //   Refresh creds fucks up
      //   User file cannot be written


      // Read user creds file
      File userCredsFile = new File(argResults['creds']);
      UserCreds userCreds = decodeUserCreds(JSON.decode(userCredsFile.readAsStringSync()));

      // Refresh credentials
      client = new http.Client();
      userCreds.accessCredentials = await refreshCredentials(userCreds.clientId, userCreds.accessCredentials, client);

      // Update user credentials file
      userCredsFile.writeAsStringSync(JSON.encode(encodeUserCreds(userCreds)), flush: true);

    } finally {
      client?.close();
    }
  }

}


void promptBuilder(String url) {

  print('Please go to the following URL and grant access:');
  print('');
  print('$url');
  print('');
}